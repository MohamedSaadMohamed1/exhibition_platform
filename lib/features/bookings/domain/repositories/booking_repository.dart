import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/booking_model.dart';

/// Booking repository interface
abstract class BookingRepository {
  /// Create booking request (Exhibitor only)
  Future<Either<Failure, BookingRequest>> createBookingRequest({
    required String eventId,
    required String boothId,
    required String exhibitorId,
    required String organizerId,
    String? message,
    double? totalPrice,
  });

  /// Get booking request by ID
  Future<Either<Failure, BookingRequest>> getBookingById(String bookingId);

  /// Get bookings for exhibitor
  Future<Either<Failure, List<BookingRequest>>> getExhibitorBookings(
    String exhibitorId, {
    BookingStatus? status,
    int limit = 20,
    String? lastBookingId,
  });

  /// Get bookings for organizer (their events only)
  Future<Either<Failure, List<BookingRequest>>> getOrganizerBookings(
    String organizerId, {
    BookingStatus? status,
    String? eventId,
    int limit = 20,
    String? lastBookingId,
  });

  /// Get bookings for specific event
  Future<Either<Failure, List<BookingRequest>>> getEventBookings(
    String eventId, {
    BookingStatus? status,
    int limit = 20,
  });

  /// Approve booking (Organizer only)
  Future<Either<Failure, BookingRequest>> approveBooking(String bookingId);

  /// Reject booking (Organizer only)
  Future<Either<Failure, BookingRequest>> rejectBooking(
    String bookingId, {
    String? reason,
  });

  /// Confirm booking (after payment - Organizer)
  Future<Either<Failure, BookingRequest>> confirmBooking(String bookingId);

  /// Cancel booking (Exhibitor before approval, or Organizer)
  Future<Either<Failure, void>> cancelBooking(
    String bookingId, {
    required String cancelledBy,
    String? reason,
  });

  /// Check if exhibitor has pending booking for booth
  Future<Either<Failure, bool>> hasExistingBooking({
    required String exhibitorId,
    required String boothId,
  });

  /// Get booking statistics for organizer
  Future<Either<Failure, BookingStats>> getBookingStats(String organizerId);

  /// Watch bookings for real-time updates
  Stream<List<BookingRequest>> watchExhibitorBookings(String exhibitorId);

  /// Watch organizer bookings
  Stream<List<BookingRequest>> watchOrganizerBookings(String organizerId);

  /// Get all bookings (admin only)
  Future<Either<Failure, List<BookingRequest>>> getAllBookings({
    BookingStatus? status,
  });
}
