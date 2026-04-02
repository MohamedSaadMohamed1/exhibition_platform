import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/booth_model.dart';

/// Booth repository interface
abstract class BoothRepository {
  /// Get all booths for an event
  Future<Either<Failure, List<BoothModel>>> getBoothsByEvent(
    String eventId, {
    int limit = 50,
    String? lastBoothId,
    BoothFilter? filter,
  });

  /// Get booth by ID
  Future<Either<Failure, BoothModel>> getBoothById(
    String eventId,
    String boothId,
  );

  /// Create booth (Organizer only)
  Future<Either<Failure, BoothModel>> createBooth({
    required String eventId,
    required String boothNumber,
    required BoothSize size,
    String? category,
    required double price,
    List<String>? amenities,
    String? description,
    BoothPosition? position,
    double? customWidth,
    double? customHeight,
  });

  /// Create multiple booths (Organizer only)
  Future<Either<Failure, List<BoothModel>>> createBooths({
    required String eventId,
    required List<BoothModel> booths,
  });

  /// Update booth (Organizer only)
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
    double? customWidth,
    double? customHeight,
  });

  /// Delete booth (Organizer only)
  Future<Either<Failure, void>> deleteBooth(String eventId, String boothId);

  /// Reserve booth with transaction (Exhibitor)
  Future<Either<Failure, BoothModel>> reserveBooth({
    required String eventId,
    required String boothId,
    required String userId,
  });

  /// Release booth reservation
  Future<Either<Failure, void>> releaseReservation({
    required String eventId,
    required String boothId,
    required String userId,
  });

  /// Book booth (after approval)
  Future<Either<Failure, BoothModel>> bookBooth({
    required String eventId,
    required String boothId,
    required String userId,
  });

  /// Release booth (cancel booking)
  Future<Either<Failure, void>> releaseBooth({
    required String eventId,
    required String boothId,
  });

  /// Get available booths count
  Future<Either<Failure, int>> getAvailableBoothsCount(String eventId);

  /// Get booth statistics for event
  Future<Either<Failure, BoothStats>> getBoothStats(String eventId);

  /// Watch booths for real-time updates
  Stream<List<BoothModel>> watchBooths(String eventId);

  /// Watch single booth
  Stream<BoothModel> watchBooth(String eventId, String boothId);

  /// Check and release expired reservations
  Future<Either<Failure, int>> releaseExpiredReservations(String eventId);
}

/// Booth statistics
class BoothStats {
  final int totalBooths;
  final int availableBooths;
  final int reservedBooths;
  final int bookedBooths;
  final double totalRevenue;
  final double occupancyRate;

  const BoothStats({
    required this.totalBooths,
    required this.availableBooths,
    required this.reservedBooths,
    required this.bookedBooths,
    required this.totalRevenue,
    required this.occupancyRate,
  });
}
