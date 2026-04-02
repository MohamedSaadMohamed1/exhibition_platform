import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/providers/repository_providers.dart';

class AdminOrdersState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;
  final OrderStatus? statusFilter;

  const AdminOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
  });

  AdminOrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    OrderStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AdminOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class AdminOrdersNotifier extends Notifier<AdminOrdersState> {
  @override
  AdminOrdersState build() {
    Future.microtask(() => _loadOrders());
    return const AdminOrdersState(isLoading: true);
  }

  Future<void> _loadOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(orderRepositoryProvider)
        .getAllOrders(status: state.statusFilter);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        isLoading: false,
        orders: orders,
      ),
    );
  }

  Future<void> filterByStatus(OrderStatus? status) async {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    await _loadOrders();
  }

  Future<void> refresh() => _loadOrders();
}

final adminOrdersProvider =
    NotifierProvider<AdminOrdersNotifier, AdminOrdersState>(
  AdminOrdersNotifier.new,
);
