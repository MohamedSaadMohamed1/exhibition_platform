import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// Booking request model
class BookingRequest {
  final String id;
  final String eventId;
  final String boothId;
  final String exhibitorId;
  final String organizerId;
  final String? eventTitle;
  final String? boothNumber;
  final String? exhibitorName;
  final String? exhibitorPhone;
  final BookingStatus status;
  final String? message;
  final String? rejectionReason;
  final double? totalPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
  final DateTime? confirmedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;

  const BookingRequest({
    required this.id,
    required this.eventId,
    required this.boothId,
    required this.exhibitorId,
    required this.organizerId,
    this.eventTitle,
    this.boothNumber,
    this.exhibitorName,
    this.exhibitorPhone,
    this.status = BookingStatus.pending,
    this.message,
    this.rejectionReason,
    this.totalPrice,
    required this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.confirmedAt,
    this.rejectedAt,
    this.cancelledAt,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      boothId: json['boothId'] as String? ?? '',
      exhibitorId: json['exhibitorId'] as String? ?? '',
      organizerId: json['organizerId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String?,
      boothNumber: json['boothNumber'] as String?,
      exhibitorName: json['exhibitorName'] as String?,
      exhibitorPhone: json['exhibitorPhone'] as String?,
      status: _parseBookingStatus(json['status']),
      message: json['message'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
      approvedAt: json['approvedAt'] != null ? _parseDateTime(json['approvedAt']) : null,
      confirmedAt: json['confirmedAt'] != null ? _parseDateTime(json['confirmedAt']) : null,
      rejectedAt: json['rejectedAt'] != null ? _parseDateTime(json['rejectedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? _parseDateTime(json['cancelledAt']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static BookingStatus _parseBookingStatus(dynamic value) {
    if (value is String) {
      return BookingStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => BookingStatus.pending,
      );
    }
    return BookingStatus.pending;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'boothId': boothId,
      'exhibitorId': exhibitorId,
      'organizerId': organizerId,
      'eventTitle': eventTitle,
      'boothNumber': boothNumber,
      'exhibitorName': exhibitorName,
      'exhibitorPhone': exhibitorPhone,
      'status': status.name,
      'message': message,
      'rejectionReason': rejectionReason,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    };
  }

  factory BookingRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingRequest.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    return json;
  }

  bool get isPending => status == BookingStatus.pending;
  bool get isApproved => status == BookingStatus.approved;
  bool get isRejected => status == BookingStatus.rejected;
  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get canBeCancelled => isPending || isApproved;
  bool get canBeApproved => isPending;
  bool get canBeConfirmed => isApproved;

  String get statusDisplayText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending Review';
      case BookingStatus.approved:
        return 'Approved - Awaiting Payment';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  BookingRequest copyWith({
    String? id,
    String? eventId,
    String? boothId,
    String? exhibitorId,
    String? organizerId,
    String? eventTitle,
    String? boothNumber,
    String? exhibitorName,
    String? exhibitorPhone,
    BookingStatus? status,
    String? message,
    String? rejectionReason,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    DateTime? confirmedAt,
    DateTime? rejectedAt,
    DateTime? cancelledAt,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      boothId: boothId ?? this.boothId,
      exhibitorId: exhibitorId ?? this.exhibitorId,
      organizerId: organizerId ?? this.organizerId,
      eventTitle: eventTitle ?? this.eventTitle,
      boothNumber: boothNumber ?? this.boothNumber,
      exhibitorName: exhibitorName ?? this.exhibitorName,
      exhibitorPhone: exhibitorPhone ?? this.exhibitorPhone,
      status: status ?? this.status,
      message: message ?? this.message,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}

/// Booking stats model
class BookingStats {
  final int totalBookings;
  final int pendingBookings;
  final int approvedBookings;
  final int confirmedBookings;
  final int rejectedBookings;
  final int cancelledBookings;
  final double totalRevenue;

  const BookingStats({
    this.totalBookings = 0,
    this.pendingBookings = 0,
    this.approvedBookings = 0,
    this.confirmedBookings = 0,
    this.rejectedBookings = 0,
    this.cancelledBookings = 0,
    this.totalRevenue = 0.0,
  });

  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      totalBookings: json['totalBookings'] as int? ?? 0,
      pendingBookings: json['pendingBookings'] as int? ?? 0,
      approvedBookings: json['approvedBookings'] as int? ?? 0,
      confirmedBookings: json['confirmedBookings'] as int? ?? 0,
      rejectedBookings: json['rejectedBookings'] as int? ?? 0,
      cancelledBookings: json['cancelledBookings'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBookings': totalBookings,
      'pendingBookings': pendingBookings,
      'approvedBookings': approvedBookings,
      'confirmedBookings': confirmedBookings,
      'rejectedBookings': rejectedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
    };
  }
}
