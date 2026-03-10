import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ========================
// NOTIFICATION HELPERS
// ========================

interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

async function sendPushNotification(payload: NotificationPayload): Promise<void> {
  try {
    // Get user's FCM token
    const userDoc = await db.collection('users').doc(payload.userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token for user ${payload.userId}`);
      return;
    }

    // Send push notification
    await messaging.send({
      token: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      android: {
        priority: 'high',
        notification: {
          channelId: 'default',
          priority: 'high',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: payload.title,
              body: payload.body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
    });

    // Store notification in Firestore
    await db.collection('notifications').add({
      userId: payload.userId,
      title: payload.title,
      body: payload.body,
      data: payload.data || {},
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Notification sent to user ${payload.userId}`);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

// ========================
// BOOKING NOTIFICATIONS
// ========================

// Notify organizer when new booking request is created
export const onBookingCreated = functions.firestore
  .document('bookingRequests/{requestId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();

    // Get exhibitor name
    const exhibitorDoc = await db.collection('users').doc(booking.exhibitorId).get();
    const exhibitorName = exhibitorDoc.data()?.name || 'A user';

    // Get event title
    const eventDoc = await db.collection('events').doc(booking.eventId).get();
    const eventTitle = eventDoc.data()?.title || 'an event';

    // Notify organizer
    await sendPushNotification({
      userId: booking.organizerId,
      title: 'New Booking Request',
      body: `${exhibitorName} wants to book booth ${booking.boothNumber || ''} for ${eventTitle}`,
      data: {
        type: 'booking_request',
        bookingId: context.params.requestId,
        eventId: booking.eventId,
      },
    });
  });

// Notify exhibitor when booking status changes
export const onBookingStatusChanged = functions.firestore
  .document('bookingRequests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed
    if (before.status === after.status) {
      return;
    }

    // Get event title
    const eventDoc = await db.collection('events').doc(after.eventId).get();
    const eventTitle = eventDoc.data()?.title || 'your event';

    let title = '';
    let body = '';

    switch (after.status) {
      case 'approved':
        title = 'Booking Approved!';
        body = `Your booking for ${eventTitle} has been approved. Please proceed with payment.`;
        break;
      case 'rejected':
        title = 'Booking Rejected';
        body = `Your booking for ${eventTitle} has been rejected.${after.rejectionReason ? ` Reason: ${after.rejectionReason}` : ''}`;
        break;
      case 'confirmed':
        title = 'Booking Confirmed!';
        body = `Your booking for ${eventTitle} is confirmed. See you at the event!`;
        break;
      case 'cancelled':
        title = 'Booking Cancelled';
        body = `The booking for ${eventTitle} has been cancelled.`;
        break;
      default:
        return;
    }

    // Notify exhibitor
    await sendPushNotification({
      userId: after.exhibitorId,
      title,
      body,
      data: {
        type: 'booking_status',
        bookingId: context.params.requestId,
        status: after.status,
      },
    });
  });

// ========================
// CHAT NOTIFICATIONS
// ========================

// Notify user when new message is received
export const onNewMessage = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const { chatId } = context.params;

    // Get chat to find recipient
    const chatDoc = await db.collection('chats').doc(chatId).get();
    const chat = chatDoc.data();

    if (!chat) return;

    // Find recipient (other participant)
    const recipientId = chat.participants.find(
      (id: string) => id !== message.senderId
    );

    if (!recipientId) return;

    // Get sender name
    const senderName = chat.participantNames[message.senderId] || 'Someone';

    // Notify recipient
    await sendPushNotification({
      userId: recipientId,
      title: senderName,
      body: message.type === 'image' ? '📷 Sent an image' : message.text,
      data: {
        type: 'new_message',
        chatId,
        senderId: message.senderId,
      },
    });
  });

// ========================
// EVENT NOTIFICATIONS
// ========================

// Notify interested users when event is updated
export const onEventUpdated = functions.firestore
  .document('events/{eventId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const { eventId } = context.params;

    // Check if event was just published
    if (before.status !== 'published' && after.status === 'published') {
      // Get all interests for this event
      const interests = await db.collection('interests')
        .where('eventId', '==', eventId)
        .get();

      // Notify each interested user
      const notifications = interests.docs.map((doc) =>
        sendPushNotification({
          userId: doc.data().userId,
          title: 'Event Published!',
          body: `${after.title} is now live. Check it out!`,
          data: {
            type: 'event_published',
            eventId,
          },
        })
      );

      await Promise.all(notifications);
    }

    // Check if event dates changed
    if (before.startDate !== after.startDate || before.location !== after.location) {
      // Get all bookings for this event
      const bookings = await db.collection('bookingRequests')
        .where('eventId', '==', eventId)
        .where('status', 'in', ['approved', 'confirmed'])
        .get();

      // Notify exhibitors
      const notifications = bookings.docs.map((doc) =>
        sendPushNotification({
          userId: doc.data().exhibitorId,
          title: 'Event Details Updated',
          body: `${after.title} details have been updated. Please check the new information.`,
          data: {
            type: 'event_updated',
            eventId,
          },
        })
      );

      await Promise.all(notifications);
    }
  });

// ========================
// JOB NOTIFICATIONS
// ========================

// Notify when job application status changes
export const onJobApplicationStatusChanged = functions.firestore
  .document('jobApplications/{applicationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;

    // Get job details
    const jobDoc = await db.collection('eventJobs').doc(after.jobId).get();
    const jobTitle = jobDoc.data()?.title || 'a job';

    let title = '';
    let body = '';

    switch (after.status) {
      case 'reviewed':
        title = 'Application Under Review';
        body = `Your application for "${jobTitle}" is being reviewed.`;
        break;
      case 'accepted':
        title = 'Application Accepted!';
        body = `Congratulations! Your application for "${jobTitle}" has been accepted.`;
        break;
      case 'rejected':
        title = 'Application Update';
        body = `Your application for "${jobTitle}" was not selected.${after.feedback ? ` Feedback: ${after.feedback}` : ''}`;
        break;
      default:
        return;
    }

    await sendPushNotification({
      userId: after.userId,
      title,
      body,
      data: {
        type: 'job_application_status',
        applicationId: context.params.applicationId,
        jobId: after.jobId,
        status: after.status,
      },
    });
  });

// ========================
// CLEANUP FUNCTIONS
// ========================

// Clean up expired booth reservations (runs every 5 minutes)
export const cleanupExpiredReservations = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async () => {
    const fifteenMinutesAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 15 * 60 * 1000)
    );

    // Find all events
    const events = await db.collection('events').get();

    for (const event of events.docs) {
      // Find expired reservations
      const expiredBooths = await db
        .collection('events')
        .doc(event.id)
        .collection('booths')
        .where('status', '==', 'reserved')
        .where('reservedAt', '<', fifteenMinutesAgo)
        .get();

      // Release expired reservations
      const batch = db.batch();

      for (const booth of expiredBooths.docs) {
        batch.update(booth.ref, {
          status: 'available',
          reservedBy: null,
          reservedAt: null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Also update any related pending booking requests
        const pendingBookings = await db.collection('bookingRequests')
          .where('boothId', '==', booth.id)
          .where('status', '==', 'pending')
          .get();

        for (const booking of pendingBookings.docs) {
          batch.update(booking.ref, {
            status: 'cancelled',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      if (expiredBooths.size > 0) {
        console.log(`Released ${expiredBooths.size} expired reservations for event ${event.id}`);
      }
    }

    return null;
  });

// ========================
// USER MANAGEMENT
// ========================

// When admin creates a user document, ensure phone number mapping
export const onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();

    // Subscribe user to role-based topic for targeted notifications
    if (user.fcmToken) {
      await messaging.subscribeToTopic([user.fcmToken], `role_${user.role}`);
    }
  });

// ========================
// ANALYTICS & AGGREGATIONS
// ========================

// Update interested count when interest is added/removed
export const onInterestChange = functions.firestore
  .document('interests/{interestId}')
  .onWrite(async (change, context) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;

    // Determine the event ID and increment value
    const eventId = after?.eventId || before?.eventId;
    const increment = after && !before ? 1 : (!after && before ? -1 : 0);

    if (eventId && increment !== 0) {
      await db.collection('events').doc(eventId).update({
        interestedCount: admin.firestore.FieldValue.increment(increment),
      });
    }
  });
