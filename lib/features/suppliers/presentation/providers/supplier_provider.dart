import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/supplier_repository.dart';

/// Suppliers state
class SuppliersState {
  final List<SupplierModel> suppliers;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final SupplierFilter filter;

  const SuppliersState({
    this.suppliers = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.filter = const SupplierFilter(),
  });

  SuppliersState copyWith({
    List<SupplierModel>? suppliers,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    SupplierFilter? filter,
  }) {
    return SuppliersState(
      suppliers: suppliers ?? this.suppliers,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

/// Suppliers notifier
class SuppliersNotifier extends Notifier<SuppliersState> {
  late final SupplierRepository _supplierRepository;

  @override
  SuppliersState build() {
    _supplierRepository = ref.watch(supplierRepositoryProvider);
    Future.microtask(() => _loadSuppliers());
    return const SuppliersState(isLoading: true);
  }

  Future<void> _loadSuppliers({bool refresh = false}) async {
    if (state.isLoading && state.suppliers.isNotEmpty && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      suppliers: refresh ? [] : state.suppliers,
    );

    final result = await _supplierRepository.getSuppliers(
      filter: state.filter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (suppliers) {
        state = state.copyWith(
          suppliers: suppliers,
          isLoading: false,
          hasMore: suppliers.length >= 20,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastId = state.suppliers.isNotEmpty ? state.suppliers.last.id : null;

    state = state.copyWith(isLoading: true);

    final result = await _supplierRepository.getSuppliers(
      filter: state.filter,
      lastSupplierId: lastId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (suppliers) {
        state = state.copyWith(
          suppliers: [...state.suppliers, ...suppliers],
          isLoading: false,
          hasMore: suppliers.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadSuppliers(refresh: true);
  }

  void applyFilter(SupplierFilter filter) {
    state = state.copyWith(filter: filter);
    _loadSuppliers(refresh: true);
  }

  void clearFilter() {
    state = state.copyWith(filter: const SupplierFilter());
    _loadSuppliers(refresh: true);
  }
}

/// Suppliers notifier provider
final suppliersNotifierProvider =
    NotifierProvider<SuppliersNotifier, SuppliersState>(() {
  return SuppliersNotifier();
});

/// Single supplier provider
final supplierProvider =
    FutureProvider.family<SupplierModel?, String>((ref, supplierId) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getSupplierById(supplierId);
  return result.fold((l) => null, (r) => r);
});

/// Supplier by user ID provider
final supplierByUserIdProvider =
    FutureProvider.family<SupplierModel?, String>((ref, userId) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getSupplierByUserId(userId);
  return result.fold((l) => null, (r) => r);
});

/// Supplier stream provider
final supplierStreamProvider =
    StreamProvider.family<SupplierModel, String>((ref, supplierId) {
  final repository = ref.watch(supplierRepositoryProvider);
  return repository.watchSupplier(supplierId);
});

/// Suppliers by category provider
final suppliersByCategoryProvider =
    FutureProvider.family<List<SupplierModel>, String>((ref, category) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getSuppliersByCategory(category);
  return result.fold((l) => [], (r) => r);
});

/// Featured suppliers provider
final featuredSuppliersProvider =
    FutureProvider<List<SupplierModel>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getFeaturedSuppliers();
  return result.fold((l) => [], (r) => r);
});

/// Top rated suppliers provider
final topRatedSuppliersProvider =
    FutureProvider<List<SupplierModel>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getTopRatedSuppliers();
  return result.fold((l) => [], (r) => r);
});

/// Supplier services provider
final supplierServicesProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, supplierId) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getSupplierServices(supplierId);
  return result.fold((l) => [], (r) => r);
});

/// Supplier categories provider
final supplierCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getSupplierCategories();
  return result.fold((l) => [], (r) => r);
});
