import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/providers/repository_providers.dart';

class AdminBookingsState {
  final List<BookingRequest> bookings;
  final bool isLoading;
  final String? errorMessage;
  final BookingStatus? statusFilter;

  const AdminBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
  });

  AdminBookingsState copyWith({
    List<BookingRequest>? bookings,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    BookingStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AdminBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class AdminBookingsNotifier extends Notifier<AdminBookingsState> {
  @override
  AdminBookingsState build() {
    Future.microtask(() => _loadBookings());
    return const AdminBookingsState(isLoading: true);
  }

  Future<void> _loadBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(bookingRepositoryProvider)
        .getAllBookings(status: state.statusFilter);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (bookings) => state = state.copyWith(
        isLoading: false,
        bookings: bookings,
      ),
    );
  }

  Future<void> filterByStatus(BookingStatus? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    await _loadBookings();
  }

  Future<void> refresh() => _loadBookings();
}

final adminBookingsProvider =
    NotifierProvider<AdminBookingsNotifier, AdminBookingsState>(
  AdminBookingsNotifier.new,
);
