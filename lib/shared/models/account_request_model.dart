import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// Model representing a request to become an Organizer or Supplier
class AccountRequestModel {
  final String id;
  final String userId; // Empty string for unauthenticated submissions
  final String name;
  final String phone;
  final String? email;
  final UserRole requestedRole; // Expected to be organizer or supplier
  final String? companyName;
  final String? notes;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AccountRequestModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.phone,
    this.email,
    required this.requestedRole,
    this.companyName,
    this.notes,
    this.status = RequestStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  factory AccountRequestModel.fromJson(Map<String, dynamic> json) {
    return AccountRequestModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      requestedRole: _parseUserRole(json['requestedRole']),
      companyName: json['companyName'] as String?,
      notes: json['notes'] as String?,
      status: RequestStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  static UserRole _parseUserRole(dynamic value) {
    if (value is String) {
      return UserRole.values.firstWhere(
        (e) => e.name == value,
        orElse: () => UserRole.visitor,
      );
    }
    return UserRole.visitor;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'requestedRole': requestedRole.name,
      'companyName': companyName,
      'notes': notes,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory AccountRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountRequestModel.fromJson({
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

  AccountRequestModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    UserRole? requestedRole,
    String? companyName,
    String? notes,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      requestedRole: requestedRole ?? this.requestedRole,
      companyName: companyName ?? this.companyName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
