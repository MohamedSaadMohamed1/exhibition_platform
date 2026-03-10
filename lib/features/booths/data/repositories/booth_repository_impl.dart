import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/booth_model.dart';
import '../../domain/repositories/booth_repository.dart';

/// Implementation of BoothRepository with transaction support
class BoothRepositoryImpl implements BoothRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  BoothRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _boothsCollection(String eventId) =>
      _firestore
          .collection(FirestoreCollections.events)
          .doc(eventId)
          .collection(FirestoreCollections.booths);

  @override
  Future<Either<Failure, List<BoothModel>>> getBoothsByEvent(
    String eventId, {
    int limit = 50,
    String? lastBoothId,
    BoothFilter? filter,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _boothsCollection(eventId).orderBy('boothNumber');

      // Apply filters
      if (filter != null) {
        if (filter.category != null) {
          query = query.where('category', isEqualTo: filter.category);
        }
        if (filter.size != null) {
          query = query.where('size', isEqualTo: filter.size!.value);
        }
        if (filter.status != null) {
          query = query.where('status', isEqualTo: filter.status!.value);
        }
        if (filter.showOnlyAvailable) {
          query = query.where('status', isEqualTo: BoothStatus.available.value);
        }
      }

      if (lastBoothId != null) {
        final lastDoc = await _boothsCollection(eventId).doc(lastBoothId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      var booths = snapshot.docs
          .map((doc) => BoothModel.fromFirestore(doc, eventId))
          .toList();

      // Apply client-side filters (price range)
      if (filter != null) {
        if (filter.minPrice != null) {
          booths = booths.where((b) => b.price >= filter.minPrice!).toList();
        }
        if (filter.maxPrice != null) {
          booths = booths.where((b) => b.price <= filter.maxPrice!).toList();
        }
      }

      return Right(booths);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BoothModel>> getBoothById(
    String eventId,
    String boothId,
  ) async {
    try {
      final doc = await _boothsCollection(eventId).doc(boothId).get();

      if (!doc.exists) {
        return Left(FirestoreFailure.notFound('Booth'));
      }

      return Right(BoothModel.fromFirestore(doc, eventId));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BoothModel>> createBooth({
    required String eventId,
    required String boothNumber,
    required BoothSize size,
    String? category,
    required double price,
    List<String>? amenities,
    String? description,
    BoothPosition? position,
  }) async {
    try {
      final boothId = _uuid.v4();

      final booth = BoothModel(
        id: boothId,
        eventId: eventId,
        boothNumber: boothNumber,
        size: size,
        category: category,
        price: price,
        status: BoothStatus.available,
        amenities: amenities ?? [],
        description: description,
        position: position,
        createdAt: DateTime.now(),
      );

      await _boothsCollection(eventId).doc(boothId).set(booth.toFirestore());

      // Update event booth count
      await _firestore
          .collection(FirestoreCollections.events)
          .doc(eventId)
          .update({
        'boothCount': FieldValue.increment(1),
      });

      return Right(booth);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<BoothModel>>> createBooths({
    required String eventId,
    required List<BoothModel> booths,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final booth in booths) {
        final boothRef = _boothsCollection(eventId).doc(booth.id);
        batch.set(boothRef, booth.toFirestore());
      }

      // Update event booth count
      batch.update(
        _firestore.collection(FirestoreCollections.events).doc(eventId),
        {'boothCount': FieldValue.increment(booths.length)},
      );

      await batch.commit();

      return Right(booths);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BoothModel>> updateBooth({
    required String eventId,
    required String boothId,
    String? boothNumber,
    BoothSize? size,
    String? category,
    double? price,
    List<String>? amenities,
    String? description,
    BoothPosition? position,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (boothNumber != null) updates['boothNumber'] = boothNumber;
      if (size != null) updates['size'] = size.value;
      if (category != null) updates['category'] = category;
      if (price != null) updates['price'] = price;
      if (amenities != null) updates['amenities'] = amenities;
      if (description != null) updates['description'] = description;
      if (position != null) updates['position'] = position.toJson();

      await _boothsCollection(eventId).doc(boothId).update(updates);

      final updatedDoc = await _boothsCollection(eventId).doc(boothId).get();
      return Right(BoothModel.fromFirestore(updatedDoc, eventId));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteBooth(
    String eventId,
    String boothId,
  ) async {
    try {
      await _boothsCollection(eventId).doc(boothId).delete();

      // Update event booth count
      await _firestore
          .collection(FirestoreCollections.events)
          .doc(eventId)
          .update({
        'boothCount': FieldValue.increment(-1),
      });

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BoothModel>> reserveBooth({
    required String eventId,
    required String boothId,
    required String userId,
  }) async {
    try {
      // Use transaction to prevent double booking
      final result = await _firestore.runTransaction<BoothModel>((transaction) async {
        final boothRef = _boothsCollection(eventId).doc(boothId);
        final boothDoc = await transaction.get(boothRef);

        if (!boothDoc.exists) {
          throw FirestoreFailure.notFound('Booth');
        }

        final booth = BoothModel.fromFirestore(boothDoc, eventId);

        // Check if booth is available
        if (!booth.isAvailable) {
          // Check if it's reserved but expired
          if (booth.isReserved && booth.isReservationExpired) {
            // Release the expired reservation and allow new reservation
          } else {
            throw BookingFailure.boothNotAvailable();
          }
        }

        // Reserve the booth
        transaction.update(boothRef, {
          'status': BoothStatus.reserved.value,
          'reservedBy': userId,
          'reservedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return booth.copyWith(
          status: BoothStatus.reserved,
          reservedBy: userId,
          reservedAt: DateTime.now(),
        );
      });

      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> releaseReservation({
    required String eventId,
    required String boothId,
    required String userId,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final boothRef = _boothsCollection(eventId).doc(boothId);
        final boothDoc = await transaction.get(boothRef);

        if (!boothDoc.exists) {
          throw FirestoreFailure.notFound('Booth');
        }

        final booth = BoothModel.fromFirestore(boothDoc, eventId);

        // Only the user who reserved can release
        if (booth.reservedBy != userId) {
          throw PermissionFailure.notOwner();
        }

        transaction.update(boothRef, {
          'status': BoothStatus.available.value,
          'reservedBy': null,
          'reservedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BoothModel>> bookBooth({
    required String eventId,
    required String boothId,
    required String userId,
  }) async {
    try {
      final result = await _firestore.runTransaction<BoothModel>((transaction) async {
        final boothRef = _boothsCollection(eventId).doc(boothId);
        final boothDoc = await transaction.get(boothRef);

        if (!boothDoc.exists) {
          throw FirestoreFailure.notFound('Booth');
        }

        final booth = BoothModel.fromFirestore(boothDoc, eventId);

        // Booth must be reserved by this user to book
        if (booth.reservedBy != userId) {
          throw BookingFailure.boothNotAvailable();
        }

        transaction.update(boothRef, {
          'status': BoothStatus.booked.value,
          'bookedBy': userId,
          'bookedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return booth.copyWith(
          status: BoothStatus.booked,
          bookedBy: userId,
          bookedAt: DateTime.now(),
        );
      });

      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> releaseBooth({
    required String eventId,
    required String boothId,
  }) async {
    try {
      await _boothsCollection(eventId).doc(boothId).update({
        'status': BoothStatus.available.value,
        'reservedBy': null,
        'reservedAt': null,
        'bookedBy': null,
        'bookedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getAvailableBoothsCount(String eventId) async {
    try {
      final snapshot = await _boothsCollection(eventId)
          .where('status', isEqualTo: BoothStatus.available.value)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BoothStats>> getBoothStats(String eventId) async {
    try {
      final snapshot = await _boothsCollection(eventId).get();

      int available = 0;
      int reserved = 0;
      int booked = 0;
      double totalRevenue = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = BoothStatus.fromString(data['status'] ?? 'available');
        final price = (data['price'] ?? 0).toDouble();

        switch (status) {
          case BoothStatus.available:
            available++;
            break;
          case BoothStatus.reserved:
            reserved++;
            break;
          case BoothStatus.booked:
          case BoothStatus.occupied:
            booked++;
            totalRevenue += price;
            break;
        }
      }

      final total = snapshot.docs.length;
      final occupancyRate = total > 0 ? (booked / total) * 100 : 0.0;

      return Right(BoothStats(
        totalBooths: total,
        availableBooths: available,
        reservedBooths: reserved,
        bookedBooths: booked,
        totalRevenue: totalRevenue,
        occupancyRate: occupancyRate,
      ));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<BoothModel>> watchBooths(String eventId) {
    return _boothsCollection(eventId)
        .orderBy('boothNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BoothModel.fromFirestore(doc, eventId))
          .toList();
    });
  }

  @override
  Stream<BoothModel> watchBooth(String eventId, String boothId) {
    return _boothsCollection(eventId).doc(boothId).snapshots().map((doc) {
      if (!doc.exists) {
        throw FirestoreFailure.notFound('Booth');
      }
      return BoothModel.fromFirestore(doc, eventId);
    });
  }

  @override
  Future<Either<Failure, int>> releaseExpiredReservations(String eventId) async {
    try {
      final expiryTime = DateTime.now().subtract(
        const Duration(minutes: AppConstants.boothReservationTimeout),
      );

      final snapshot = await _boothsCollection(eventId)
          .where('status', isEqualTo: BoothStatus.reserved.value)
          .where('reservedAt', isLessThan: Timestamp.fromDate(expiryTime))
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(0);
      }

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': BoothStatus.available.value,
          'reservedBy': null,
          'reservedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      return Right(snapshot.docs.length);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
