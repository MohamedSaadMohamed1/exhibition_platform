"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onInterestChange = exports.onUserCreated = exports.cleanupExpiredReservations = exports.onJobApplicationStatusChanged = exports.onEventUpdated = exports.onNewMessage = exports.onBookingStatusChanged = exports.onBookingCreated = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();
async function sendPushNotification(payload) {
    try {
        // Get user's FCM tokens (support both single token and array)
        const userDoc = await db.collection('users').doc(payload.userId).get();
        const userData = userDoc.data();
        if (!userData) {
            console.log(`User ${payload.userId} not found`);
            return;
        }
        // Collect all valid tokens
        const tokens = [];
        if (userData.fcmToken && typeof userData.fcmToken === 'string') {
            tokens.push(userData.fcmToken);
        }
        if (Array.isArray(userData.fcmTokens)) {
            for (const t of userData.fcmTokens) {
                if (typeof t === 'string' && !tokens.includes(t))
                    tokens.push(t);
            }
        }
        if (tokens.length === 0) {
            console.log(`No FCM tokens for user ${payload.userId}`);
            return;
        }
        const messageBase = {
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data,
            android: {
                priority: 'high',
                notification: {
                    channelId: 'high_importance_channel',
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
        };
        // Send to all tokens, remove invalid ones
        const response = await messaging.sendEachForMulticast(Object.assign({ tokens }, messageBase));
        // Remove invalid tokens from Firestore
        const invalidTokens = [];
        response.responses.forEach((res, idx) => {
            var _a;
            if (!res.success && ((_a = res.error) === null || _a === void 0 ? void 0 : _a.code) === 'messaging/registration-token-not-registered') {
                invalidTokens.push(tokens[idx]);
            }
        });
        if (invalidTokens.length > 0) {
            await db.collection('users').doc(payload.userId).update({
                fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
            });
        }
        // Store notification in Firestore
        await db.collection('notifications').add({
            userId: payload.userId,
            title: payload.title,
            body: payload.body,
            data: payload.data || {},
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Notification sent to user ${payload.userId} (${response.successCount}/${tokens.length} tokens)`);
    }
    catch (error) {
        console.error('Error sending notification:', error);
    }
}
// ========================
// BOOKING NOTIFICATIONS
// ========================
// Notify organizer when new booking request is created
exports.onBookingCreated = functions.firestore
    .document('bookingRequests/{requestId}')
    .onCreate(async (snap, context) => {
    var _a, _b;
    const booking = snap.data();
    // Get exhibitor name
    const exhibitorDoc = await db.collection('users').doc(booking.exhibitorId).get();
    const exhibitorName = ((_a = exhibitorDoc.data()) === null || _a === void 0 ? void 0 : _a.name) || 'A user';
    // Get event title
    const eventDoc = await db.collection('events').doc(booking.eventId).get();
    const eventTitle = ((_b = eventDoc.data()) === null || _b === void 0 ? void 0 : _b.title) || 'an event';
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
exports.onBookingStatusChanged = functions.firestore
    .document('bookingRequests/{requestId}')
    .onUpdate(async (change, context) => {
    var _a;
    const before = change.before.data();
    const after = change.after.data();
    // Check if status changed
    if (before.status === after.status) {
        return;
    }
    // Get event title
    const eventDoc = await db.collection('events').doc(after.eventId).get();
    const eventTitle = ((_a = eventDoc.data()) === null || _a === void 0 ? void 0 : _a.title) || 'your event';
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
exports.onNewMessage = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
    const message = snap.data();
    const { chatId } = context.params;
    // Get chat to find recipient
    const chatDoc = await db.collection('chats').doc(chatId).get();
    const chat = chatDoc.data();
    if (!chat)
        return;
    // Find recipient (other participant)
    const recipientId = chat.participants.find((id) => id !== message.senderId);
    if (!recipientId)
        return;
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
exports.onEventUpdated = functions.firestore
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
        const notifications = interests.docs.map((doc) => sendPushNotification({
            userId: doc.data().userId,
            title: 'Event Published!',
            body: `${after.title} is now live. Check it out!`,
            data: {
                type: 'event_published',
                eventId,
            },
        }));
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
        const notifications = bookings.docs.map((doc) => sendPushNotification({
            userId: doc.data().exhibitorId,
            title: 'Event Details Updated',
            body: `${after.title} details have been updated. Please check the new information.`,
            data: {
                type: 'event_updated',
                eventId,
            },
        }));
        await Promise.all(notifications);
    }
});
// ========================
// JOB NOTIFICATIONS
// ========================
// Notify when job application status changes
exports.onJobApplicationStatusChanged = functions.firestore
    .document('jobApplications/{applicationId}')
    .onUpdate(async (change, context) => {
    var _a;
    const before = change.before.data();
    const after = change.after.data();
    if (before.status === after.status)
        return;
    // Get job details
    const jobDoc = await db.collection('eventJobs').doc(after.jobId).get();
    const jobTitle = ((_a = jobDoc.data()) === null || _a === void 0 ? void 0 : _a.title) || 'a job';
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
exports.cleanupExpiredReservations = functions.pubsub
    .schedule('every 5 minutes')
    .onRun(async () => {
    const fifteenMinutesAgo = admin.firestore.Timestamp.fromDate(new Date(Date.now() - 15 * 60 * 1000));
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
exports.onUserCreated = functions.firestore
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
exports.onInterestChange = functions.firestore
    .document('interests/{interestId}')
    .onWrite(async (change, context) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;
    // Determine the event ID and increment value
    const eventId = (after === null || after === void 0 ? void 0 : after.eventId) || (before === null || before === void 0 ? void 0 : before.eventId);
    const increment = after && !before ? 1 : (!after && before ? -1 : 0);
    if (eventId && increment !== 0) {
        await db.collection('events').doc(eventId).update({
            interestedCount: admin.firestore.FieldValue.increment(increment),
        });
    }
});
//# sourceMappingURL=index.js.map