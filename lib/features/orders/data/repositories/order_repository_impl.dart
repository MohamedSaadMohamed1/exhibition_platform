import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';

/// Implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  @override
  Future<Either<Failure, OrderModel>> createOrder(OrderModel order) async {
    try {
      final docRef = _ordersCollection.doc();
      final newOrder = order.copyWith(id: docRef.id);

      await docRef.set(newOrder.toFirestore());

      return Right(newOrder);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, OrderModel>> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure.withMessage('Order not found'));
      }

      return Right(OrderModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getCustomerOrders(
    String customerId, {
    OrderStatus? status,
    int limit = 20,
    String? lastOrderId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersCollection
          .where('customerId', isEqualTo: customerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      query = query.orderBy('createdAt', descending: true);

      if (lastOrderId != null) {
        final lastDoc = await _ordersCollection.doc(lastOrderId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getSupplierOrders(
    String supplierId, {
    OrderStatus? status,
    int limit = 20,
    String? lastOrderId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _ordersCollection
          .where('supplierId', isEqualTo: supplierId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      query = query.orderBy('createdAt', descending: true);

      if (lastOrderId != null) {
        final lastDoc = await _ordersCollection.doc(lastOrderId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderModel>>> getServiceOrders(
    String serviceId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _ordersCollection
          .where('serviceId', isEqualTo: serviceId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      return Right(orders);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, OrderModel>> acceptOrder(String orderId) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        return Left(NotFoundFailure.withMessage('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);
      if (!order.canBeAccepted) {
        return Left(ValidationFailure.withMessage('Order cannot be accepted'));
      }

      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.accepted.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _ordersCollection.doc(orderId).get();
      return Right(OrderModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, OrderModel>> rejectOrder(
    String orderId, {
    String? reason,
  }) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        return Left(NotFoundFailure.withMessage('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);
      if (!order.canBeAccepted) {
        return Left(ValidationFailure.withMessage('Order cannot be rejected'));
      }

      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.rejected.value,
        if (reason != null) 'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _ordersCollection.doc(orderId).get();
      return Right(OrderModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, OrderModel>> startOrderProgress(String orderId) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        return Left(NotFoundFailure.withMessage('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);
      if (!order.canStartProgress) {
        return Left(ValidationFailure.withMessage('Order cannot start progress'));
      }

      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.inProgress.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _ordersCollection.doc(orderId).get();
      return Right(OrderModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, OrderModel>> completeOrder(String orderId) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        return Left(NotFoundFailure.withMessage('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);
      if (!order.canBeCompleted) {
        return Left(ValidationFailure.withMessage('Order cannot be completed'));
      }

      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.completed.value,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _ordersCollection.doc(orderId).get();
      return Right(OrderModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(
    String orderId, {
    required String cancelledBy,
    String? reason,
  }) async {
    try {
      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        return Left(NotFoundFailure.withMessage('Order not found'));
      }

      final order = OrderModel.fromFirestore(orderDoc);
      if (!order.canBeCancelled) {
        return Left(ValidationFailure.withMessage('Order cannot be cancelled'));
      }

      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.value,
        'cancelledBy': cancelledBy,
        if (reason != null) 'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, OrderStats>> getSupplierOrderStats(
    String supplierId,
  ) async {
    try {
      final snapshot = await _ordersCollection
          .where('supplierId', isEqualTo: supplierId)
          .get();

      int pending = 0, accepted = 0, inProgress = 0, completed = 0, cancelled = 0;
      double totalRevenue = 0, pendingRevenue = 0;

      for (final doc in snapshot.docs) {
        final order = OrderModel.fromFirestore(doc);

        switch (order.status) {
          case OrderStatus.pending:
            pending++;
            pendingRevenue += order.totalPrice;
            break;
          case OrderStatus.accepted:
            accepted++;
            pendingRevenue += order.totalPrice;
            break;
          case OrderStatus.inProgress:
            inProgress++;
            pendingRevenue += order.totalPrice;
            break;
          case OrderStatus.completed:
            completed++;
            totalRevenue += order.totalPrice;
            break;
          case OrderStatus.cancelled:
            cancelled++;
            break;
          case OrderStatus.rejected:
            break;
        }
      }

      return Right(OrderStats(
        totalOrders: snapshot.docs.length,
        pendingOrders: pending,
        acceptedOrders: accepted,
        inProgressOrders: inProgress,
        completedOrders: completed,
        cancelledOrders: cancelled,
        totalRevenue: totalRevenue,
        pendingRevenue: pendingRevenue,
      ));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<OrderModel> watchOrder(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map(
      (doc) => OrderModel.fromFirestore(doc),
    );
  }

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String customerId) {
    return _ordersCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<OrderModel>> watchSupplierOrders(String supplierId) {
    return _ordersCollection
        .where('supplierId', isEqualTo: supplierId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  @override
  Future<Either<Failure, int>> getPendingOrdersCount(String supplierId) async {
    try {
      final snapshot = await _ordersCollection
          .where('supplierId', isEqualTo: supplierId)
          .where('status', isEqualTo: OrderStatus.pending.value)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
