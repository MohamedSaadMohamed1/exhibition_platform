import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/event_repository.dart';

/// Events state
class EventsState {
  final List<EventModel> events;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final EventFilter filter;

  const EventsState({
    this.events = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const EventFilter(),
  });

  EventsState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    EventFilter? filter,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Events Notifier
class EventsNotifier extends Notifier<EventsState> {
  late final EventRepository _eventRepository;

  @override
  EventsState build() {
    _eventRepository = ref.watch(eventRepositoryProvider);
    Future.microtask(() => _loadEvents());
    return const EventsState(isLoading: true);
  }

  /// Load events
  Future<void> _loadEvents({bool refresh = false}) async {
    if (state.isLoading && state.events.isNotEmpty && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      events: refresh ? [] : state.events,
    );

    final result = await _eventRepository.getEvents(
      filter: state.filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (events) {
        state = state.copyWith(
          events: events,
          isLoading: false,
          hasMore: events.length >= 20,
        );
      },
    );
  }

  /// Load more events (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastEventId = state.events.isNotEmpty ? state.events.last.id : null;

    state = state.copyWith(isLoading: true);

    final result = await _eventRepository.getEvents(
      lastEventId: lastEventId,
      filter: state.filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (events) {
        state = state.copyWith(
          events: [...state.events, ...events],
          isLoading: false,
          hasMore: events.length >= 20,
        );
      },
    );
  }

  /// Refresh events
  Future<void> refresh() async {
    await _loadEvents(refresh: true);
  }

  /// Apply filter
  void applyFilter(EventFilter filter) {
    state = state.copyWith(filter: filter);
    _loadEvents(refresh: true);
  }

  /// Clear filter
  void clearFilter() {
    state = state.copyWith(filter: const EventFilter());
    _loadEvents(refresh: true);
  }
}

/// Events Notifier Provider
final eventsNotifierProvider = NotifierProvider<EventsNotifier, EventsState>(() {
  return EventsNotifier();
});

/// Event detail provider
final eventDetailProvider = FutureProvider.family<EventModel?, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  final result = await repository.getEventById(eventId);
  return result.fold((l) => null, (r) => r);
});

/// Event stream provider
final eventStreamProvider = StreamProvider.family<EventModel, String>((ref, eventId) {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchEvent(eventId);
});

/// Organizer events provider
final organizerEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, organizerId) async {
  final repository = ref.watch(eventRepositoryProvider);
  final result = await repository.getEventsByOrganizer(organizerId);
  return result.fold((l) => [], (r) => r);
});

/// Upcoming events provider
final upcomingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  final result = await repository.getUpcomingEvents(limit: 5);
  return result.fold((l) => [], (r) => r);
});

/// Event categories provider
final eventCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  final result = await repository.getEventCategories();
  return result.fold((l) => [], (r) => r);
});

/// Is user interested provider
final isUserInterestedProvider = FutureProvider.family<bool, ({String eventId, String userId})>((ref, params) async {
  final repository = ref.watch(eventRepositoryProvider);
  final result = await repository.isUserInterested(
    eventId: params.eventId,
    userId: params.userId,
  );
  return result.fold((l) => false, (r) => r);
});
