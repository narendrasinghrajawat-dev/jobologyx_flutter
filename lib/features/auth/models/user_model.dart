import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Mirrors the Mongoose `User` schema in jobologyx_nodejs exactly — see the
/// backend_api_contract project memory for field-by-field provenance.
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage = "",
    this.resumeUrl = "",
    this.bio = "",
    this.skills = const [],
    this.location = "",
    this.companyName = "",
    this.companyWebsite = "",
    this.companyLogo = "",
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: "_id")
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String profileImage;
  final String resumeUrl;
  final String bio;
  final List<String> skills;
  final String location;
  final String companyName;
  final String companyWebsite;
  final String companyLogo;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isJobSeeker => role == "job_seeker";
  bool get isRecruiter => role == "recruiter";
  bool get isAdmin => role == "admin";

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

/// The three selectable/registerable roles — `admin` is deliberately excluded
/// from registration per spec §22.
class UserRole {
  UserRole._();

  static const String jobSeeker = "job_seeker";
  static const String recruiter = "recruiter";
  static const String admin = "admin";
}
