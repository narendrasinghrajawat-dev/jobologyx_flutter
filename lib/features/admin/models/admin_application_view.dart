/// A row in `/admin/applications` — its own model rather than reusing
/// `ApplicationModel`: the admin endpoint populates `job` (title,
/// companyName), `applicant` (name, email) AND `recruiter` (name, email) —
/// a different populate depth than any seeker/recruiter endpoint — and
/// admin's list is read-only (no resumeUrl/coverLetter needed, per §48).
class AdminApplicationView {
  const AdminApplicationView({
    required this.id,
    required this.status,
    required this.jobTitle,
    required this.applicantName,
    required this.applicantEmail,
    required this.recruiterName,
    this.createdAt,
  });

  final String id;
  final String status;
  final String jobTitle;
  final String applicantName;
  final String applicantEmail;
  final String recruiterName;
  final DateTime? createdAt;

  factory AdminApplicationView.fromJson(Map<String, dynamic> json) {
    final job = json["job"] is Map<String, dynamic> ? json["job"] as Map<String, dynamic> : const {};
    final applicant = json["applicant"] is Map<String, dynamic> ? json["applicant"] as Map<String, dynamic> : const {};
    final recruiter = json["recruiter"] is Map<String, dynamic> ? json["recruiter"] as Map<String, dynamic> : const {};
    return AdminApplicationView(
      id: json["_id"] as String,
      status: json["status"] as String? ?? "applied",
      jobTitle: job["title"] as String? ?? "Job posting removed",
      applicantName: applicant["name"] as String? ?? "Unknown",
      applicantEmail: applicant["email"] as String? ?? "",
      recruiterName: recruiter["name"] as String? ?? "Unknown",
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"] as String) : null,
    );
  }
}
