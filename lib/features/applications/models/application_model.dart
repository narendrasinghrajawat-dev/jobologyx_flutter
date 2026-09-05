/// A job reference on an [ApplicationModel]. The backend sometimes returns
/// this as a plain ObjectId string and sometimes as a partially-populated
/// object (`title`, `companyName`, `location`, `jobType`, `status`, `_id`)
/// depending on which endpoint returned it — see the backend_api_contract
/// project memory. Handled here instead of with json_serializable since the
/// shape isn't uniform.
class JobRef {
  const JobRef({required this.id, this.title, this.companyName, this.location, this.jobType, this.status});

  final String id;
  final String? title;
  final String? companyName;
  final String? location;
  final String? jobType;
  final String? status;

  factory JobRef.fromJson(dynamic json) {
    if (json is String) return JobRef(id: json);
    final map = json as Map<String, dynamic>;
    return JobRef(
      id: map["_id"] as String,
      title: map["title"] as String?,
      companyName: map["companyName"] as String?,
      location: map["location"] as String?,
      jobType: map["jobType"] as String?,
      status: map["status"] as String?,
    );
  }
}

/// Same idea as [JobRef] but for the `applicant` field — populated with
/// `name email phone resumeUrl skills` on recruiter-facing endpoints, a
/// plain id string on `getMyApplications`.
class ApplicantRef {
  const ApplicantRef({required this.id, this.name, this.email, this.phone, this.resumeUrl, this.skills});

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? resumeUrl;
  final List<String>? skills;

  factory ApplicantRef.fromJson(dynamic json) {
    if (json is String) return ApplicantRef(id: json);
    final map = json as Map<String, dynamic>;
    return ApplicantRef(
      id: map["_id"] as String,
      name: map["name"] as String?,
      email: map["email"] as String?,
      phone: map["phone"] as String?,
      resumeUrl: map["resumeUrl"] as String?,
      skills: (map["skills"] as List?)?.map((s) => s as String).toList(),
    );
  }
}

/// Mirrors the Mongoose `Application` schema. `recruiter` is never
/// populated by the backend on any endpoint, so it always stays a plain id.
class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.job,
    required this.applicant,
    required this.recruiter,
    required this.resumeUrl,
    required this.coverLetter,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final JobRef job;
  final ApplicantRef applicant;
  final String recruiter;
  final String resumeUrl;
  final String coverLetter;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final recruiterField = json["recruiter"];
    return ApplicationModel(
      id: json["_id"] as String,
      job: JobRef.fromJson(json["job"]),
      applicant: ApplicantRef.fromJson(json["applicant"]),
      recruiter: recruiterField is String ? recruiterField : (recruiterField as Map<String, dynamic>)["_id"] as String,
      resumeUrl: json["resumeUrl"] as String? ?? "",
      coverLetter: json["coverLetter"] as String? ?? "",
      status: json["status"] as String? ?? "applied",
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"] as String) : null,
      updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"] as String) : null,
    );
  }
}

class ApplicationStatus {
  ApplicationStatus._();

  static const String applied = "applied";
  static const String reviewing = "reviewing";
  static const String shortlisted = "shortlisted";
  static const String rejected = "rejected";
  static const String hired = "hired";
}
