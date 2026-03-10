# Exhibition & Supplier Booking Platform - Architecture Documentation

## 📋 Overview

A production-ready Flutter application for managing exhibitions, booths, suppliers, and bookings with strict role-based access control.

## 🏛️ Clean Architecture Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── constants/                 # App constants, API endpoints, keys
│   ├── exceptions/                # Custom exceptions and failure classes
│   ├── extensions/                # Dart extensions
│   ├── services/                  # Core services (Firebase, notifications)
│   ├── theme/                     # App theme, colors, typography
│   ├── utils/                     # Utility functions, validators
│   └── widgets/                   # Shared widgets (buttons, inputs, etc.)
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication (Phone OTP)
│   ├── admin/                     # Admin dashboard (create organizers/suppliers)
│   ├── events/                    # Events management
│   ├── booths/                    # Booth management within events
│   ├── bookings/                  # Booking requests flow
│   ├── chat/                      # Real-time messaging
│   ├── suppliers/                 # Suppliers module
│   ├── jobs/                      # Event jobs and applications
│   └── profile/                   # User profile management
│
├── shared/                        # Shared across features
│   ├── models/                    # Shared data models
│   ├── providers/                 # Shared providers
│   └── widgets/                   # Feature-agnostic widgets
│
├── router/                        # GoRouter configuration
│   ├── app_router.dart
│   ├── route_guards.dart
│   └── routes.dart
│
└── main.dart                      # App entry point
```

## 👥 User Roles & Permissions

| Role | Permissions |
|------|-------------|
| **Admin** | Create organizers/suppliers, manage all users, view all data, system settings |
| **Organizer** | Create/manage own events, manage booths, approve/reject bookings for own events |
| **Supplier** | Manage own supplier profile, view events, apply for jobs |
| **Exhibitor** | Browse events, book booths, chat with organizers, apply for jobs |

## 🔐 Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Authentication Flow                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐ │
│  │   Splash    │───>│   Phone     │───>│   OTP Input     │ │
│  │   Screen    │    │   Input     │    │   Screen        │ │
│  └─────────────┘    └─────────────┘    └─────────────────┘ │
│         │                                      │            │
│         │ (Auto-login)                         │            │
│         ▼                                      ▼            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Role-Based Routing                      │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Admin ────> Admin Dashboard                         │   │
│  │  Organizer ──> Organizer Dashboard                   │   │
│  │  Supplier ───> Supplier Dashboard                    │   │
│  │  Exhibitor ──> Exhibitor Home                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📊 Firestore Data Model

### Collections Structure

```
firestore/
├── users/{uid}
│   ├── name: string
│   ├── phone: string
│   ├── role: 'admin' | 'organizer' | 'supplier' | 'exhibitor'
│   ├── profileImage: string?
│   ├── createdAt: timestamp
│   ├── createdBy: string (uid of admin who created, or 'self' for exhibitors)
│   └── isActive: boolean
│
├── events/{eventId}
│   ├── title: string
│   ├── description: string
│   ├── location: string
│   ├── address: string
│   ├── startDate: timestamp
│   ├── endDate: timestamp
│   ├── tags: string[]
│   ├── images: string[]
│   ├── interestedCount: number
│   ├── organizerId: string
│   ├── status: 'draft' | 'published' | 'cancelled' | 'completed'
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│   │
│   └── booths/{boothId}
│       ├── boothNumber: string
│       ├── size: 'small' | 'medium' | 'large' | 'premium'
│       ├── category: string
│       ├── price: number
│       ├── status: 'available' | 'reserved' | 'booked' | 'occupied'
│       ├── reservedBy: string?
│       ├── reservedAt: timestamp?
│       ├── amenities: string[]
│       └── position: { x: number, y: number }
│
├── bookingRequests/{requestId}
│   ├── eventId: string
│   ├── boothId: string
│   ├── exhibitorId: string
│   ├── organizerId: string
│   ├── status: 'pending' | 'approved' | 'rejected' | 'confirmed' | 'cancelled'
│   ├── message: string?
│   ├── rejectionReason: string?
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── chats/{chatId}
│   ├── participants: string[] (uids)
│   ├── participantNames: map<uid, name>
│   ├── lastMessage: string
│   ├── lastMessageAt: timestamp
│   ├── lastMessageBy: string
│   ├── unreadCount: map<uid, number>
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│   │
│   └── messages/{messageId}
│       ├── senderId: string
│       ├── text: string
│       ├── type: 'text' | 'image' | 'file'
│       ├── mediaUrl: string?
│       ├── createdAt: timestamp
│       ├── readBy: string[]
│       └── readAt: map<uid, timestamp>
│
├── suppliers/{supplierId}
│   ├── name: string
│   ├── description: string
│   ├── services: string[]
│   ├── category: string
│   ├── images: string[]
│   ├── ownerId: string
│   ├── contactEmail: string
│   ├── contactPhone: string
│   ├── rating: number
│   ├── reviewCount: number
│   ├── createdByAdmin: string
│   ├── isActive: boolean
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── eventJobs/{jobId}
│   ├── eventId: string
│   ├── organizerId: string
│   ├── title: string
│   ├── description: string
│   ├── requirements: string[]
│   ├── salary: string?
│   ├── deadline: timestamp
│   ├── applicationsCount: number
│   ├── status: 'open' | 'closed'
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
├── jobApplications/{applicationId}
│   ├── jobId: string
│   ├── eventId: string
│   ├── userId: string
│   ├── coverLetter: string?
│   ├── resumeUrl: string?
│   ├── status: 'pending' | 'reviewed' | 'accepted' | 'rejected'
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
│
└── interests/{interestId}
    ├── userId: string
    ├── eventId: string
    └── createdAt: timestamp
```

## 🔄 State Management with Riverpod 2.x

### Provider Types Used

```dart
// For simple synchronous state
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() => ThemeNotifier());

// For async operations (API calls, Firestore)
final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<Event>>(() => EventsNotifier());

// For streams (real-time data)
final chatMessagesProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
});

// For filtered/derived state
final filteredEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventsProvider).valueOrNull ?? [];
  final filter = ref.watch(eventFilterProvider);
  return events.where((e) => filter.matches(e)).toList();
});
```

### AsyncValue Handling Pattern

```dart
ref.watch(eventsProvider).when(
  data: (events) => EventsList(events: events),
  loading: () => const LoadingIndicator(),
  error: (error, stack) => ErrorWidget(error: error, onRetry: () => ref.invalidate(eventsProvider)),
);
```

## 🛡️ Security Architecture

### Firestore Security Rules Summary

1. **Users Collection**:
   - Admin can read/write all
   - Users can read/update own profile only
   - Only admin can set roles for organizer/supplier

2. **Events Collection**:
   - Anyone authenticated can read published events
   - Only organizers can create events
   - Organizers can only update/delete their own events

3. **Booths Subcollection**:
   - Anyone authenticated can read
   - Only event organizer can create/update/delete

4. **Booking Requests**:
   - Exhibitors can create and read own requests
   - Organizers can read/update requests for their events
   - Only organizer can approve/reject

5. **Chats & Messages**:
   - Only participants can read/write
   - Messages inherit chat permissions

6. **Suppliers**:
   - Anyone can read active suppliers
   - Only owner can update own supplier profile
   - Only admin can create suppliers

## 🚀 Performance Optimization Strategy

### 1. Pagination
- Cursor-based pagination for all lists
- Page size: 20 items default
- Infinite scroll with `ScrollController`

### 2. Caching
- Riverpod's built-in caching
- `keepAlive` for critical providers
- Firebase offline persistence enabled

### 3. Optimized Rebuilds
- Use `select()` for fine-grained subscriptions
- `ref.watch(provider.select((state) => state.specificField))`
- Separate providers for different UI sections

### 4. Image Optimization
- Lazy loading with `cached_network_image`
- Firebase Storage thumbnails
- WebP format for smaller sizes

### 5. Query Optimization
- Composite indexes for complex queries
- Limit fields with `select` in queries
- Denormalization for read-heavy data

## 📈 Scaling Plan for 10,000+ Users

### Database
- Sharding strategy for hot collections
- Composite indexes for complex queries
- Cloud Functions for aggregations

### Real-time Features
- Limit real-time listeners scope
- Use Cloud Functions for fan-out operations
- Implement presence system efficiently

### Storage
- CDN for static assets
- Image compression pipeline
- Cleanup unused files periodically

### Monitoring
- Firebase Performance Monitoring
- Crashlytics for error tracking
- Custom analytics events

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10

  # Routing
  go_router: ^13.0.1

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # UI
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Utils
  intl: ^0.19.0
  intl_phone_field: ^3.2.0
  uuid: ^4.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
```
