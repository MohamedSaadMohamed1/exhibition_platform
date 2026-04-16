import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/event_model.dart';

/// Event repository interface
abstract class EventRepository {
  /// Get all published events with pagination
  Future<Either<Failure, List<EventModel>>> getEvents({
    int limit = 20,
    String? lastEventId,
    EventFilter? filter,
  });

  /// Get event by ID
  Future<Either<Failure, EventModel>> getEventById(String eventId);

  /// Get events by organizer
  Future<Either<Failure, List<EventModel>>> getEventsByOrganizer(
    String organizerId, {
    int limit = 20,
    String? lastEventId,
  });

  /// Create event (Organizer only)
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
    String? planPic,
  });

  /// Update event (Organizer only - own events)
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
    String? planPic,
  });

  /// Delete event (Organizer only - own events)
  Future<Either<Failure, void>> deleteEvent(String eventId);

  /// Publish event
  Future<Either<Failure, void>> publishEvent(String eventId);

  /// Cancel event
  Future<Either<Failure, void>> cancelEvent(String eventId);

  /// Toggle interest in event
  Future<Either<Failure, bool>> toggleInterest({
    required String eventId,
    required String userId,
  });

  /// Check if user is interested in event
  Future<Either<Failure, bool>> isUserInterested({
    required String eventId,
    required String userId,
  });

  /// Get user's interested events
  Future<Either<Failure, List<EventModel>>> getInterestedEvents(String userId);

  /// Stream of event updates
  Stream<EventModel> watchEvent(String eventId);

  /// Stream of events list
  Stream<List<EventModel>> watchEvents({EventFilter? filter});

  /// Search events
  Future<Either<Failure, List<EventModel>>> searchEvents(String query);

  /// Get upcoming events
  Future<Either<Failure, List<EventModel>>> getUpcomingEvents({int limit = 10});

  /// Get event categories
  Future<Either<Failure, List<String>>> getEventCategories();

  /// Get all events regardless of status (admin only)
  Future<Either<Failure, List<EventModel>>> getAllEvents({EventStatus? status});
}
