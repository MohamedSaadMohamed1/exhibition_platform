import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/booth_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/booth_repository.dart';

/// Booths state
class BoothsState {
  final List<BoothModel> booths;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final BoothFilter filter;

  const BoothsState({
    this.booths = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const BoothFilter(),
  });

  BoothsState copyWith({
    List<BoothModel>? booths,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    BoothFilter? filter,
  }) {
    return BoothsState(
      booths: booths ?? this.booths,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Event booths notifier
class EventBoothsNotifier extends FamilyNotifier<BoothsState, String> {
  late final BoothRepository _boothRepository;

  @override
  BoothsState build(String eventId) {
    _boothRepository = ref.watch(boothRepositoryProvider);
    _loadBooths(eventId);
    return const BoothsState(isLoading: true);
  }

  Future<void> _loadBooths(String eventId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      booths: refresh ? [] : state.booths,
    );

    final result = await _boothRepository.getBoothsByEvent(
      eventId,
      filter: state.filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (booths) {
        state = state.copyWith(
          booths: booths,
          isLoading: false,
          hasMore: booths.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadBooths(arg, refresh: true);
  }

  void applyFilter(BoothFilter filter) {
    state = state.copyWith(filter: filter);
    _loadBooths(arg, refresh: true);
  }

  void clearFilter() {
    state = state.copyWith(filter: const BoothFilter());
    _loadBooths(arg, refresh: true);
  }
}

/// Event booths provider
final eventBoothsProvider =
    NotifierProvider.family<EventBoothsNotifier, BoothsState, String>(() {
  return EventBoothsNotifier();
});

/// Single booth provider - requires (eventId, boothId) tuple
final boothProvider = FutureProvider.family<BoothModel?, ({String eventId, String boothId})>((ref, params) async {
  final repository = ref.watch(boothRepositoryProvider);
  final result = await repository.getBoothById(params.eventId, params.boothId);
  return result.fold((l) => null, (r) => r);
});

/// Booth stream provider - requires (eventId, boothId) tuple
final boothStreamProvider = StreamProvider.family<BoothModel, ({String eventId, String boothId})>((ref, params) {
  final repository = ref.watch(boothRepositoryProvider);
  return repository.watchBooth(params.eventId, params.boothId);
});

/// Event booths stream provider
final eventBoothsStreamProvider =
    StreamProvider.family<List<BoothModel>, String>((ref, eventId) {
  final repository = ref.watch(boothRepositoryProvider);
  return repository.watchBooths(eventId);
});

/// Available booths provider - gets booths filtered by available status
final availableBoothsProvider =
    FutureProvider.family<List<BoothModel>, String>((ref, eventId) async {
  final repository = ref.watch(boothRepositoryProvider);
  final result = await repository.getBoothsByEvent(
    eventId,
    filter: const BoothFilter(status: BoothStatus.available),
  );
  return result.fold((l) => [], (r) => r);
});

/// Booth map position provider (for interactive map)
final boothMapProvider =
    FutureProvider.family<Map<String, BoothModel>, String>((ref, eventId) async {
  final repository = ref.watch(boothRepositoryProvider);
  final result = await repository.getBoothsByEvent(eventId);
  return result.fold(
    (l) => {},
    (booths) => {for (final booth in booths) booth.id: booth},
  );
});
