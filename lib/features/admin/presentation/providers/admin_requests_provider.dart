import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/account_request_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_provider.dart';

class AdminRequestsState {
  final List<AccountRequestModel> requests;
  final bool isLoading;
  final String? errorMessage;

  const AdminRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminRequestsState copyWith({
    List<AccountRequestModel>? requests,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminRequestsNotifier extends Notifier<AdminRequestsState> {
  late final AdminRepository _adminRepository;

  @override
  AdminRequestsState build() {
    _adminRepository = ref.watch(adminRepositoryProvider);
    Future.microtask(() => _loadRequests());
    return const AdminRequestsState(isLoading: true);
  }

  Future<void> _loadRequests() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _adminRepository.getAccountRequests();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (requests) {
        state = state.copyWith(
          requests: requests,
          isLoading: false,
        );
      },
    );
  }

  Future<void> refresh() async {
    await _loadRequests();
  }

  Future<bool> approveRequest(String requestId, String adminId) async {
    state = state.copyWith(isLoading: true);

    final result = await _adminRepository.approveAccountRequest(requestId, adminId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        return false;
      },
      (_) {
        // Update local state
        final updatedRequests = state.requests.map((r) {
          if (r.id == requestId) {
            return r.copyWith(status: RequestStatus.approved);
          }
          return r;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> rejectRequest(String requestId) async {
    state = state.copyWith(isLoading: true);

    final result = await _adminRepository.rejectAccountRequest(requestId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        return false;
      },
      (_) {
        // Update local state
        final updatedRequests = state.requests.map((r) {
          if (r.id == requestId) {
            return r.copyWith(status: RequestStatus.rejected);
          }
          return r;
        }).toList();

        state = state.copyWith(
          requests: updatedRequests,
          isLoading: false,
        );
        return true;
      },
    );
  }
}

final adminRequestsProvider = NotifierProvider<AdminRequestsNotifier, AdminRequestsState>(() {
  return AdminRequestsNotifier();
});
