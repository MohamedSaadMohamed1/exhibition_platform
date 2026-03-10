import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:exhibition_platform/features/events/data/repositories/event_repository_impl.dart';
import 'package:exhibition_platform/features/events/domain/repositories/event_repository.dart';
import 'package:exhibition_platform/shared/models/event_model.dart';
import 'package:exhibition_platform/core/exceptions/app_exceptions.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late EventRepository eventRepository;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    eventRepository = EventRepositoryImpl(firestore: mockFirestore);
  });

  group('EventRepository', () {
    group('getEvents', () {
      test('returns list of events successfully', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

        when(() => mockDoc1.id).thenReturn('event-1');
        when(() => mockDoc1.data()).thenReturn(generateTestEventData(
          id: 'event-1',
          title: 'Event 1',
        ));

        when(() => mockDoc2.id).thenReturn('event-2');
        when(() => mockDoc2.data()).thenReturn(generateTestEventData(
          id: 'event-2',
          title: 'Event 2',
        ));

        // Act
        final result = await eventRepository.getEvents();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left: ${l.message}'),
          (r) {
            expect(r.length, equals(2));
            expect(r[0].title, equals('Event 1'));
            expect(r[1].title, equals('Event 2'));
          },
        );
      });

      test('returns empty list when no events found', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(() => mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await eventRepository.getEvents();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) => expect(r, isEmpty),
        );
      });

      test('returns failure when Firestore throws exception', () async {
        // Arrange
        final mockCollection = MockCollectionReference();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

        // Act
        final result = await eventRepository.getEvents();

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (l) => expect(l, isA<Failure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });
    });

    group('getEventById', () {
      test('returns event when found', () async {
        // Arrange
        const eventId = 'test-event-id';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn(eventId);
        when(() => mockDocSnapshot.data()).thenReturn(generateTestEventData(
          id: eventId,
          title: 'Test Event',
        ));

        // Act
        final result = await eventRepository.getEventById(eventId);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) {
            expect(r.id, equals(eventId));
            expect(r.title, equals('Test Event'));
          },
        );
      });

      test('returns failure when event not found', () async {
        // Arrange
        const eventId = 'nonexistent-event-id';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await eventRepository.getEventById(eventId);

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (l) => expect(l, isA<NotFoundFailure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });
    });

    group('getEventsByOrganizer', () {
      test('returns events for organizer', () async {
        // Arrange
        const organizerId = 'test-organizer-id';
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.where('organizerId', isEqualTo: organizerId))
            .thenReturn(mockQuery);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
            .thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);
        when(() => mockDoc.id).thenReturn('event-1');
        when(() => mockDoc.data()).thenReturn(generateTestEventData(
          id: 'event-1',
          organizerId: organizerId,
        ));

        // Act
        final result = await eventRepository.getEventsByOrganizer(organizerId);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) {
            expect(r.length, equals(1));
            expect(r[0].organizerId, equals(organizerId));
          },
        );
      });
    });

    group('getUpcomingEvents', () {
      test('returns upcoming events', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockQuerySnapshot = MockQuerySnapshot();
        final mockDoc = MockQueryDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(),
                isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        when(() => mockQuerySnapshot.docs).thenReturn([mockDoc]);
        when(() => mockDoc.id).thenReturn('upcoming-event');
        when(() => mockDoc.data()).thenReturn(generateTestEventData(
          id: 'upcoming-event',
          title: 'Upcoming Event',
        ));

        // Act
        final result = await eventRepository.getUpcomingEvents(limit: 5);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) => expect(r.isNotEmpty, isTrue),
        );
      });
    });

    group('createEvent', () {
      test('creates event successfully', () async {
        // Arrange
        final event = EventModel(
          id: '',
          title: 'New Event',
          description: 'Description',
          organizerId: 'org-1',
          location: 'Location',
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 10)),
          createdAt: DateTime.now(),
        );

        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.add(any())).thenAnswer((_) async => mockDocRef);
        when(() => mockDocRef.id).thenReturn('new-event-id');
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn('new-event-id');
        when(() => mockDocSnapshot.data()).thenReturn({
          ...event.toJson(),
          'id': 'new-event-id',
        });

        // Act
        final result = await eventRepository.createEvent(event);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) {
            expect(r.id, equals('new-event-id'));
            expect(r.title, equals('New Event'));
          },
        );

        verify(() => mockCollection.add(any())).called(1);
      });
    });

    group('updateEvent', () {
      test('updates event successfully', () async {
        // Arrange
        const eventId = 'event-to-update';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn(eventId);
        when(() => mockDocSnapshot.data()).thenReturn(generateTestEventData(
          id: eventId,
          title: 'Updated Event',
        ));

        final event = EventModel(
          id: eventId,
          title: 'Updated Event',
          description: 'Updated description',
          organizerId: 'org-1',
          location: 'New Location',
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 10)),
          createdAt: DateTime.now(),
        );

        // Act
        final result = await eventRepository.updateEvent(event);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) => expect(r.title, equals('Updated Event')),
        );

        verify(() => mockDocRef.update(any())).called(1);
      });
    });

    group('deleteEvent', () {
      test('deletes event successfully', () async {
        // Arrange
        const eventId = 'event-to-delete';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.delete()).thenAnswer((_) async {});

        // Act
        final result = await eventRepository.deleteEvent(eventId);

        // Assert
        expect(result, isA<Right>());
        verify(() => mockDocRef.delete()).called(1);
      });
    });

    group('markInterested', () {
      test('marks user as interested successfully', () async {
        // Arrange
        const eventId = 'test-event-id';
        const userId = 'test-user-id';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockSubCollection = MockCollectionReference();
        final mockSubDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.collection('interested_users'))
            .thenReturn(mockSubCollection);
        when(() => mockSubCollection.doc(userId)).thenReturn(mockSubDocRef);
        when(() => mockSubDocRef.set(any())).thenAnswer((_) async {});
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        final result = await eventRepository.markInterested(
          eventId: eventId,
          userId: userId,
        );

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSubDocRef.set(any())).called(1);
      });
    });

    group('unmarkInterested', () {
      test('removes user interest successfully', () async {
        // Arrange
        const eventId = 'test-event-id';
        const userId = 'test-user-id';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockSubCollection = MockCollectionReference();
        final mockSubDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.collection('interested_users'))
            .thenReturn(mockSubCollection);
        when(() => mockSubCollection.doc(userId)).thenReturn(mockSubDocRef);
        when(() => mockSubDocRef.delete()).thenAnswer((_) async {});
        when(() => mockDocRef.update(any())).thenAnswer((_) async {});

        // Act
        final result = await eventRepository.unmarkInterested(
          eventId: eventId,
          userId: userId,
        );

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSubDocRef.delete()).called(1);
      });
    });

    group('isUserInterested', () {
      test('returns true when user is interested', () async {
        // Arrange
        const eventId = 'test-event-id';
        const userId = 'test-user-id';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockSubCollection = MockCollectionReference();
        final mockSubDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.collection('interested_users'))
            .thenReturn(mockSubCollection);
        when(() => mockSubCollection.doc(userId)).thenReturn(mockSubDocRef);
        when(() => mockSubDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);

        // Act
        final result = await eventRepository.isUserInterested(
          eventId: eventId,
          userId: userId,
        );

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) => expect(r, isTrue),
        );
      });

      test('returns false when user is not interested', () async {
        // Arrange
        const eventId = 'test-event-id';
        const userId = 'test-user-id';
        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockSubCollection = MockCollectionReference();
        final mockSubDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('events')).thenReturn(mockCollection);
        when(() => mockCollection.doc(eventId)).thenReturn(mockDocRef);
        when(() => mockDocRef.collection('interested_users'))
            .thenReturn(mockSubCollection);
        when(() => mockSubCollection.doc(userId)).thenReturn(mockSubDocRef);
        when(() => mockSubDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(false);

        // Act
        final result = await eventRepository.isUserInterested(
          eventId: eventId,
          userId: userId,
        );

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) => expect(r, isFalse),
        );
      });
    });
  });
}
