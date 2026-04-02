import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../features/booths/domain/repositories/booth_repository.dart';
import '../../../../shared/models/booth_model.dart';
import '../../../../shared/providers/providers.dart';

/// Organizer booths state with action states
class OrganizerBoothsState {
  final List<BoothModel> booths;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final BoothFilter filter;
  final BoothStats? stats;

  // Action states
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? actionError;

  const OrganizerBoothsState({
    this.booths = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const BoothFilter(),
    this.stats,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.actionError,
  });

  OrganizerBoothsState copyWith({
    List<BoothModel>? booths,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    BoothFilter? filter,
    BoothStats? stats,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? actionError,
    bool clearActionError = false,
    bool clearErrorMessage = false,
  }) {
    return OrganizerBoothsState(
      booths: booths ?? this.booths,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      filter: filter ?? this.filter,
      stats: stats ?? this.stats,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}

/// Organizer booths notifier
class OrganizerBoothsNotifier extends FamilyNotifier<OrganizerBoothsState, String> {
  late final BoothRepository _boothRepository;

  @override
  OrganizerBoothsState build(String eventId) {
    _boothRepository = ref.watch(boothRepositoryProvider);
    // Use Future.microtask so state is fully initialized before we access it,
    // and pass refresh:true to bypass the concurrent-load guard on first run.
    Future.microtask(() async {
      await _loadBooths(eventId, refresh: true);
      await _loadStats(eventId);
    });
    return const OrganizerBoothsState(isLoading: true);
  }

  Future<void> _loadBooths(String eventId, {bool refresh = false}) async {
    // Prevent concurrent duplicate loads; always allow explicit refresh.
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      booths: refresh ? [] : state.booths,
      clearErrorMessage: true,
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
          hasMore: booths.length >= 50,
        );
      },
    );
  }

  Future<void> _loadStats(String eventId) async {
    final result = await _boothRepository.getBoothStats(eventId);
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
    await _loadBooths(arg, refresh: true);
    await _loadStats(arg);
  }

  Future<void> refreshStats() async {
    await _loadStats(arg);
  }

  void applyFilter(BoothFilter filter) {
    state = state.copyWith(filter: filter);
    _loadBooths(arg, refresh: true);
  }

  void clearFilter() {
    state = state.copyWith(filter: const BoothFilter());
    _loadBooths(arg, refresh: true);
  }

  /// Create a single booth
  Future<bool> createBooth({
    required String boothNumber,
    required BoothSize size,
    String? category,
    required double price,
    List<String>? amenities,
    String? description,
    BoothPosition? position,
    double? customWidth,
    double? customHeight,
  }) async {
    state = state.copyWith(
      isCreating: true,
      actionError: null,
      clearActionError: true,
    );

    final result = await _boothRepository.createBooth(
      eventId: arg,
      boothNumber: boothNumber,
      size: size,
      category: category,
      price: price,
      amenities: amenities,
      description: description,
      position: position,
      customWidth: customWidth,
      customHeight: customHeight,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          actionError: failure.message,
        );
        return false;
      },
      (booth) {
        state = state.copyWith(isCreating: false, clearActionError: true);
        refresh(); // Reload booth list and stats
        return true;
      },
    );
  }

  /// Create multiple booths at once
  Future<bool> createBooths({
    required List<BoothModel> booths,
  }) async {
    state = state.copyWith(
      isCreating: true,
      actionError: null,
      clearActionError: true,
    );

    final result = await _boothRepository.createBooths(
      eventId: arg,
      booths: booths,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          actionError: failure.message,
        );
        return false;
      },
      (createdBooths) {
        state = state.copyWith(isCreating: false, clearActionError: true);
        refresh(); // Reload booth list and stats
        return true;
      },
    );
  }

  /// Update booth details
  Future<bool> updateBooth({
    required String boothId,
    String? boothNumber,
    BoothSize? size,
    String? category,
    double? price,
    List<String>? amenities,
    String? description,
    BoothPosition? position,
    double? customWidth,
    double? customHeight,
  }) async {
    state = state.copyWith(
      isUpdating: true,
      actionError: null,
      clearActionError: true,
    );

    final result = await _boothRepository.updateBooth(
      eventId: arg,
      boothId: boothId,
      boothNumber: boothNumber,
      size: size,
      category: category,
      price: price,
      amenities: amenities,
      description: description,
      position: position,
      customWidth: customWidth,
      customHeight: customHeight,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          actionError: failure.message,
        );
        return false;
      },
      (booth) {
        state = state.copyWith(isUpdating: false, clearActionError: true);
        // Optimistically update the booth in the list
        final updatedBooths = state.booths.map((b) {
          return b.id == boothId ? booth : b;
        }).toList();
        state = state.copyWith(booths: updatedBooths);
        refreshStats(); // Refresh stats in case price changed
        return true;
      },
    );
  }

  /// Delete a booth
  Future<bool> deleteBooth(String boothId) async {
    state = state.copyWith(
      isDeleting: true,
      actionError: null,
      clearActionError: true,
    );

    final result = await _boothRepository.deleteBooth(arg, boothId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          actionError: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isDeleting: false, clearActionError: true);
        // Optimistically remove the booth from the list
        final updatedBooths = state.booths.where((b) => b.id != boothId).toList();
        state = state.copyWith(booths: updatedBooths);
        refreshStats(); // Refresh stats
        return true;
      },
    );
  }
}

/// Organizer booths provider
final organizerBoothsProvider =
    NotifierProvider.family<OrganizerBoothsNotifier, OrganizerBoothsState, String>(() {
  return OrganizerBoothsNotifier();
});

/// Organizer booths stream provider for real-time updates
final organizerBoothsStreamProvider =
    StreamProvider.family<List<BoothModel>, String>((ref, eventId) {
  final repository = ref.watch(boothRepositoryProvider);
  return repository.watchBooths(eventId);
});

/// Booth stats provider
final boothStatsProvider = FutureProvider.family<BoothStats?, String>((ref, eventId) async {
  final repository = ref.watch(boothRepositoryProvider);
  final result = await repository.getBoothStats(eventId);
  return result.fold((l) => null, (r) => r);
});
