import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/providers/repository_providers.dart';

class AdminEventsState {
  final List<EventModel> events;
  final bool isLoading;
  final String? errorMessage;
  final EventStatus? statusFilter;

  const AdminEventsState({
    this.events = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
  });

  AdminEventsState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    EventStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AdminEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class AdminEventsNotifier extends Notifier<AdminEventsState> {
  @override
  AdminEventsState build() {
    Future.microtask(() => _loadEvents());
    return const AdminEventsState(isLoading: true);
  }

  Future<void> _loadEvents() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(eventRepositoryProvider)
        .getAllEvents(status: state.statusFilter);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (events) => state = state.copyWith(
        isLoading: false,
        events: events,
      ),
    );
  }

  Future<void> filterByStatus(EventStatus? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    await _loadEvents();
  }

  Future<void> refresh() => _loadEvents();
}

final adminEventsProvider =
    NotifierProvider<AdminEventsNotifier, AdminEventsState>(
  AdminEventsNotifier.new,
);
