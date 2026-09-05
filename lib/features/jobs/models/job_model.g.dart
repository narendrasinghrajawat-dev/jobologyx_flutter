// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
  id: json['_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  companyName: json['companyName'] as String,
  companyLogo: json['companyLogo'] as String? ?? "",
  location: json['location'] as String,
  jobType: json['jobType'] as String,
  workMode: json['workMode'] as String,
  salaryMin: json['salaryMin'] as num? ?? 0,
  salaryMax: json['salaryMax'] as num? ?? 0,
  experience: json['experience'] as String? ?? "",
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  category: json['category'] as String? ?? "",
  createdBy: json['createdBy'] as String,
  status: json['status'] as String? ?? "active",
  applicationDeadline: json['applicationDeadline'] == null
      ? null
      : DateTime.parse(json['applicationDeadline'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'companyName': instance.companyName,
  'companyLogo': instance.companyLogo,
  'location': instance.location,
  'jobType': instance.jobType,
  'workMode': instance.workMode,
  'salaryMin': instance.salaryMin,
  'salaryMax': instance.salaryMax,
  'experience': instance.experience,
  'skills': instance.skills,
  'category': instance.category,
  'createdBy': instance.createdBy,
  'status': instance.status,
  'applicationDeadline': instance.applicationDeadline?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
