import 'package:json_annotation/json_annotation.dart';

part 'job_model.g.dart';

/// Mirrors the Mongoose `Job` schema in jobologyx_nodejs. `createdBy` is
/// never populated by the backend for job endpoints, so it always stays a
/// plain ObjectId string — see the backend_api_contract project memory.
@JsonSerializable()
class JobModel {
  const JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    this.companyLogo = "",
    required this.location,
    required this.jobType,
    required this.workMode,
    this.salaryMin = 0,
    this.salaryMax = 0,
    this.experience = "",
    this.skills = const [],
    this.category = "",
    required this.createdBy,
    this.status = "active",
    this.applicationDeadline,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: "_id")
  final String id;
  final String title;
  final String description;
  final String companyName;
  final String companyLogo;
  final String location;
  final String jobType;
  final String workMode;
  final num salaryMin;
  final num salaryMax;
  final String experience;
  final List<String> skills;
  final String category;
  final String createdBy;
  final String status;
  final DateTime? applicationDeadline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == "active";

  bool get isDeadlinePassed => applicationDeadline != null && applicationDeadline!.isBefore(DateTime.now());

  bool get isAcceptingApplications => isActive && !isDeadlinePassed;

  factory JobModel.fromJson(Map<String, dynamic> json) => _$JobModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobModelToJson(this);
}
