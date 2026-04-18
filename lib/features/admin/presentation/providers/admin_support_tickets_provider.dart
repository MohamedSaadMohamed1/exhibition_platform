import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../shared/models/support_ticket_model.dart';

class AdminSupportTicketsState {
  final List<SupportTicketModel> tickets;
  final bool isLoading;
  final String? errorMessage;
  final String? statusFilter; // null = all

  const AdminSupportTicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusFilter,
  });

  AdminSupportTicketsState copyWith({
    List<SupportTicketModel>? tickets,
    bool? isLoading,
    String? errorMessage,
    String? statusFilter,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return AdminSupportTicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      statusFilter: clearFilter ? null : statusFilter ?? this.statusFilter,
    );
  }

  List<SupportTicketModel> get filteredTickets {
    if (statusFilter == null) return tickets;
    return tickets.where((t) => t.status == statusFilter).toList();
  }
}

class AdminSupportTicketsNotifier
    extends Notifier<AdminSupportTicketsState> {
  @override
  AdminSupportTicketsState build() {
    Future.microtask(() => _loadTickets());
    return const AdminSupportTicketsState(isLoading: true);
  }

  Future<void> _loadTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.supportTickets)
          .orderBy('createdAt', descending: true)
          .get();

      final tickets = snapshot.docs
          .map((doc) => SupportTicketModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> refresh() => _loadTickets();

  void setStatusFilter(String? filter) {
    if (filter == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter);
    }
  }

  Future<bool> updateTicketStatus(
    String ticketId,
    String newStatus, {
    String? adminNotes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (adminNotes != null) {
        updateData['adminNotes'] = adminNotes;
      }

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.supportTickets)
          .doc(ticketId)
          .update(updateData);

      // Reflect change in local state
      final updated = state.tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(
            status: newStatus,
            adminNotes: adminNotes ?? t.adminNotes,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(tickets: updated);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final adminSupportTicketsProvider =
    NotifierProvider<AdminSupportTicketsNotifier, AdminSupportTicketsState>(
  () => AdminSupportTicketsNotifier(),
);
