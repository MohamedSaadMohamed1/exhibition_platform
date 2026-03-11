// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobModelImpl _$$JobModelImplFromJson(Map<String, dynamic> json) =>
    _$JobModelImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      organizerId: json['organizerId'] as String,
      eventTitle: json['eventTitle'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      salary: json['salary'] as String?,
      location: json['location'] as String?,
      jobType: json['jobType'] as String?,
      deadline: const TimestampConverter().fromJson(json['deadline']),
      applicationsCount: (json['applicationsCount'] as num?)?.toInt() ?? 0,
      status: $enumDecodeNullable(_$JobStatusEnumMap, json['status']) ??
          JobStatus.open,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$JobModelImplToJson(_$JobModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'organizerId': instance.organizerId,
      'eventTitle': instance.eventTitle,
      'title': instance.title,
      'description': instance.description,
      'requirements': instance.requirements,
      'salary': instance.salary,
      'location': instance.location,
      'jobType': instance.jobType,
      'deadline': const TimestampConverter().toJson(instance.deadline),
      'applicationsCount': instance.applicationsCount,
      'status': _$JobStatusEnumMap[instance.status]!,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
    };

const _$JobStatusEnumMap = {
  JobStatus.open: 'open',
  JobStatus.closed: 'closed',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$JobApplicationImpl _$$JobApplicationImplFromJson(Map<String, dynamic> json) =>
    _$JobApplicationImpl(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userPhone: json['userPhone'] as String?,
      userEmail: json['userEmail'] as String?,
      coverLetter: json['coverLetter'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
      status: $enumDecodeNullable(_$ApplicationStatusEnumMap, json['status']) ??
          ApplicationStatus.pending,
      feedback: json['feedback'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      reviewedAt:
          const NullableTimestampConverter().fromJson(json['reviewedAt']),
    );

Map<String, dynamic> _$$JobApplicationImplToJson(
        _$JobApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'eventId': instance.eventId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPhone': instance.userPhone,
      'userEmail': instance.userEmail,
      'coverLetter': instance.coverLetter,
      'resumeUrl': instance.resumeUrl,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'feedback': instance.feedback,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
      'reviewedAt':
          const NullableTimestampConverter().toJson(instance.reviewedAt),
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.pending: 'pending',
  ApplicationStatus.reviewed: 'reviewed',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
};
