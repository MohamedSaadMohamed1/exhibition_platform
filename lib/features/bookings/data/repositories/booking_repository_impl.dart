import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/booking_model.dart';
import '../../domain/repositories/booking_repository.dart';

/// Implementation of BookingRepository
class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  BookingRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection(FirestoreCollections.bookingRequests);

  DocumentReference<Map<String, dynamic>> _boothRef(
          String eventId, String boothId) =>
      _firestore
          .collection(FirestoreCollections.events)
          .doc(eventId)
          .collection(FirestoreCollections.booths)
          .doc(boothId);

  @override
  Future<Either<Failure, BookingRequest>> createBookingRequest({
    required String eventId,
    required String boothId,
    required String exhibitorId,
    required String organizerId,
    String? message,
    double? totalPrice,
  }) async {
    try {
      // Check for existing pending booking
      final existingResult = await hasExistingBooking(
        exhibitorId: exhibitorId,
        boothId: boothId,
      );

      if (existingResult.isRight() && existingResult.getOrElse(() => false)) {
        return Left(BookingFailure.alreadyBooked());
      }

      // Use transaction to reserve booth and create booking atomically
      final booking = await _firestore.runTransaction<BookingRequest>((transaction) async {
        final boothDoc = await transaction.get(_boothRef(eventId, boothId));

        if (!boothDoc.exists) {
          throw FirestoreFailure.notFound('Booth');
        }

        final boothData = boothDoc.data()!;
        final status = BoothStatus.fromString(boothData['status'] ?? 'available');

        // Check if booth is available or has expired reservation
        if (status != BoothStatus.available) {
          if (status == BoothStatus.reserved) {
            final reservedAt = (boothData['reservedAt'] as Timestamp?)?.toDate();
            if (reservedAt != null) {
              final expiryTime = reservedAt.add(
                const Duration(minutes: AppConstants.boothReservationTimeout),
              );
              if (DateTime.now().isBefore(expiryTime)) {
                throw BookingFailure.boothNotAvailable();
              }
            }
          } else {
            throw BookingFailure.boothNotAvailable();
          }
        }

        // Reserve the booth
        transaction.update(_boothRef(eventId, boothId), {
          'status': BoothStatus.reserved.value,
          'reservedBy': exhibitorId,
          'reservedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create booking request
        final bookingId = _uuid.v4();
        final bookingRequest = BookingRequest(
          id: bookingId,
          eventId: eventId,
          boothId: boothId,
          exhibitorId: exhibitorId,
          organizerId: organizerId,
          status: BookingStatus.pending,
          message: message,
          totalPrice: totalPrice ?? boothData['price']?.toDouble(),
          boothNumber: boothData['boothNumber'],
          createdAt: DateTime.now(),
        );

        transaction.set(
          _bookingsCollection.doc(bookingId),
          bookingRequest.toFirestore(),
        );

        return bookingRequest;
      });

      return Right(booking);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> getBookingById(
    String bookingId,
  ) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();

      if (!doc.exists) {
        return Left(FirestoreFailure.notFound('Booking'));
      }

      return Right(BookingRequest.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookingRequest>>> getExhibitorBookings(
    String exhibitorId, {
    BookingStatus? status,
    int limit = 20,
    String? lastBookingId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _bookingsCollection
          .where('exhibitorId', isEqualTo: exhibitorId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      if (lastBookingId != null) {
        final lastDoc = await _bookingsCollection.doc(lastBookingId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final bookings = snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookingRequest>>> getOrganizerBookings(
    String organizerId, {
    BookingStatus? status,
    String? eventId,
    int limit = 20,
    String? lastBookingId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _bookingsCollection
          .where('organizerId', isEqualTo: organizerId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      if (eventId != null) {
        query = query.where('eventId', isEqualTo: eventId);
      }

      if (lastBookingId != null) {
        final lastDoc = await _bookingsCollection.doc(lastBookingId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final bookings = snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookingRequest>>> getEventBookings(
    String eventId, {
    BookingStatus? status,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _bookingsCollection
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final bookings = snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> approveBooking(
    String bookingId,
  ) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': BookingStatus.approved.value,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await _bookingsCollection.doc(bookingId).get();
      return Right(BookingRequest.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> rejectBooking(
    String bookingId, {
    String? reason,
  }) async {
    try {
      // Get booking to release booth
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = BookingRequest.fromFirestore(bookingDoc);

      // Use transaction to update booking and release booth
      await _firestore.runTransaction((transaction) async {
        // Update booking status
        transaction.update(_bookingsCollection.doc(bookingId), {
          'status': BookingStatus.rejected.value,
          'rejectionReason': reason,
          'rejectedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Release the booth
        transaction.update(_boothRef(booking.eventId, booking.boothId), {
          'status': BoothStatus.available.value,
          'reservedBy': null,
          'reservedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      final updatedDoc = await _bookingsCollection.doc(bookingId).get();
      return Right(BookingRequest.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BookingRequest>> confirmBooking(
    String bookingId,
  ) async {
    try {
      // Get booking to confirm booth
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = BookingRequest.fromFirestore(bookingDoc);

      // Use transaction to update booking and booth
      await _firestore.runTransaction((transaction) async {
        // Update booking status
        transaction.update(_bookingsCollection.doc(bookingId), {
          'status': BookingStatus.confirmed.value,
          'confirmedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Book the booth
        transaction.update(_boothRef(booking.eventId, booking.boothId), {
          'status': BoothStatus.booked.value,
          'bookedBy': booking.exhibitorId,
          'bookedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      final updatedDoc = await _bookingsCollection.doc(bookingId).get();
      return Right(BookingRequest.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(
    String bookingId, {
    required String cancelledBy,
    String? reason,
  }) async {
    try {
      // Get booking to check if it can be cancelled
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = BookingRequest.fromFirestore(bookingDoc);

      if (!booking.canBeCancelled) {
        return Left(BookingFailure.cannotCancel());
      }

      // Use transaction to update booking and release booth
      await _firestore.runTransaction((transaction) async {
        transaction.update(_bookingsCollection.doc(bookingId), {
          'status': BookingStatus.cancelled.value,
          'cancelledAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Release the booth
        transaction.update(_boothRef(booking.eventId, booking.boothId), {
          'status': BoothStatus.available.value,
          'reservedBy': null,
          'reservedAt': null,
          'bookedBy': null,
          'bookedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasExistingBooking({
    required String exhibitorId,
    required String boothId,
  }) async {
    try {
      final snapshot = await _bookingsCollection
          .where('exhibitorId', isEqualTo: exhibitorId)
          .where('boothId', isEqualTo: boothId)
          .where('status', whereIn: [
            BookingStatus.pending.value,
            BookingStatus.approved.value,
            BookingStatus.confirmed.value,
          ])
          .limit(1)
          .get();

      return Right(snapshot.docs.isNotEmpty);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, BookingStats>> getBookingStats(
    String organizerId,
  ) async {
    try {
      final snapshot = await _bookingsCollection
          .where('organizerId', isEqualTo: organizerId)
          .get();

      int pending = 0;
      int approved = 0;
      int confirmed = 0;
      int rejected = 0;
      int cancelled = 0;
      double totalRevenue = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = BookingStatus.fromString(data['status'] ?? 'pending');
        final price = (data['totalPrice'] ?? 0).toDouble();

        switch (status) {
          case BookingStatus.pending:
            pending++;
            break;
          case BookingStatus.approved:
            approved++;
            break;
          case BookingStatus.confirmed:
            confirmed++;
            totalRevenue += price;
            break;
          case BookingStatus.rejected:
            rejected++;
            break;
          case BookingStatus.cancelled:
            cancelled++;
            break;
        }
      }

      return Right(BookingStats(
        totalBookings: snapshot.docs.length,
        pendingBookings: pending,
        approvedBookings: approved,
        confirmedBookings: confirmed,
        rejectedBookings: rejected,
        cancelledBookings: cancelled,
        totalRevenue: totalRevenue,
      ));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<List<BookingRequest>> watchExhibitorBookings(String exhibitorId) {
    return _bookingsCollection
        .where('exhibitorId', isEqualTo: exhibitorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<BookingRequest>> watchOrganizerBookings(String organizerId) {
    return _bookingsCollection
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<BookingRequest>>> getAllBookings({
    BookingStatus? status,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _bookingsCollection.orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }

      final snapshot = await query.limit(200).get();
      final bookings = snapshot.docs
          .map((doc) => BookingRequest.fromFirestore(doc))
          .toList();

      return Right(bookings);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
