// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  phone: json['phone'] as String?,
  profileImage: json['profileImage'] as String? ?? "",
  resumeUrl: json['resumeUrl'] as String? ?? "",
  bio: json['bio'] as String? ?? "",
  skills:
      (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  location: json['location'] as String? ?? "",
  companyName: json['companyName'] as String? ?? "",
  companyWebsite: json['companyWebsite'] as String? ?? "",
  companyLogo: json['companyLogo'] as String? ?? "",
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'phone': instance.phone,
  'profileImage': instance.profileImage,
  'resumeUrl': instance.resumeUrl,
  'bio': instance.bio,
  'skills': instance.skills,
  'location': instance.location,
  'companyName': instance.companyName,
  'companyWebsite': instance.companyWebsite,
  'companyLogo': instance.companyLogo,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
