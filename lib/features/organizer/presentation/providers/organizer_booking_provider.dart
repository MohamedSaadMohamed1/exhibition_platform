import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../features/bookings/domain/repositories/booking_repository.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/providers/providers.dart';

/// Organizer booking requests state
class OrganizerBookingState {
  final List<BookingRequest> bookings;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final BookingStatus? statusFilter;
  final String? eventFilter;
  final BookingStats? stats;

  // Action states
  final bool isApproving;
  final bool isRejecting;
  final String? actionError;

  const OrganizerBookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.statusFilter,
    this.eventFilter,
    this.stats,
    this.isApproving = false,
    this.isRejecting = false,
    this.actionError,
  });

  OrganizerBookingState copyWith({
    List<BookingRequest>? bookings,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    BookingStatus? statusFilter,
    String? eventFilter,
    BookingStats? stats,
    bool? isApproving,
    bool? isRejecting,
    String? actionError,
    bool clearErrorMessage = false,
    bool clearActionError = false,
    bool clearStatusFilter = false,
    bool clearEventFilter = false,
  }) {
    return OrganizerBookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      eventFilter: clearEventFilter ? null : (eventFilter ?? this.eventFilter),
      stats: stats ?? this.stats,
      isApproving: isApproving ?? this.isApproving,
      isRejecting: isRejecting ?? this.isRejecting,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  int get pendingCount =>
      bookings.where((b) => b.isPending).length;

  int get approvedCount =>
      bookings.where((b) => b.isApproved).length;

  int get rejectedCount =>
      bookings.where((b) => b.isRejected).length;
}

/// Organizer booking requests notifier
class OrganizerBookingNotifier extends FamilyNotifier<OrganizerBookingState, String> {
  late final BookingRepository _bookingRepository;

  @override
  OrganizerBookingState build(String organizerId) {
    _bookingRepository = ref.watch(bookingRepositoryProvider);
    _loadBookings(organizerId);
    _loadStats(organizerId);
    return const OrganizerBookingState(isLoading: true);
  }

  Future<void> _loadBookings(String organizerId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      bookings: refresh ? [] : state.bookings,
      clearErrorMessage: true,
    );

    try {
      final result = await _bookingRepository.getOrganizerBookings(
        organizerId,
        status: state.statusFilter,
        eventId: state.eventFilter,
      );

      result.fold(
        (failure) {
          // Log error for debugging
          print('❌ Booking fetch error: ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          );
        },
        (bookings) {
          // Log success for debugging
          print('✅ Fetched ${bookings.length} bookings for organizer: $organizerId');
          state = state.copyWith(
            bookings: bookings,
            isLoading: false,
            hasMore: bookings.length >= 20,
          );
        },
      );
    } catch (e) {
      // Catch any unexpected errors
      print('❌ Unexpected error in _loadBookings: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load bookings: $e',
        isLoading: false,
      );
    }
  }

  Future<void> _loadStats(String organizerId) async {
    final result = await _bookingRepository.getBookingStats(organizerId);
    result.fold(
      (failure) {
        // Stats loading failure is non-critical
      },
      (stats) {
        state = state.copyWith(stats: stats);
      },
    );
  }

  Future<void> refresh() async {
    await _loadBookings(arg, refresh: true);
    await _loadStats(arg);
  }

  Future<void> refreshStats() async {
    await _loadStats(arg);
  }

  void filterByStatus(BookingStatus? status) {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    _loadBookings(arg, refresh: true);
  }

  void filterByEvent(String? eventId) {
    state = state.copyWith(
      eventFilter: eventId,
      clearEventFilter: eventId == null,
    );
    _loadBookings(arg, refresh: true);
  }

  void clearFilters() {
    state = state.copyWith(
      clearStatusFilter: true,
      clearEventFilter: true,
    );
    _loadBookings(arg, refresh: true);
  }

  /// Approve a booking request
  Future<bool> approveBooking(String bookingId) async {
    state = state.copyWith(
      isApproving: true,
      actionError: null,
      clearActionError: true,
    );

    final result = await _bookingRepository.approveBooking(bookingId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isApproving: false,
          actionError: failure.message,
        );
        return false;
      },
      (booking) {
        state = state.copyWith(isApproving: false, clearActionError: true);
        // Optimistically update the booking in the list
        final updatedBookings = state.bookings.map((b) {
          return b.id == bookingId ? booking : b;
        }).toList();
        state = state.copyWith(bookings: updatedBookings);
        refreshStats();
        return true;
      },
    );
  }

  /// Reject a booking request
  Future<bool> rejectBooking(String bookingId, {String? reason}) async {
    state = state.copyWith(
      isRejecting: true,
      actionError: null,
      clearActionError: true,
    );

    final result = await _bookingRepository.rejectBooking(
      bookingId,
      reason: reason,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRejecting: false,
          actionError: failure.message,
        );
        return false;
      },
      (booking) {
        state = state.copyWith(isRejecting: false, clearActionError: true);
        // Optimistically update the booking in the list
        final updatedBookings = state.bookings.map((b) {
          return b.id == bookingId ? booking : b;
        }).toList();
        state = state.copyWith(bookings: updatedBookings);
        refreshStats();
        return true;
      },
    );
  }

  /// Confirm a booking (after payment)
  Future<bool> confirmBooking(String bookingId) async {
    final result = await _bookingRepository.confirmBooking(bookingId);

    return result.fold(
      (failure) {
        state = state.copyWith(actionError: failure.message);
        return false;
      },
      (booking) {
        // Optimistically update the booking in the list
        final updatedBookings = state.bookings.map((b) {
          return b.id == bookingId ? booking : b;
        }).toList();
        state = state.copyWith(bookings: updatedBookings, clearActionError: true);
        refreshStats();
        return true;
      },
    );
  }
}

/// Organizer booking requests provider
final organizerBookingProvider =
    NotifierProvider.family<OrganizerBookingNotifier, OrganizerBookingState, String>(() {
  return OrganizerBookingNotifier();
});

/// Organizer booking requests stream provider for real-time updates
final organizerBookingStreamProvider =
    StreamProvider.family<List<BookingRequest>, String>((ref, organizerId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.watchOrganizerBookings(organizerId);
});

/// Booking stats provider
final bookingStatsProvider = FutureProvider.family<BookingStats?, String>((ref, organizerId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final result = await repository.getBookingStats(organizerId);
  return result.fold((l) => null, (r) => r);
});
