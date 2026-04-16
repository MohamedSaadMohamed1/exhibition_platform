import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/providers/providers.dart';

/// Provider to store the currently selected supplier ID
final selectedSupplierIdProvider = StateProvider<String?>((ref) => null);

/// Provider to get ALL suppliers owned by the user
final userSuppliersProvider = FutureProvider<List<SupplierModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  var snapshot = await FirebaseFirestore.instance
      .collection('suppliers')
      .where('ownerId', isEqualTo: userId)
      .get();
      
  List<SupplierModel> suppliers = snapshot.docs
      .map((doc) => SupplierModel.fromFirestore(doc))
      .toList();

  if (suppliers.isEmpty) {
    // Fallback for legacy database records
    snapshot = await FirebaseFirestore.instance
        .collection('suppliers')
        .where('userId', isEqualTo: userId)
        .get();
    suppliers = snapshot.docs
        .map((doc) => SupplierModel.fromFirestore(doc))
        .toList();
  }
  
  // Stable sorting by creation date
  suppliers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return suppliers;
});

/// Provider for current user's ACTIVE supplier profile
final currentSupplierProvider = FutureProvider<SupplierModel?>((ref) async {
  final suppliers = await ref.read(userSuppliersProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  if (suppliers.isNotEmpty) {
    final selectedId = ref.watch(selectedSupplierIdProvider);
    if (selectedId != null) {
      try {
        return suppliers.firstWhere((s) => s.id == selectedId);
      } catch (_) {
        return suppliers.first;
      }
    }
    return suppliers.first;
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
      isActive: true, // Auto-Active for visibility
    );
    await docRef.set(newSupplier.toFirestore());
    // Invalidate list to fetch the newly provisioned one on next pull
    ref.invalidate(userSuppliersProvider);
    return newSupplier;
  }

  return null;
});

/// Global API to manually create a new Business Profile side-by-side with existing ones
Future<void> createBusinessProfile(WidgetRef ref, String businessName) async {
  final user = ref.read(currentUserProvider).valueOrNull;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance.collection('suppliers').doc();
  final newSupplier = SupplierModel(
    id: docRef.id,
    name: businessName,
    description: 'Please describe your business.',
    ownerId: user.id,
    createdByAdmin: 'system',
    createdAt: DateTime.now(),
    isActive: true, // Auto-Active for visibility
  );
  
  await docRef.set(newSupplier.toFirestore());
  
  // Refresh and switch to the new business!
  ref.invalidate(userSuppliersProvider);
  ref.read(selectedSupplierIdProvider.notifier).state = docRef.id;
  
  // Invalidate loaded data
  ref.invalidate(myServicesProvider);
  ref.invalidate(recentOrdersProvider);
  ref.invalidate(supplierStatsProvider);
}

/// Provider for current supplier's services (stored as subcollection)
final myServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('services')
      .where('supplierId', isEqualTo: supplier.id)
      .get();

  final services = snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
  // Sort locally to bypass missing composite index in Firebase
  services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return services;
});

/// Provider for current supplier's orders
final myOrdersAsSupplierProvider = FutureProvider<List<OrderModel>>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('supplierId', isEqualTo: supplier.id)
      .get();

  final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  // Sort locally to bypass missing composite index in Firebase
  orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return orders;
});

/// Provider for supplier dashboard stats
final supplierStatsProvider = FutureProvider<SupplierDashboardStats>((ref) async {
  final supplier = await ref.watch(currentSupplierProvider.future);
  if (supplier == null) return const SupplierDashboardStats();

  final firestore = FirebaseFirestore.instance;

  // Get services count from root collection
  // Fetch all services, then calculate active ones to bypass missing index
  final servicesSnapshot = await firestore
      .collection('services')
      .where('supplierId', isEqualTo: supplier.id)
      .get();
      
  final activeServices = servicesSnapshot.docs
      .where((doc) => doc.data()['isActive'] == true)
      .length;

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
    activeServices: activeServices,
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
      .get();

  final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  // Sort locally to bypass missing composite index in Firebase
  orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return orders.take(5).toList();
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

  /// Get the current supplier (single read to avoid race conditions)
  Future<SupplierModel?> _getCurrentSupplier() async {
    return ref.read(currentSupplierProvider.future);
  }

  Future<bool> createService(ServiceModel service) async {
    state = const AsyncValue.loading();
    try {
      final supplier = await _getCurrentSupplier();
      if (supplier == null) {
        state = AsyncValue.error('Supplier profile not found. Please complete your business profile first.', StackTrace.current);
        return false;
      }

      final docRef = FirebaseFirestore.instance.collection('services').doc();
      await docRef.set({
        ...service.toFirestore(),
        'id': docRef.id,
        'supplierId': supplier.id,
        'supplierName': supplier.businessName,
      });
      ref.invalidate(myServicesProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    state = const AsyncValue.loading();
    try {
      final supplier = await _getCurrentSupplier();
      if (supplier == null) {
        state = AsyncValue.error('Supplier profile not found.', StackTrace.current);
        return false;
      }

      final updateData = service.toUpdateMap();
      updateData['supplierId'] = supplier.id;
      updateData['supplierName'] = supplier.businessName;

      await FirebaseFirestore.instance
          .collection('services')
          .doc(service.id)
          .update(updateData);
      ref.invalidate(myServicesProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .delete();
      ref.invalidate(myServicesProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> toggleServiceStatus(String serviceId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ref.invalidate(myServicesProvider);
      ref.invalidate(supplierStatsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
