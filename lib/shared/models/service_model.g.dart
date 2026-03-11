// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceModelImpl _$$ServiceModelImplFromJson(Map<String, dynamic> json) =>
    _$ServiceModelImpl(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      price: (json['price'] as num?)?.toDouble(),
      priceUnit: json['priceUnit'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$ServiceModelImplToJson(_$ServiceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'images': instance.images,
      'price': instance.price,
      'priceUnit': instance.priceUnit,
      'isActive': instance.isActive,
      'ordersCount': instance.ordersCount,
      'rating': instance.rating,
      'reviewsCount': instance.reviewsCount,
      'tags': instance.tags,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
