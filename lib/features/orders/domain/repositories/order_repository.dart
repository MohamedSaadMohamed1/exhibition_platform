import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/order_model.dart';

/// Order repository interface
abstract class OrderRepository {
  /// Create an order
  Future<Either<Failure, OrderModel>> createOrder(OrderModel order);

  /// Get order by ID
  Future<Either<Failure, OrderModel>> getOrderById(String orderId);

  /// Get orders for customer
  Future<Either<Failure, List<OrderModel>>> getCustomerOrders(
    String customerId, {
    OrderStatus? status,
    int limit = 20,
    String? lastOrderId,
  });

  /// Get orders for supplier
  Future<Either<Failure, List<OrderModel>>> getSupplierOrders(
    String supplierId, {
    OrderStatus? status,
    int limit = 20,
    String? lastOrderId,
  });

  /// Get orders for a service
  Future<Either<Failure, List<OrderModel>>> getServiceOrders(
    String serviceId, {
    int limit = 20,
  });

  /// Accept order (supplier)
  Future<Either<Failure, OrderModel>> acceptOrder(String orderId);

  /// Reject order (supplier)
  Future<Either<Failure, OrderModel>> rejectOrder(
    String orderId, {
    String? reason,
  });

  /// Start order progress (supplier)
  Future<Either<Failure, OrderModel>> startOrderProgress(String orderId);

  /// Complete order (supplier)
  Future<Either<Failure, OrderModel>> completeOrder(String orderId);

  /// Cancel order (customer or supplier)
  Future<Either<Failure, void>> cancelOrder(
    String orderId, {
    required String cancelledBy,
    String? reason,
  });

  /// Get order statistics for supplier
  Future<Either<Failure, OrderStats>> getSupplierOrderStats(String supplierId);

  /// Watch order for real-time updates
  Stream<OrderModel> watchOrder(String orderId);

  /// Watch customer orders
  Stream<List<OrderModel>> watchCustomerOrders(String customerId);

  /// Watch supplier orders
  Stream<List<OrderModel>> watchSupplierOrders(String supplierId);

  /// Get pending orders count for supplier
  Future<Either<Failure, int>> getPendingOrdersCount(String supplierId);
}
