import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/service_model.dart';
import '../../domain/repositories/supplier_repository.dart';

/// Implementation of SupplierRepository
class SupplierRepositoryImpl implements SupplierRepository {
  final FirebaseFirestore _firestore;

  SupplierRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _suppliersCollection =>
      _firestore.collection(FirestoreCollections.suppliers);

  @override
  Future<Either<Failure, List<SupplierModel>>> getSuppliers({
    SupplierFilter? filter,
    int limit = 20,
    String? lastSupplierId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _suppliersCollection
          .where('isActive', isEqualTo: true);

      // Apply filters
      if (filter != null) {
        if (filter.category != null) {
          query = query.where('categories', arrayContains: filter.category);
        }
        if (filter.minRating != null) {
          query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
        }
        if (filter.showOnlyVerified) {
          query = query.where('isVerified', isEqualTo: true);
        }
      }

      // Sort
      final sortBy = filter?.sortBy ?? SupplierSortBy.rating;
      final ascending = filter?.ascending ?? false;

      switch (sortBy) {
        case SupplierSortBy.rating:
          query = query.orderBy('rating', descending: !ascending);
          break;
        case SupplierSortBy.reviewCount:
          query = query.orderBy('reviewsCount', descending: !ascending);
          break;
        case SupplierSortBy.ordersCount:
          query = query.orderBy('ordersCount', descending: !ascending);
          break;
        case SupplierSortBy.name:
          query = query.orderBy('businessName', descending: !ascending);
          break;
        case SupplierSortBy.createdAt:
          query = query.orderBy('createdAt', descending: !ascending);
          break;
      }

      // Pagination
      if (lastSupplierId != null) {
        final lastDoc = await _suppliersCollection.doc(lastSupplierId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();

      return Right(suppliers);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, SupplierModel>> getSupplierById(String supplierId) async {
    try {
      final doc = await _suppliersCollection.doc(supplierId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure.withMessage('Supplier not found'));
      }

      return Right(SupplierModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, SupplierModel?>> getSupplierByUserId(String userId) async {
    try {
      final snapshot = await _suppliersCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      return Right(SupplierModel.fromFirestore(snapshot.docs.first));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, SupplierModel>> createSupplier(SupplierModel supplier) async {
    try {
      final docRef = _suppliersCollection.doc();
      final newSupplier = supplier.copyWith(id: docRef.id);

      await docRef.set(newSupplier.toFirestore());

      return Right(newSupplier);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, SupplierModel>> updateSupplier(SupplierModel supplier) async {
    try {
      await _suppliersCollection.doc(supplier.id).update(supplier.toUpdateMap());
      return Right(supplier);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(String supplierId) async {
    try {
      await _suppliersCollection.doc(supplierId).delete();
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<SupplierModel>>> getSuppliersByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _suppliersCollection
          .where('isActive', isEqualTo: true)
          .where('categories', arrayContains: category)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();

      return Right(suppliers);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<SupplierModel>>> searchSuppliers(
    String query, {
    int limit = 20,
  }) async {
    try {
      // Firestore doesn't support full-text search, so we use a simple prefix search
      final queryLower = query.toLowerCase();

      final snapshot = await _suppliersCollection
          .where('isActive', isEqualTo: true)
          .where('searchKeywords', arrayContains: queryLower)
          .limit(limit)
          .get();

      final suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();

      return Right(suppliers);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<SupplierModel>>> getFeaturedSuppliers({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _suppliersCollection
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();

      return Right(suppliers);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<SupplierModel>>> getTopRatedSuppliers({
    int limit = 10,
    double minRating = 4.0,
  }) async {
    try {
      final snapshot = await _suppliersCollection
          .where('isActive', isEqualTo: true)
          .where('rating', isGreaterThanOrEqualTo: minRating)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      final suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();

      return Right(suppliers);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplierRating({
    required String supplierId,
    required double newRating,
    required int totalReviews,
  }) async {
    try {
      await _suppliersCollection.doc(supplierId).update({
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
  Future<Either<Failure, void>> incrementOrdersCount(String supplierId) async {
    try {
      await _suppliersCollection.doc(supplierId).update({
        'ordersCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
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
      // Services are stored as a subcollection under each supplier
      final snapshot = await _suppliersCollection
          .doc(supplierId)
          .collection('services')
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
  Stream<SupplierModel> watchSupplier(String supplierId) {
    return _suppliersCollection.doc(supplierId).snapshots().map(
      (doc) => SupplierModel.fromFirestore(doc),
    );
  }

  @override
  Stream<List<SupplierModel>> watchSuppliers({SupplierFilter? filter}) {
    Query<Map<String, dynamic>> query = _suppliersCollection
        .where('isActive', isEqualTo: true);

    if (filter?.category != null) {
      query = query.where('categories', arrayContains: filter!.category);
    }

    return query.orderBy('rating', descending: true).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList(),
    );
  }

  @override
  Future<Either<Failure, List<String>>> getSupplierCategories() async {
    try {
      // Return predefined categories
      return Right(SupplierCategories.all);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
