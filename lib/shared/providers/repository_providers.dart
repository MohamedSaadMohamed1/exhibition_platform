import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/booths/data/repositories/booth_repository_impl.dart';
import '../../features/booths/domain/repositories/booth_repository.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/suppliers/data/repositories/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/jobs/data/repositories/job_repository_impl.dart';
import '../../features/jobs/domain/repositories/job_repository.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import 'firebase_providers.dart';

// ==================== Repository Providers ====================

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

/// Admin Repository Provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Event Repository Provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Booth Repository Provider
final boothRepositoryProvider = Provider<BoothRepository>((ref) {
  return BoothRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Booking Repository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Supplier Repository Provider
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Service Repository Provider
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Order Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Job Repository Provider
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Review Repository Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});

/// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
  );
});
