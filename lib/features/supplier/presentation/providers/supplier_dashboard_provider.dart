import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/providers/providers.dart';

/// Provider for current user's supplier profile
final currentSupplierProvider = FutureProvider<SupplierModel?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  var snapshot = await FirebaseFirestore.instance
      .collection('suppliers')
      .where('ownerId', isEqualTo: userId)
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();
      
  if (snapshot.docs.isEmpty) {
    // Fallback for legacy database records
    snapshot = await FirebaseFirestore.instance
        .collection('suppliers')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
  }

  if (snapshot.docs.isNotEmpty) {
    return SupplierModel.fromFirestore(snapshot.docs.first);
  }

  // AUTO-PROVISION: If the user has 'supplier' role but their supplier document is completely missing 
  // (e.g. because admin just updated their role without filling out the Create Supplier form)
  // we automatically provision a placeholder profile so they can use the dashboard.
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user != null && user.role == UserRole.supplier) {
    final docRef = FirebaseFirestore.instance.collection('suppliers').doc();
    final newSupplier = SupplierModel(
      id: docRef.id,
      name: user.name.isNotEmpty ? '${user.name}\'s Business' : 'My Business',
      description: 'Please describe your business.',
      ownerId: userId,
      createdByAdmin: 'system',
      createdAt: DateTime.now(),
      isActive: true,
    );
    await docRef.set(newSupplier.toFirestore());
    return newSupplier;
  }

  return null;
});

/// Provider for current supplier's services (stored as subcollection)
final myServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('services')
      .where('supplierId', isEqualTo: supplier.id)
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
});

/// Provider for current supplier's orders
final myOrdersAsSupplierProvider = FutureProvider<List<OrderModel>>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('supplierId', isEqualTo: supplier.id)
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
});

/// Provider for supplier dashboard stats
final supplierStatsProvider = FutureProvider<SupplierDashboardStats>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return const SupplierDashboardStats();

  final firestore = FirebaseFirestore.instance;

  // Get services count from root collection
  final servicesSnapshot = await firestore
      .collection('services')
      .where('supplierId', isEqualTo: supplier.id)
      .where('isActive', isEqualTo: true)
      .count()
      .get();

  // Get orders
  final ordersSnapshot = await firestore
      .collection('orders')
      .where('supplierId', isEqualTo: supplier.id)
      .get();

  final orders = ordersSnapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

  int pendingOrders = 0;
  int completedOrders = 0;
  double totalRevenue = 0;
  double monthlyRevenue = 0;

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  for (final order in orders) {
    if (order.status == OrderStatus.pending) {
      pendingOrders++;
    } else if (order.status == OrderStatus.completed) {
      completedOrders++;
      totalRevenue += order.totalPrice;

      if (order.completedAt != null && order.completedAt!.isAfter(startOfMonth)) {
        monthlyRevenue += order.totalPrice;
      }
    }
  }

  return SupplierDashboardStats(
    activeServices: servicesSnapshot.count ?? 0,
    pendingOrders: pendingOrders,
    completedOrders: completedOrders,
    totalRevenue: totalRevenue,
    monthlyRevenue: monthlyRevenue,
  );
});

/// Provider for recent orders (last 5)
final recentOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('supplierId', isEqualTo: supplier.id)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .get();

  return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
});

/// Dashboard stats model
class SupplierDashboardStats {
  final int activeServices;
  final int pendingOrders;
  final int completedOrders;
  final double totalRevenue;
  final double monthlyRevenue;

  const SupplierDashboardStats({
    this.activeServices = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.totalRevenue = 0,
    this.monthlyRevenue = 0,
  });
}

/// Service management notifier
class ServiceManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ServiceManagementNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Get the services collection reference for current supplier
  Future<CollectionReference<Map<String, dynamic>>?> _getServicesCollection() async {
    final supplier = await ref.read(currentSupplierProvider.future);
    if (supplier == null) return null;

    return FirebaseFirestore.instance
        .collection('services');
  }

  Future<bool> createService(ServiceModel service) async {
    state = const AsyncValue.loading();
    try {
      final servicesCollection = await _getServicesCollection();
      if (servicesCollection == null) {
        state = AsyncValue.error('Supplier not found', StackTrace.current);
        return false;
      }

      final supplier = await ref.read(currentSupplierProvider.future);
      final docRef = servicesCollection.doc();
      await docRef.set({
        ...service.toFirestore(),
        'id': docRef.id,
        'supplierId': supplier!.id,
        'supplierName': supplier.businessName,
      });
      ref.invalidate(myServicesProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    state = const AsyncValue.loading();
    try {
      final servicesCollection = await _getServicesCollection();
      if (servicesCollection == null) {
        state = AsyncValue.error('Supplier not found', StackTrace.current);
        return false;
      }

      await servicesCollection.doc(service.id).update(service.toUpdateMap());
      ref.invalidate(myServicesProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    state = const AsyncValue.loading();
    try {
      final servicesCollection = await _getServicesCollection();
      if (servicesCollection == null) {
        state = AsyncValue.error('Supplier not found', StackTrace.current);
        return false;
      }

      await servicesCollection.doc(serviceId).delete();
      ref.invalidate(myServicesProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> toggleServiceStatus(String serviceId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      final servicesCollection = await _getServicesCollection();
      if (servicesCollection == null) {
        state = AsyncValue.error('Supplier not found', StackTrace.current);
        return false;
      }

      await servicesCollection.doc(serviceId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ref.invalidate(myServicesProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final serviceManagementProvider =
    StateNotifierProvider<ServiceManagementNotifier, AsyncValue<void>>((ref) {
  return ServiceManagementNotifier(ref);
});

/// Order management notifier
class OrderManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  OrderManagementNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<bool> updateOrderStatus(String orderId, OrderStatus status, {String? reason}) async {
    state = const AsyncValue.loading();
    try {
      final updates = <String, dynamic>{
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == OrderStatus.rejected && reason != null) {
        updates['rejectionReason'] = reason;
      }
      if (status == OrderStatus.cancelled && reason != null) {
        updates['cancellationReason'] = reason;
      }
      if (status == OrderStatus.accepted) {
        updates['confirmedAt'] = FieldValue.serverTimestamp();
      }
      if (status == OrderStatus.completed) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update(updates);

      ref.invalidate(myOrdersAsSupplierProvider);
      ref.invalidate(recentOrdersProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final orderManagementProvider =
    StateNotifierProvider<OrderManagementNotifier, AsyncValue<void>>((ref) {
  return OrderManagementNotifier(ref);
});
