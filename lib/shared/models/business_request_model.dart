import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessRequestModel {
  final String id;
  final String supplierId;
  final String supplierName;
  final String businessName;
  final String description;
  final String? category;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? website;
  final String status; // pending | approved | rejected
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  const BusinessRequestModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.businessName,
    required this.description,
    this.category,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.website,
    this.status = 'pending',
    this.adminNotes,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory BusinessRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessRequestModel(
      id: doc.id,
      supplierId: data['supplierId'] as String? ?? '',
      supplierName: data['supplierName'] as String? ?? '',
      businessName: data['businessName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String?,
      contactEmail: data['contactEmail'] as String?,
      contactPhone: data['contactPhone'] as String?,
      address: data['address'] as String?,
      website: data['website'] as String?,
      status: data['status'] as String? ?? 'pending',
      adminNotes: data['adminNotes'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      reviewedAt: data['reviewedAt'] != null ? _parseDateTime(data['reviewedAt']) : null,
      reviewedBy: data['reviewedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'businessName': businessName,
      'description': description,
      'category': category,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address,
      'website': website,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
    };
  }

  BusinessRequestModel copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? businessName,
    String? description,
    String? category,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? website,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return BusinessRequestModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      category: category ?? this.category,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      website: website ?? this.website,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
