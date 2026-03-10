import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';

/// User model representing a user in the system
class UserModel {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? profileImage;
  final String? email;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.profileImage,
    this.email,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: _parseUserRole(json['role']),
      profileImage: json['profileImage'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
      fcmToken: json['fcmToken'] as String?,
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
      'name': name,
      'phone': phone,
      'role': role.name,
      'profileImage': profileImage,
      'email': email,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
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

  bool get isAdmin => role == UserRole.admin;
  bool get isOwner => role == UserRole.owner;
  bool get isOrganizer => role == UserRole.organizer;
  bool get isSupplier => role == UserRole.supplier;
  bool get isVisitor => role == UserRole.visitor;
  bool get canManageUsers => role.canManageUsers;
  bool get canCreateEvents => role.canCreateEvents;
  bool get canBookBooths => role.canBookBooths;

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    UserRole? role,
    String? profileImage,
    String? email,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
