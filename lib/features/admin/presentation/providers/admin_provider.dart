import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../domain/repositories/admin_repository.dart';

/// Admin users state
class AdminUsersState {
  final List<UserModel> users;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final UserRole? roleFilter;

  const AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.roleFilter,
  });

  AdminUsersState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    UserRole? roleFilter,
    bool clearRoleFilter = false,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
    );
  }
}

/// Admin Users Notifier
class AdminUsersNotifier extends Notifier<AdminUsersState> {
  late final AdminRepository _adminRepository;

  @override
  AdminUsersState build() {
    _adminRepository = ref.watch(adminRepositoryProvider);
    Future.microtask(() => _loadUsers());
    return const AdminUsersState(isLoading: true);
  }

  /// Load users
  Future<void> _loadUsers({bool refresh = false}) async {
    if (state.isLoading && state.users.isNotEmpty && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      users: refresh ? [] : state.users,
    );

    final result = await _adminRepository.getUsers(
      roleFilter: state.roleFilter,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (users) {
        state = state.copyWith(
          users: users,
          isLoading: false,
          hasMore: users.length >= 20,
        );
      },
    );
  }

  /// Load more users
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final lastUserId = state.users.isNotEmpty ? state.users.last.id : null;

    state = state.copyWith(isLoading: true);

    final result = await _adminRepository.getUsers(
      roleFilter: state.roleFilter,
      lastUserId: lastUserId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (users) {
        state = state.copyWith(
          users: [...state.users, ...users],
          isLoading: false,
          hasMore: users.length >= 20,
        );
      },
    );
  }

  /// Filter by role
  void filterByRole(UserRole? role) {
    if (role == null) {
      state = state.copyWith(clearRoleFilter: true);
    } else {
      state = state.copyWith(roleFilter: role);
    }
    _loadUsers(refresh: true);
  }

  /// Refresh
  Future<void> refresh() async {
    await _loadUsers(refresh: true);
  }

  /// Create organizer
  Future<bool> createOrganizer({
    required String name,
    required String phone,
    String? email,
    required String adminId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _adminRepository.createOrganizer(
      name: name,
      phone: phone,
      email: email,
      createdByAdminId: adminId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          users: [user, ...state.users],
          isLoading: false,
        );
        return true;
      },
    );
  }

  /// Create supplier
  Future<bool> createSupplier({
    required String name,
    required String phone,
    required String supplierName,
    required String supplierDescription,
    required List<String> services,
    String? category,
    String? email,
    required String adminId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _adminRepository.createSupplier(
      name: name,
      phone: phone,
      supplierName: supplierName,
      supplierDescription: supplierDescription,
      services: services,
      category: category,
      email: email,
      createdByAdminId: adminId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        return false;
      },
      (data) {
        state = state.copyWith(
          users: [data.user, ...state.users],
          isLoading: false,
        );
        return true;
      },
    );
  }

  /// Deactivate user
  Future<bool> deactivateUser(String userId) async {
    state = state.copyWith(isLoading: true);

    final result = await _adminRepository.deactivateUser(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          users: state.users.map((u) {
            if (u.id == userId) {
              return u.copyWith(isActive: false);
            }
            return u;
          }).toList(),
          isLoading: false,
        );
        return true;
      },
    );
  }

  /// Activate user
  Future<bool> activateUser(String userId) async {
    state = state.copyWith(isLoading: true);

    final result = await _adminRepository.activateUser(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          isLoading: false,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          users: state.users.map((u) {
            if (u.id == userId) {
              return u.copyWith(isActive: true);
            }
            return u;
          }).toList(),
          isLoading: false,
        );
        return true;
      },
    );
  }
}

/// Admin Users Notifier Provider
final adminUsersNotifierProvider = NotifierProvider<AdminUsersNotifier, AdminUsersState>(() {
  return AdminUsersNotifier();
});

/// User stats provider
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final result = await repository.getUserStats();
  return result.fold(
    (l) => const UserStats(
      totalUsers: 0,
      totalAdmins: 0,
      totalOrganizers: 0,
      totalSuppliers: 0,
      totalExhibitors: 0,
      totalVisitors: 0,
      activeUsers: 0,
      inactiveUsers: 0,
    ),
    (r) => r,
  );
});

/// Organizers list provider
final organizersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final result = await repository.getOrganizers();
  return result.fold((l) => [], (r) => r);
});
