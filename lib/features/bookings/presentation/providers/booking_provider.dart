import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/booking_repository.dart';

/// Bookings state
class BookingsState {
  final List<BookingRequest> bookings;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final BookingStatus? statusFilter;

  const BookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.statusFilter,
  });

  BookingsState copyWith({
    List<BookingRequest>? bookings,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    BookingStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

/// Exhibitor bookings notifier
class ExhibitorBookingsNotifier extends FamilyNotifier<BookingsState, String> {
  late BookingRepository _bookingRepository;

  @override
  BookingsState build(String exhibitorId) {
    _bookingRepository = ref.watch(bookingRepositoryProvider);
    _loadBookings(exhibitorId);
    return const BookingsState(isLoading: true);
  }

  Future<void> _loadBookings(String exhibitorId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      bookings: refresh ? [] : state.bookings,
    );

    final result = await _bookingRepository.getExhibitorBookings(
      exhibitorId,
      status: state.statusFilter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (bookings) {
        state = state.copyWith(
          bookings: bookings,
          isLoading: false,
          hasMore: bookings.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadBookings(arg, refresh: true);
  }

  void filterByStatus(BookingStatus? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    _loadBookings(arg, refresh: true);
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final result = await _bookingRepository.cancelBooking(
      bookingId,
      cancelledBy: arg,
      reason: reason,
    );

    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }
}

/// Exhibitor bookings provider
final exhibitorBookingsProvider =
    NotifierProvider.family<ExhibitorBookingsNotifier, BookingsState, String>(() {
  return ExhibitorBookingsNotifier();
});

/// Organizer bookings notifier
class OrganizerBookingsNotifier extends FamilyNotifier<BookingsState, String> {
  late BookingRepository _bookingRepository;

  @override
  BookingsState build(String organizerId) {
    _bookingRepository = ref.watch(bookingRepositoryProvider);
    _loadBookings(organizerId);
    return const BookingsState(isLoading: true);
  }

  Future<void> _loadBookings(String organizerId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      bookings: refresh ? [] : state.bookings,
    );

    final result = await _bookingRepository.getOrganizerBookings(
      organizerId,
      status: state.statusFilter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (bookings) {
        state = state.copyWith(
          bookings: bookings,
          isLoading: false,
          hasMore: bookings.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadBookings(arg, refresh: true);
  }

  void filterByStatus(BookingStatus? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    _loadBookings(arg, refresh: true);
  }

  Future<bool> approveBooking(String bookingId) async {
    final result = await _bookingRepository.approveBooking(bookingId);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }

  Future<bool> rejectBooking(String bookingId, {String? reason}) async {
    final result = await _bookingRepository.rejectBooking(bookingId, reason: reason);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }

  Future<bool> confirmBooking(String bookingId) async {
    final result = await _bookingRepository.confirmBooking(bookingId);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }
}

/// Organizer bookings provider
final organizerBookingsProvider =
    NotifierProvider.family<OrganizerBookingsNotifier, BookingsState, String>(() {
  return OrganizerBookingsNotifier();
});

/// Single booking provider
final bookingProvider =
    FutureProvider.family<BookingRequest?, String>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBookingById(bookingId);
  return result.fold((l) => null, (r) => r);
});

/// Exhibitor bookings stream provider
final exhibitorBookingsStreamProvider =
    StreamProvider.family<List<BookingRequest>, String>((ref, exhibitorId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.watchExhibitorBookings(exhibitorId);
});

/// Organizer bookings stream provider
final organizerBookingsStreamProvider =
    StreamProvider.family<List<BookingRequest>, String>((ref, organizerId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.watchOrganizerBookings(organizerId);
});

/// Booking stats provider
final bookingStatsProvider =
    FutureProvider.family<BookingStats, String>((ref, organizerId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBookingStats(organizerId);
  return result.fold(
    (l) => const BookingStats(),
    (r) => r,
  );
});

/// Event bookings provider
final eventBookingsProvider =
    FutureProvider.family<List<BookingRequest>, String>((ref, eventId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getEventBookings(eventId);
  return result.fold((l) => [], (r) => r);
});

/// Check existing booking provider
final hasExistingBookingProvider =
    FutureProvider.family<bool, ({String exhibitorId, String boothId})>((ref, params) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.hasExistingBooking(
    exhibitorId: params.exhibitorId,
    boothId: params.boothId,
  );
  return result.fold((l) => false, (r) => r);
});
