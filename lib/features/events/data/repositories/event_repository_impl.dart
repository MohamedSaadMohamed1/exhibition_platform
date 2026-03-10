import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/event_model.dart';
import '../../domain/repositories/event_repository.dart';

/// Implementation of EventRepository
class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  EventRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _eventsCollection =>
      _firestore.collection(FirestoreCollections.events);

  CollectionReference<Map<String, dynamic>> get _interestsCollection =>
      _firestore.collection(FirestoreCollections.interests);

  @override
  Future<Either<Failure, List<EventModel>>> getEvents({
    int limit = 20,
    String? lastEventId,
    EventFilter? filter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _eventsCollection
          .where('status', isEqualTo: EventStatus.published.value)
          .orderBy('startDate', descending: false);

      // Apply filters
      if (filter != null) {
        if (filter.category != null) {
          query = query.where('category', isEqualTo: filter.category);
        }
        if (filter.location != null) {
          query = query.where('location', isEqualTo: filter.location);
        }
        if (!filter.showPastEvents) {
          query = query.where('endDate', isGreaterThan: Timestamp.now());
        }
      }

      if (lastEventId != null) {
        final lastDoc = await _eventsCollection.doc(lastEventId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      return Right(events);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, EventModel>> getEventById(String eventId) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get();

      if (!doc.exists) {
        return Left(FirestoreFailure.notFound('Event'));
      }

      return Right(EventModel.fromFirestore(doc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<EventModel>>> getEventsByOrganizer(
    String organizerId, {
    int limit = 20,
    String? lastEventId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _eventsCollection
          .where('organizerId', isEqualTo: organizerId)
          .orderBy('createdAt', descending: true);

      if (lastEventId != null) {
        final lastDoc = await _eventsCollection.doc(lastEventId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      return Right(events);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, EventModel>> createEvent({
    required String title,
    required String description,
    required String location,
    String? address,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> tags,
    required List<String> images,
    required String organizerId,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final eventId = _uuid.v4();

      final event = EventModel(
        id: eventId,
        title: title,
        description: description,
        location: location,
        address: address,
        startDate: startDate,
        endDate: endDate,
        tags: tags,
        images: images,
        organizerId: organizerId,
        category: category,
        latitude: latitude,
        longitude: longitude,
        status: EventStatus.draft,
        interestedCount: 0,
        boothCount: 0,
        createdAt: DateTime.now(),
      );

      await _eventsCollection.doc(eventId).set(event.toFirestore());

      return Right(event);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, EventModel>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    String? address,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    List<String>? images,
    String? category,
    EventStatus? status,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (location != null) updates['location'] = location;
      if (address != null) updates['address'] = address;
      if (startDate != null) updates['startDate'] = Timestamp.fromDate(startDate);
      if (endDate != null) updates['endDate'] = Timestamp.fromDate(endDate);
      if (tags != null) updates['tags'] = tags;
      if (images != null) updates['images'] = images;
      if (category != null) updates['category'] = category;
      if (status != null) updates['status'] = status.value;

      await _eventsCollection.doc(eventId).update(updates);

      final updatedDoc = await _eventsCollection.doc(eventId).get();
      return Right(EventModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      // Delete event and all its subcollections (booths, etc.)
      final batch = _firestore.batch();

      // Delete booths
      final boothsSnapshot = await _eventsCollection
          .doc(eventId)
          .collection('booths')
          .get();

      for (final doc in boothsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete event
      batch.delete(_eventsCollection.doc(eventId));

      // Delete related interests
      final interestsSnapshot = await _interestsCollection
          .where('eventId', isEqualTo: eventId)
          .get();

      for (final doc in interestsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> publishEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.published.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'status': EventStatus.cancelled.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> toggleInterest({
    required String eventId,
    required String userId,
  }) async {
    try {
      final interestId = '${userId}_$eventId';
      final interestDoc = await _interestsCollection.doc(interestId).get();

      if (interestDoc.exists) {
        // Remove interest
        await _firestore.runTransaction((transaction) async {
          transaction.delete(_interestsCollection.doc(interestId));
          transaction.update(_eventsCollection.doc(eventId), {
            'interestedCount': FieldValue.increment(-1),
          });
        });
        return const Right(false);
      } else {
        // Add interest
        await _firestore.runTransaction((transaction) async {
          transaction.set(_interestsCollection.doc(interestId), {
            'userId': userId,
            'eventId': eventId,
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(_eventsCollection.doc(eventId), {
            'interestedCount': FieldValue.increment(1),
          });
        });
        return const Right(true);
      }
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isUserInterested({
    required String eventId,
    required String userId,
  }) async {
    try {
      final interestId = '${userId}_$eventId';
      final doc = await _interestsCollection.doc(interestId).get();
      return Right(doc.exists);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<EventModel>>> getInterestedEvents(
    String userId,
  ) async {
    try {
      final interestsSnapshot = await _interestsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final eventIds = interestsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toList();

      if (eventIds.isEmpty) {
        return const Right([]);
      }

      // Fetch events in batches of 10 (Firestore limitation)
      final events = <EventModel>[];
      for (var i = 0; i < eventIds.length; i += 10) {
        final batchIds = eventIds.skip(i).take(10).toList();
        final eventsSnapshot = await _eventsCollection
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        events.addAll(
          eventsSnapshot.docs.map((doc) => EventModel.fromFirestore(doc)),
        );
      }

      return Right(events);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<EventModel> watchEvent(String eventId) {
    return _eventsCollection.doc(eventId).snapshots().map((doc) {
      if (!doc.exists) {
        throw FirestoreFailure.notFound('Event');
      }
      return EventModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<EventModel>> watchEvents({EventFilter? filter}) {
    Query<Map<String, dynamic>> query = _eventsCollection
        .where('status', isEqualTo: EventStatus.published.value)
        .orderBy('startDate', descending: false);

    if (filter != null && !filter.showPastEvents) {
      query = query.where('endDate', isGreaterThan: Timestamp.now());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<Either<Failure, List<EventModel>>> searchEvents(String query) async {
    try {
      // Note: Firestore doesn't support full-text search
      // For production, use Algolia or ElasticSearch
      final snapshot = await _eventsCollection
          .where('status', isEqualTo: EventStatus.published.value)
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      return Right(events);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<EventModel>>> getUpcomingEvents({
    int limit = 10,
  }) async {
    try {
      final snapshot = await _eventsCollection
          .where('status', isEqualTo: EventStatus.published.value)
          .where('startDate', isGreaterThan: Timestamp.now())
          .orderBy('startDate')
          .limit(limit)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

      return Right(events);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getEventCategories() async {
    try {
      // In production, this could be a separate collection
      // For now, return predefined categories
      return const Right([
        'Technology',
        'Fashion',
        'Food & Beverage',
        'Art & Design',
        'Health & Wellness',
        'Education',
        'Business',
        'Entertainment',
        'Sports',
        'Other',
      ]);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
