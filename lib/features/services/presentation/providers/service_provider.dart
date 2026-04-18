import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/service_repository.dart';

/// Services state
class ServicesState {
  final List<ServiceModel> services;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final ServiceFilter filter;

  const ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const ServiceFilter(),
  });

  ServicesState copyWith({
    List<ServiceModel>? services,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    ServiceFilter? filter,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Services notifier
class ServicesNotifier extends Notifier<ServicesState> {
  late ServiceRepository _serviceRepository;

  @override
  ServicesState build() {
    _serviceRepository = ref.watch(serviceRepositoryProvider);
    Future.microtask(() => _loadServices());
    return const ServicesState(isLoading: true);
  }

  Future<void> _loadServices({bool refresh = false}) async {
    if (state.isLoading && state.services.isNotEmpty && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      services: refresh ? [] : state.services,
    );

    final result = await _serviceRepository.getServices(filter: state.filter);

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (services) {
        state = state.copyWith(
          services: services,
          isLoading: false,
          hasMore: services.length >= 20,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastId = state.services.isNotEmpty ? state.services.last.id : null;

    state = state.copyWith(isLoading: true);

    final result = await _serviceRepository.getServices(
      filter: state.filter,
      lastServiceId: lastId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (services) {
        state = state.copyWith(
          services: [...state.services, ...services],
          isLoading: false,
          hasMore: services.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadServices(refresh: true);
  }

  void applyFilter(ServiceFilter filter) {
    state = state.copyWith(filter: filter);
    _loadServices(refresh: true);
  }

  void clearFilter() {
    state = state.copyWith(filter: const ServiceFilter());
    _loadServices(refresh: true);
  }
}

/// Services notifier provider
final servicesNotifierProvider =
    NotifierProvider<ServicesNotifier, ServicesState>(() {
  return ServicesNotifier();
});

/// Single service provider
final serviceProvider =
    FutureProvider.family<ServiceModel?, String>((ref, serviceId) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getServiceById(serviceId);
  return result.fold((l) => null, (r) => r);
});

/// Service stream provider
final serviceStreamProvider =
    StreamProvider.family<ServiceModel, String>((ref, serviceId) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.watchService(serviceId);
});

/// Supplier services provider
final supplierServicesListProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, supplierId) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getSupplierServices(supplierId);
  return result.fold((l) => [], (r) => r);
});

/// Supplier services stream provider
final supplierServicesStreamProvider =
    StreamProvider.family<List<ServiceModel>, String>((ref, supplierId) {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.watchSupplierServices(supplierId);
});

/// Services by category provider
final servicesByCategoryProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, category) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getServicesByCategory(category);
  return result.fold((l) => [], (r) => r);
});

/// Featured services provider
final featuredServicesProvider =
    FutureProvider<List<ServiceModel>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getFeaturedServices();
  return result.fold((l) => [], (r) => r);
});

/// Top rated services provider
final topRatedServicesProvider =
    FutureProvider<List<ServiceModel>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getTopRatedServices();
  return result.fold((l) => [], (r) => r);
});

/// Service categories provider
final serviceCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  final result = await repository.getServiceCategories();
  return result.fold((l) => [], (r) => r);
});
