import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/service_model.dart';

/// Service repository interface
abstract class ServiceRepository {
  /// Get all services with optional filter
  Future<Either<Failure, List<ServiceModel>>> getServices({
    ServiceFilter? filter,
    int limit = 20,
    String? lastServiceId,
  });

  /// Get service by ID
  Future<Either<Failure, ServiceModel>> getServiceById(String serviceId);

  /// Get services by supplier
  Future<Either<Failure, List<ServiceModel>>> getSupplierServices(
    String supplierId, {
    int limit = 20,
  });

  /// Create a service
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service);

  /// Update a service
  Future<Either<Failure, ServiceModel>> updateService(ServiceModel service);

  /// Delete a service
  Future<Either<Failure, void>> deleteService(String serviceId);

  /// Toggle service active status
  Future<Either<Failure, void>> toggleServiceStatus(
    String serviceId, {
    required bool isActive,
  });

  /// Get services by category
  Future<Either<Failure, List<ServiceModel>>> getServicesByCategory(
    String category, {
    int limit = 20,
  });

  /// Search services
  Future<Either<Failure, List<ServiceModel>>> searchServices(
    String query, {
    int limit = 20,
  });

  /// Get featured services
  Future<Either<Failure, List<ServiceModel>>> getFeaturedServices({
    int limit = 10,
  });

  /// Get top rated services
  Future<Either<Failure, List<ServiceModel>>> getTopRatedServices({
    int limit = 10,
    double minRating = 4.0,
  });

  /// Update service rating
  Future<Either<Failure, void>> updateServiceRating({
    required String serviceId,
    required double newRating,
    required int totalReviews,
  });

  /// Increment orders count
  Future<Either<Failure, void>> incrementOrdersCount(String serviceId);

  /// Watch service for real-time updates
  Stream<ServiceModel> watchService(String serviceId);

  /// Watch services by supplier
  Stream<List<ServiceModel>> watchSupplierServices(String supplierId);

  /// Get service categories
  Future<Either<Failure, List<String>>> getServiceCategories();
}
