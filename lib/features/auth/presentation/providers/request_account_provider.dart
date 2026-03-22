import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/account_request_model.dart';

final requestAccountProvider = StateNotifierProvider<RequestAccountNotifier, bool>((ref) {
  return RequestAccountNotifier();
});

class RequestAccountNotifier extends StateNotifier<bool> {
  RequestAccountNotifier() : super(false);

  Future<bool> submitRequest({
    required String name,
    required String phone,
    String? email,
    required UserRole requestedRole,
    String? companyName,
    String? notes,
  }) async {
    state = true; // isLoading = true

    try {
      final id = const Uuid().v4();
      final request = AccountRequestModel(
        id: id,
        name: name,
        phone: phone,
        email: email,
        requestedRole: requestedRole,
        companyName: companyName,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.accountRequests)
          .doc(id)
          .set(request.toFirestore());

      state = false;
      return true;
    } catch (e) {
      state = false;
      return false;
    }
  }
}
