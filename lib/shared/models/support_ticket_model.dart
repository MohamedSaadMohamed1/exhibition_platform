import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String? userEmail;
  final String subject;
  final String message;
  final String status; // open | inProgress | resolved
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userEmail,
    required this.subject,
    required this.message,
    this.status = 'open',
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicketModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      userPhone: data['userPhone'] as String? ?? '',
      userEmail: data['userEmail'] as String?,
      subject: data['subject'] as String? ?? '',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      adminNotes: data['adminNotes'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? _parseDateTime(data['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
    String? subject,
    String? message,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
