import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/service_model.dart';
import '../../domain/repositories/service_repository.dart';

/// Implementation of ServiceRepository
class ServiceRepositoryImpl implements ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _servicesCollection =>
      _firestore.collection(FirestoreCollections.services);

  @override
  Future<Either<Failure, List<ServiceModel>>> getServices({
    ServiceFilter? filter,
    int limit = 20,
    String? lastServiceId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _servicesCollection
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (filter != null) {
        if (filter.supplierId != null) {
          query = query.where('supplierId', isEqualTo: filter.supplierId);
        }
        if (filter.category != null) {
          query = query.where('category', isEqualTo: filter.category);
        }
        if (filter.minRating != null) {
          query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
        }
      }

      // Sort
      final sortBy = filter?.sortBy ?? ServiceSortBy.createdAt;
      final ascending = filter?.ascending ?? false;

      switch (sortBy) {
        case ServiceSortBy.createdAt:
          query = query.orderBy('createdAt', descending: !ascending);
          break;
        case ServiceSortBy.title:
          query = query.orderBy('title', descending: !ascending);
          break;
        case ServiceSortBy.price:
          query = query.orderBy('price', descending: !ascending);
          break;
        case ServiceSortBy.rating:
          query = query.orderBy('rating', descending: !ascending);
          break;
        case ServiceSortBy.ordersCount:
          query = query.orderBy('ordersCount', descending: !ascending);
          break;
      }

      // Pagination
      if (lastServiceId != null) {
        final lastDoc = await _servicesCollection.doc(lastServiceId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> getServiceById(String serviceId) async {
    try {
      final doc = await _servicesCollection.doc(serviceId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure('Service not found'));
      }

      return Right(ServiceModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getSupplierServices(
    String supplierId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _servicesCollection
          .where('supplierId', isEqualTo: supplierId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> createService(ServiceModel service) async {
    try {
      final docRef = _servicesCollection.doc();
      final newService = service.copyWith(id: docRef.id);

      await docRef.set(newService.toFirestore());

      return Right(newService);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> updateService(ServiceModel service) async {
    try {
      await _servicesCollection.doc(service.id).update(service.toUpdateMap());
      return Right(service);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).delete();
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleServiceStatus(
    String serviceId, {
    required bool isActive,
  }) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getServicesByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> searchServices(
    String query, {
    int limit = 20,
  }) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('searchKeywords', arrayContains: queryLower)
          .limit(limit)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getFeaturedServices({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('ordersCount', descending: true)
          .limit(limit)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> getTopRatedServices({
    int limit = 10,
    double minRating = 4.0,
  }) async {
    try {
      final snapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('rating', isGreaterThanOrEqualTo: minRating)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();

      return Right(services);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateServiceRating({
    required String serviceId,
    required double newRating,
    required int totalReviews,
  }) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'rating': newRating,
        'reviewsCount': totalReviews,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> incrementOrdersCount(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'ordersCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<ServiceModel> watchService(String serviceId) {
    return _servicesCollection.doc(serviceId).snapshots().map(
      (doc) => ServiceModel.fromFirestore(doc),
    );
  }

  @override
  Stream<List<ServiceModel>> watchSupplierServices(String supplierId) {
    return _servicesCollection
        .where('supplierId', isEqualTo: supplierId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  @override
  Future<Either<Failure, List<String>>> getServiceCategories() async {
    try {
      return Right(ServiceCategories.all);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
