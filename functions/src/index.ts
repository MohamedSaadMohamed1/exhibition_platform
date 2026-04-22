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
  type?: string;
  targetId?: string;
  data?: Record<string, string>;
}

async function sendPushNotification(payload: NotificationPayload): Promise<void> {
  try {
    // Always store notification in Firestore first — visible in-app regardless of push delivery.
    // skipPush: true prevents onNotificationCreated from re-triggering a second FCM push.
    await db.collection('notifications').add({
      userId: payload.userId,
      title: payload.title,
      body: payload.body,
      type: payload.type ?? 'general',
      targetId: payload.targetId ?? null,
      data: payload.data || {},
      isRead: false,
      skipPush: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Get user's FCM tokens (support both single token and array)
    const userDoc = await db.collection('users').doc(payload.userId).get();
    const userData = userDoc.data();

    if (!userData) {
      console.log(`User ${payload.userId} not found — notification stored, push skipped`);
      return;
    }

    // Collect all valid tokens (deduplicated)
    const tokens: string[] = [];
    if (userData.fcmToken && typeof userData.fcmToken === 'string') {
      tokens.push(userData.fcmToken);
    }
    if (Array.isArray(userData.fcmTokens)) {
      for (const t of userData.fcmTokens) {
        if (typeof t === 'string' && !tokens.includes(t)) tokens.push(t);
      }
    }

    if (tokens.length === 0) {
      console.log(`No FCM tokens for user ${payload.userId} — notification stored, push skipped`);
      return;
    }

    const messageBase = {
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      android: {
        priority: 'high' as const,
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high' as const,
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
    };

    // Send to all tokens, remove invalid ones
    const response = await messaging.sendEachForMulticast({
      tokens,
      ...messageBase,
    });

    // Remove invalid tokens from Firestore
    const invalidTokens: string[] = [];
    response.responses.forEach((res, idx) => {
      if (!res.success && res.error?.code === 'messaging/registration-token-not-registered') {
        invalidTokens.push(tokens[idx]);
      }
    });

    if (invalidTokens.length > 0) {
      await db.collection('users').doc(payload.userId).update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      });
    }

    console.log(`Notification sent to user ${payload.userId} (${response.successCount}/${tokens.length} tokens)`);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

// ========================
// NOTIFICATION WRITE TRIGGER
// Fires when client code writes a notification doc directly
// (resolves the TODO in notification_repository_impl.dart)
// ========================

export const onNotificationCreated = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap) => {
    const n = snap.data();
    if (!n || n.skipPush === true) return;

    await sendPushNotification({
      userId: n.userId,
      title: n.title,
      body: n.body,
      type: n.type,
      targetId: n.targetId,
      data: n.data ?? {},
    });
  });

// ========================
// BOOKING NOTIFICATIONS
// ========================

// Notify organizer when new booking request is created
export const onBookingCreated = functions.firestore
  .document('booking_requests/{requestId}')
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
      type: 'bookingConfirmed',
      data: {
        type: 'booking_request',
        bookingId: context.params.requestId,
        eventId: booking.eventId,
      },
    });

    // Notify exhibitor: confirmation that their request was submitted
    await sendPushNotification({
      userId: booking.exhibitorId,
      title: 'Booking Request Submitted',
      body: `Your booking request for ${eventTitle} has been submitted and is awaiting approval.`,
      type: 'bookingConfirmed',
      targetId: context.params.requestId,
      data: {
        type: 'booking_request',
        bookingId: context.params.requestId,
        eventId: booking.eventId,
      },
    });
  });

// Notify exhibitor when booking status changes; also send exhibitor a submission confirmation
export const onBookingStatusChanged = functions.firestore
  .document('booking_requests/{requestId}')
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

    const bookingTypeMap: Record<string, string> = {
      approved: 'bookingConfirmed',
      confirmed: 'bookingConfirmed',
      rejected: 'bookingCancelled',
      cancelled: 'bookingCancelled',
    };

    // Notify exhibitor
    await sendPushNotification({
      userId: after.exhibitorId,
      title,
      body,
      type: bookingTypeMap[after.status] ?? 'systemAnnouncement',
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

    // Suppress notification if recipient is currently viewing this chat
    const recipientDoc = await db.collection('users').doc(recipientId).get();
    if (recipientDoc.data()?.activeChat === chatId) {
      console.log(`Suppressing new_message notification: recipient ${recipientId} is in chat ${chatId}`);
      return;
    }

    // Get sender name
    const senderName = chat.participantNames[message.senderId] || 'Someone';

    // Notify recipient
    await sendPushNotification({
      userId: recipientId,
      title: senderName,
      body: message.type === 'image' ? '📷 Sent an image' : message.text,
      type: 'newMessage',
      targetId: chatId,
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
          type: 'newEvent',
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
      const bookings = await db.collection('booking_requests')
        .where('eventId', '==', eventId)
        .where('status', 'in', ['approved', 'confirmed'])
        .get();

      // Notify exhibitors
      const notifications = bookings.docs.map((doc) =>
        sendPushNotification({
          userId: doc.data().exhibitorId,
          title: 'Event Details Updated',
          body: `${after.title} details have been updated. Please check the new information.`,
          type: 'eventUpdate',
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
  .document('jobs/{jobId}/applications/{applicationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status) return;

    // Get job details
    const jobDoc = await db.collection('jobs').doc(context.params.jobId).get();
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
      type: 'applicationAccepted',
      targetId: context.params.jobId,
      data: {
        type: 'job_application_status',
        applicationId: context.params.applicationId,
        jobId: context.params.jobId,
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

// When a user document is created: subscribe to role topic and notify admins
export const onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data();
    const { userId } = context.params;

    // Subscribe user to role-based topic (handles both single token and array)
    const tokens: string[] = [];
    if (user.fcmToken && typeof user.fcmToken === 'string') tokens.push(user.fcmToken);
    if (Array.isArray(user.fcmTokens)) {
      for (const t of user.fcmTokens) {
        if (typeof t === 'string' && !tokens.includes(t)) tokens.push(t);
      }
    }
    if (tokens.length > 0) {
      await messaging.subscribeToTopic(tokens, `role_${user.role}`);
    }

    // Notify all admins of new user registration
    const adminSnapshot = await db.collection('users').where('role', '==', 'admin').get();
    if (!adminSnapshot.empty) {
      await Promise.all(adminSnapshot.docs.map((doc) =>
        sendPushNotification({
          userId: doc.id,
          title: 'New User Registered',
          body: `${user.name || 'A new user'} (${user.role}) has joined the platform.`,
          type: 'systemAnnouncement',
          targetId: userId,
          data: { type: 'account', userId },
        })
      ));
    }
  });

// ========================
// ORDER NOTIFICATIONS
// ========================

// Notify supplier when a new order is placed
export const onOrderCreated = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const { orderId } = context.params;

    if (!order.supplierId) return;

    const customerName = order.customerName || 'A customer';
    const serviceLabel = order.serviceNames?.length
      ? order.serviceNames.join(', ')
      : (order.serviceName || 'a service');

    // Notify supplier of new order
    await sendPushNotification({
      userId: order.supplierId,
      title: 'New Order Received',
      body: `${customerName} has requested "${serviceLabel}".`,
      type: 'orderPlaced',
      targetId: orderId,
      data: { type: 'order', orderId },
    });

    // Notify customer (organizer) that their request was sent
    if (order.customerId) {
      await sendPushNotification({
        userId: order.customerId,
        title: 'Order Request Sent',
        body: `Your service request for "${serviceLabel}" has been sent to the supplier and is awaiting confirmation.`,
        type: 'orderPlaced',
        targetId: orderId,
        data: { type: 'order', orderId },
      });
    }
  });

// Notify customer when order status changes; notify supplier on payment
export const onOrderStatusChanged = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const { orderId } = context.params;

    // Order status notifications to customer (organizer)
    if (before.status !== after.status && after.customerId) {
      const serviceLabel = after.serviceNames?.length
        ? after.serviceNames.join(', ')
        : (after.serviceName || 'your service');

      const rejectionNote = after.rejectionReason ? ` Reason: ${after.rejectionReason}` : '';

      const statusMap: Record<string, { title: string; body: string; type: string }> = {
        accepted:   { title: 'Order Accepted',    body: `Your order for "${serviceLabel}" has been accepted by the supplier.`,          type: 'orderConfirmed' },
        rejected:   { title: 'Order Rejected',    body: `Your order for "${serviceLabel}" was rejected by the supplier.${rejectionNote}`, type: 'orderCancelled' },
        inProgress: { title: 'Service Started',   body: `The supplier has started working on "${serviceLabel}".`,                       type: 'orderShipped'   },
        completed:  { title: 'Service Completed', body: `Your service "${serviceLabel}" has been completed successfully.`,              type: 'orderDelivered' },
        cancelled:  { title: 'Order Cancelled',   body: `Your order for "${serviceLabel}" has been cancelled.`,                         type: 'orderCancelled' },
      };

      const msg = statusMap[after.status];
      if (msg) {
        await sendPushNotification({
          userId: after.customerId,
          ...msg,
          targetId: orderId,
          data: { type: 'order', orderId, status: after.status },
        });
      }
    }
  });

// ========================
// ACCOUNT NOTIFICATIONS
// ========================

// Notify user when their account request is approved or rejected
export const onAccountApprovalStatusChanged = functions.firestore
  .document('account_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status || !after.userId) return;

    if (after.status === 'approved') {
      await sendPushNotification({
        userId: after.userId,
        title: 'Account Approved!',
        body: 'Your account has been approved. You can now access all features.',
        type: 'accountVerified',
        targetId: context.params.requestId,
        data: { type: 'account_approval', status: 'approved' },
      });
    } else if (after.status === 'rejected') {
      await sendPushNotification({
        userId: after.userId,
        title: 'Account Request Rejected',
        body: `Your request was not approved.${after.rejectionReason ? ` Reason: ${after.rejectionReason}` : ''}`,
        type: 'systemAnnouncement',
        targetId: context.params.requestId,
        data: { type: 'account_approval', status: 'rejected' },
      });
    }
  });

// ========================
// JOB APPLICATION CREATED NOTIFICATION
// ========================

// Notify organizer when a new job application is submitted
export const onJobApplicationCreated = functions.firestore
  .document('jobs/{jobId}/applications/{applicationId}')
  .onCreate(async (snap, context) => {
    const application = snap.data();
    const { jobId, applicationId } = context.params;

    const [jobDoc, applicantDoc] = await Promise.all([
      db.collection('jobs').doc(jobId).get(),
      db.collection('users').doc(application.userId).get(),
    ]);

    const job = jobDoc.data();
    if (!job || !job.organizerId) return;

    const applicantName = applicantDoc.data()?.name || 'Someone';

    await sendPushNotification({
      userId: job.organizerId,
      title: 'New Job Application',
      body: `${applicantName} applied for "${job.title || 'your job posting'}".`,
      type: 'applicationReceived',
      targetId: jobId,
      data: { type: 'job_application', jobId, applicationId },
    });
  });

// ========================
// CUSTOM CLAIMS — ROLE SYNC
// ========================
//
// Keeps Firebase Auth custom claims in sync with the Firestore user document.
// Benefits:
//   • Role is available in request.auth.token.role inside Firestore rules
//     without an extra Firestore read — faster, cheaper, more reliable.
//   • isActive is embedded so deactivated users are blocked at the token level.
//
// Usage in firestore.rules:
//   function hasRole(role) {
//     return request.auth.token.role == role;
//   }
//   function isActiveUser() {
//     return request.auth.token.isActive == true;
//   }

export const setRoleClaimsOnUserWrite = functions.firestore
  .document('users/{userId}')
  .onWrite(async (change, context) => {
    const { userId } = context.params;

    // Document deleted — revoke claims
    if (!change.after.exists) {
      try {
        await admin.auth().setCustomUserClaims(userId, {});
      } catch (err) {
        // User may not exist in Auth (pre-created temp doc) — that's fine
        console.log(`Could not clear claims for ${userId}:`, err);
      }
      return null;
    }

    const data = change.after.data()!;
    const role: string = data.role ?? 'visitor';
    const isActive: boolean = data.isActive ?? true;

    // Only update claims when role or isActive actually changed
    const before = change.before.exists ? change.before.data()! : {};
    if (before.role === role && before.isActive === isActive) return null;

    try {
      await admin.auth().setCustomUserClaims(userId, { role, isActive });
      console.log(`Custom claims set for ${userId}: role=${role}, isActive=${isActive}`);
    } catch (err) {
      // The Firestore doc may have a temp UUID that doesn't exist in Firebase Auth yet.
      // This is expected for admin-pre-created accounts before first login — ignore silently.
      console.log(`Could not set claims for ${userId} (may be pre-auth temp doc):`, err);
    }

    return null;
  });

// ========================
// ANALYTICS & AGGREGATIONS
// ========================

// ========================
// REVIEW NOTIFICATIONS
// ========================

export const onReviewCreated = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    if (!review) return null;

    // Only notify supplier when reviewed
    if (review.type !== 'supplier') return null;

    try {
      const supplierDoc = await db.collection('suppliers').doc(review.targetId).get();
      const supplierData = supplierDoc.data();
      if (!supplierData?.userId) return null;

      await sendPushNotification({
        userId: supplierData.userId,
        title: 'تقييم جديد ⭐',
        body: `${review.reviewerName ?? 'مستخدم'} قيّمك بـ ${review.rating} نجوم`,
        type: 'newReview',
        targetId: review.targetId,
        data: {
          reviewId: context.params.reviewId,
          screen: 'supplier_reviews',
        },
      });
    } catch (err) {
      console.error('Error in onReviewCreated:', err);
    }

    return null;
  });

// ========================
// BUSINESS REQUEST NOTIFICATIONS
// ========================

// Notify supplier when admin approves or rejects their business request
export const onBusinessRequestStatusChanged = functions.firestore
  .document('business_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.status === after.status || !after.supplierId) return;

    if (after.status === 'approved') {
      await sendPushNotification({
        userId: after.supplierId,
        title: 'Business Request Approved!',
        body: 'Your business request has been approved. You can now access all business features.',
        type: 'accountVerified',
        targetId: context.params.requestId,
        data: { type: 'business_request', status: 'approved' },
      });
    } else if (after.status === 'rejected') {
      const rejectionNote = after.rejectionReason ? ` Reason: ${after.rejectionReason}` : '';
      await sendPushNotification({
        userId: after.supplierId,
        title: 'Business Request Rejected',
        body: `Your business request was not approved.${rejectionNote}`,
        type: 'systemAnnouncement',
        targetId: context.params.requestId,
        data: { type: 'business_request', status: 'rejected' },
      });
    }
  });

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
