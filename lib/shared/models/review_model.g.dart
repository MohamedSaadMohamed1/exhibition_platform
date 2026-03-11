// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewModelImpl _$$ReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$ReviewModelImpl(
      id: json['id'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String?,
      reviewerImage: json['reviewerImage'] as String?,
      type: $enumDecode(_$ReviewTypeEnumMap, json['type']),
      targetId: json['targetId'] as String,
      targetName: json['targetName'] as String?,
      orderId: json['orderId'] as String?,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      helpfulBy: (json['helpfulBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      supplierResponse: json['supplierResponse'] as String?,
      supplierResponseAt: const NullableTimestampConverter()
          .fromJson(json['supplierResponseAt']),
      isVerified: json['isVerified'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$ReviewModelImplToJson(_$ReviewModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'reviewerImage': instance.reviewerImage,
      'type': _$ReviewTypeEnumMap[instance.type]!,
      'targetId': instance.targetId,
      'targetName': instance.targetName,
      'orderId': instance.orderId,
      'rating': instance.rating,
      'title': instance.title,
      'comment': instance.comment,
      'images': instance.images,
      'helpfulCount': instance.helpfulCount,
      'helpfulBy': instance.helpfulBy,
      'supplierResponse': instance.supplierResponse,
      'supplierResponseAt': const NullableTimestampConverter()
          .toJson(instance.supplierResponseAt),
      'isVerified': instance.isVerified,
      'isVisible': instance.isVisible,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
    };

const _$ReviewTypeEnumMap = {
  ReviewType.event: 'event',
  ReviewType.supplier: 'supplier',
  ReviewType.service: 'service',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$ReviewStatsImpl _$$ReviewStatsImplFromJson(Map<String, dynamic> json) =>
    _$ReviewStatsImpl(
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      fiveStarCount: (json['fiveStarCount'] as num?)?.toInt() ?? 0,
      fourStarCount: (json['fourStarCount'] as num?)?.toInt() ?? 0,
      threeStarCount: (json['threeStarCount'] as num?)?.toInt() ?? 0,
      twoStarCount: (json['twoStarCount'] as num?)?.toInt() ?? 0,
      oneStarCount: (json['oneStarCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ReviewStatsImplToJson(_$ReviewStatsImpl instance) =>
    <String, dynamic>{
      'totalReviews': instance.totalReviews,
      'averageRating': instance.averageRating,
      'fiveStarCount': instance.fiveStarCount,
      'fourStarCount': instance.fourStarCount,
      'threeStarCount': instance.threeStarCount,
      'twoStarCount': instance.twoStarCount,
      'oneStarCount': instance.oneStarCount,
    };
