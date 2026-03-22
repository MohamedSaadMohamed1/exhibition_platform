import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/account_request_model.dart';

/// Admin repository interface
abstract class AdminRepository {
  /// Create a new organizer account (Admin only)
  Future<Either<Failure, UserModel>> createOrganizer({
    required String name,
    required String phone,
    String? email,
    required String createdByAdminId,
  });

  /// Create a new supplier account (Admin only)
  Future<Either<Failure, ({UserModel user, SupplierModel supplier})>>
      createSupplier({
    required String name,
    required String phone,
    required String supplierName,
    required String supplierDescription,
    required List<String> services,
    String? category,
    String? email,
    required String createdByAdminId,
  });

  /// Update user role (Admin only)
  Future<Either<Failure, UserModel>> updateUserRole({
    required String userId,
    required UserRole newRole,
  });

  /// Deactivate user (Admin only)
  Future<Either<Failure, void>> deactivateUser(String userId);

  /// Activate user (Admin only)
  Future<Either<Failure, void>> activateUser(String userId);

  /// Get all users with pagination
  Future<Either<Failure, List<UserModel>>> getUsers({
    UserRole? roleFilter,
    int limit = 20,
    String? lastUserId,
  });

  /// Get users by role
  Future<Either<Failure, List<UserModel>>> getUsersByRole(UserRole role);

  /// Search users
  Future<Either<Failure, List<UserModel>>> searchUsers(String query);

  /// Get user statistics
  Future<Either<Failure, UserStats>> getUserStats();

  /// Get all organizers
  Future<Either<Failure, List<UserModel>>> getOrganizers();

  /// Get all suppliers (users)
  Future<Either<Failure, List<UserModel>>> getSupplierUsers();

  /// Get account requests
  Future<Either<Failure, List<AccountRequestModel>>> getAccountRequests({
    RequestStatus? statusFilter,
  });

  /// Approve account request
  Future<Either<Failure, void>> approveAccountRequest(String requestId, String adminId);

  /// Reject account request
  Future<Either<Failure, void>> rejectAccountRequest(String requestId);
}

/// User statistics model
class UserStats {
  final int totalUsers;
  final int totalAdmins;
  final int totalOrganizers;
  final int totalSuppliers;
  final int totalExhibitors;
  final int totalVisitors;
  final int activeUsers;
  final int inactiveUsers;

  const UserStats({
    required this.totalUsers,
    required this.totalAdmins,
    required this.totalOrganizers,
    required this.totalSuppliers,
    required this.totalExhibitors,
    required this.totalVisitors,
    required this.activeUsers,
    required this.inactiveUsers,
  });
}
