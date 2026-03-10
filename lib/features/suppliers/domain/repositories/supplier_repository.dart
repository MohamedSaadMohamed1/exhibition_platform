import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/service_model.dart';

/// Supplier repository interface
abstract class SupplierRepository {
  /// Get all suppliers with optional filter
  Future<Either<Failure, List<SupplierModel>>> getSuppliers({
    SupplierFilter? filter,
    int limit = 20,
    String? lastSupplierId,
  });

  /// Get supplier by ID
  Future<Either<Failure, SupplierModel>> getSupplierById(String supplierId);

  /// Get supplier by user ID
  Future<Either<Failure, SupplierModel?>> getSupplierByUserId(String userId);

  /// Create supplier profile
  Future<Either<Failure, SupplierModel>> createSupplier(SupplierModel supplier);

  /// Update supplier profile
  Future<Either<Failure, SupplierModel>> updateSupplier(SupplierModel supplier);

  /// Delete supplier profile
  Future<Either<Failure, void>> deleteSupplier(String supplierId);

  /// Get suppliers by category
  Future<Either<Failure, List<SupplierModel>>> getSuppliersByCategory(
    String category, {
    int limit = 20,
  });

  /// Search suppliers
  Future<Either<Failure, List<SupplierModel>>> searchSuppliers(
    String query, {
    int limit = 20,
  });

  /// Get featured suppliers
  Future<Either<Failure, List<SupplierModel>>> getFeaturedSuppliers({
    int limit = 10,
  });

  /// Get top rated suppliers
  Future<Either<Failure, List<SupplierModel>>> getTopRatedSuppliers({
    int limit = 10,
    double minRating = 4.0,
  });

  /// Update supplier rating
  Future<Either<Failure, void>> updateSupplierRating({
    required String supplierId,
    required double newRating,
    required int totalReviews,
  });

  /// Increment orders count
  Future<Either<Failure, void>> incrementOrdersCount(String supplierId);

  /// Get supplier services
  Future<Either<Failure, List<ServiceModel>>> getSupplierServices(
    String supplierId, {
    int limit = 20,
  });

  /// Watch supplier for real-time updates
  Stream<SupplierModel> watchSupplier(String supplierId);

  /// Watch suppliers list
  Stream<List<SupplierModel>> watchSuppliers({SupplierFilter? filter});

  /// Get supplier categories
  Future<Either<Failure, List<String>>> getSupplierCategories();
}
