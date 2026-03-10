import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/order_repository.dart';

/// Orders state
class OrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final OrderStatus? statusFilter;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.statusFilter,
  });

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    OrderStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

/// Customer orders notifier
class CustomerOrdersNotifier extends FamilyNotifier<OrdersState, String> {
  late final OrderRepository _orderRepository;

  @override
  OrdersState build(String customerId) {
    _orderRepository = ref.watch(orderRepositoryProvider);
    _loadOrders(customerId);
    return const OrdersState(isLoading: true);
  }

  Future<void> _loadOrders(String customerId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      orders: refresh ? [] : state.orders,
    );

    final result = await _orderRepository.getCustomerOrders(
      customerId,
      status: state.statusFilter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (orders) {
        state = state.copyWith(
          orders: orders,
          isLoading: false,
          hasMore: orders.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadOrders(arg, refresh: true);
  }

  void filterByStatus(OrderStatus? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    _loadOrders(arg, refresh: true);
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final result = await _orderRepository.cancelOrder(
      orderId,
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

/// Customer orders provider
final customerOrdersProvider =
    NotifierProvider.family<CustomerOrdersNotifier, OrdersState, String>(() {
  return CustomerOrdersNotifier();
});

/// Supplier orders notifier
class SupplierOrdersNotifier extends FamilyNotifier<OrdersState, String> {
  late final OrderRepository _orderRepository;

  @override
  OrdersState build(String supplierId) {
    _orderRepository = ref.watch(orderRepositoryProvider);
    _loadOrders(supplierId);
    return const OrdersState(isLoading: true);
  }

  Future<void> _loadOrders(String supplierId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      orders: refresh ? [] : state.orders,
    );

    final result = await _orderRepository.getSupplierOrders(
      supplierId,
      status: state.statusFilter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (orders) {
        state = state.copyWith(
          orders: orders,
          isLoading: false,
          hasMore: orders.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadOrders(arg, refresh: true);
  }

  void filterByStatus(OrderStatus? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    _loadOrders(arg, refresh: true);
  }

  Future<bool> acceptOrder(String orderId) async {
    final result = await _orderRepository.acceptOrder(orderId);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }

  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    final result = await _orderRepository.rejectOrder(orderId, reason: reason);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }

  Future<bool> startProgress(String orderId) async {
    final result = await _orderRepository.startOrderProgress(orderId);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }

  Future<bool> completeOrder(String orderId) async {
    final result = await _orderRepository.completeOrder(orderId);
    if (result.isRight()) {
      await refresh();
      return true;
    }
    return false;
  }
}

/// Supplier orders provider
final supplierOrdersProvider =
    NotifierProvider.family<SupplierOrdersNotifier, OrdersState, String>(() {
  return SupplierOrdersNotifier();
});

/// Single order provider
final orderProvider =
    FutureProvider.family<OrderModel?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getOrderById(orderId);
  return result.fold((l) => null, (r) => r);
});

/// Order stream provider
final orderStreamProvider =
    StreamProvider.family<OrderModel, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrder(orderId);
});

/// Customer orders stream provider
final customerOrdersStreamProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchCustomerOrders(customerId);
});

/// Supplier orders stream provider
final supplierOrdersStreamProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, supplierId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchSupplierOrders(supplierId);
});

/// Supplier order stats provider
final supplierOrderStatsProvider =
    FutureProvider.family<OrderStats, String>((ref, supplierId) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getSupplierOrderStats(supplierId);
  return result.fold((l) => const OrderStats(), (r) => r);
});

/// Pending orders count provider
final pendingOrdersCountProvider =
    FutureProvider.family<int, String>((ref, supplierId) async {
  final repository = ref.watch(orderRepositoryProvider);
  final result = await repository.getPendingOrdersCount(supplierId);
  return result.fold((l) => 0, (r) => r);
});
