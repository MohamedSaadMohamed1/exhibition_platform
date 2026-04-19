import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/models/business_request_model.dart';

class AdminBusinessRequestsState {
  final List<BusinessRequestModel> requests;
  final bool isLoading;
  final String? errorMessage;
  final String? statusFilter; // null = all

  const AdminBusinessRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
  });

  AdminBusinessRequestsState copyWith({
    List<BusinessRequestModel>? requests,
    bool? isLoading,
    String? errorMessage,
    String? statusFilter,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return AdminBusinessRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      statusFilter: clearFilter ? null : statusFilter ?? this.statusFilter,
    );
  }

  List<BusinessRequestModel> get filteredRequests {
    if (statusFilter == null) return requests;
    return requests.where((r) => r.status == statusFilter).toList();
  }
}

class AdminBusinessRequestsNotifier
    extends Notifier<AdminBusinessRequestsState> {
  @override
  AdminBusinessRequestsState build() {
    Future.microtask(() => _loadRequests());
    return const AdminBusinessRequestsState(isLoading: true);
  }

  Future<void> _loadRequests() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.businessRequests)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => BusinessRequestModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(requests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() => _loadRequests();

  void setStatusFilter(String? filter) {
    if (filter == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter);
    }
  }

  Future<bool> approveRequest(String requestId, String adminId) async {
    try {
      final request = state.requests.firstWhere((r) => r.id == requestId);
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Create a new suppliers document
      final supplierRef = firestore.collection(FirestoreCollections.suppliers).doc();
      batch.set(supplierRef, {
        'name': request.businessName,
        'description': request.description,
        'category': request.category,
        'contactEmail': request.contactEmail,
        'contactPhone': request.contactPhone,
        'address': request.address,
        'website': request.website,
        'ownerId': request.supplierId,
        'ownerName': request.supplierName,
        'services': <String>[],
        'images': <String>[],
        'rating': 0.0,
        'reviewCount': 0,
        'ordersCount': 0,
        'isActive': true,
        'isVerified': false,
        'isFeatured': false,
        'createdByAdmin': adminId,
        'searchKeywords': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the request status
      final requestRef = firestore
          .collection(FirestoreCollections.businessRequests)
          .doc(requestId);
      batch.update(requestRef, {
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      await batch.commit();

      // Reflect in local state
      final updated = state.requests.map((r) {
        if (r.id == requestId) {
          return r.copyWith(
            status: 'approved',
            reviewedAt: DateTime.now(),
            reviewedBy: adminId,
          );
        }
        return r;
      }).toList();

      state = state.copyWith(requests: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectRequest(
    String requestId,
    String adminId, {
    String? adminNotes,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.businessRequests)
          .doc(requestId)
          .update({
        'status': 'rejected',
        'adminNotes': adminNotes,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      final updated = state.requests.map((r) {
        if (r.id == requestId) {
          return r.copyWith(
            status: 'rejected',
            adminNotes: adminNotes,
            reviewedAt: DateTime.now(),
            reviewedBy: adminId,
          );
        }
        return r;
      }).toList();

      state = state.copyWith(requests: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final adminBusinessRequestsProvider = NotifierProvider<
    AdminBusinessRequestsNotifier, AdminBusinessRequestsState>(
  () => AdminBusinessRequestsNotifier(),
);
