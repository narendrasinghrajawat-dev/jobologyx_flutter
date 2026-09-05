/// A row in `/admin/jobs` — deliberately a separate, lightweight model
/// rather than reusing `JobModel`: the admin listing populates `createdBy`
/// (recruiter name/email/company), which the seeker/recruiter-facing job
/// endpoints never do (see backend_api_contract project memory), and admin
/// doesn't need the full job shape (description, skills, etc.) for a list row.
class AdminJobView {
  const AdminJobView({
    required this.id,
    required this.title,
    required this.companyName,
    required this.status,
    required this.recruiterName,
    required this.recruiterEmail,
    this.createdAt,
  });

  final String id;
  final String title;
  final String companyName;
  final String status;
  final String recruiterName;
  final String recruiterEmail;
  final DateTime? createdAt;

  AdminJobView copyWith({String? status}) {
    return AdminJobView(
      id: id,
      title: title,
      companyName: companyName,
      status: status ?? this.status,
      recruiterName: recruiterName,
      recruiterEmail: recruiterEmail,
      createdAt: createdAt,
    );
  }

  factory AdminJobView.fromJson(Map<String, dynamic> json) {
    final createdBy = json["createdBy"];
    final recruiter = createdBy is Map<String, dynamic> ? createdBy : const <String, dynamic>{};
    return AdminJobView(
      id: json["_id"] as String,
      title: json["title"] as String? ?? "",
      companyName: json["companyName"] as String? ?? "",
      status: json["status"] as String? ?? "active",
      recruiterName: recruiter["name"] as String? ?? "Unknown",
      recruiterEmail: recruiter["email"] as String? ?? "",
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"] as String) : null,
    );
  }
}
