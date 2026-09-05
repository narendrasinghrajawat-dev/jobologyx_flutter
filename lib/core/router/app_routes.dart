/// Every route path in the app, matching §23–24 of the spec. Centralized so
/// screens navigate via these constants instead of typing raw path strings.
class AppRoutes {
  AppRoutes._();

  static const String splash = "/";
  static const String login = "/login";
  static const String register = "/register";

  // Job seeker
  static const String seekerDashboard = "/seeker/dashboard";
  static const String seekerJobs = "/seeker/jobs";
  static const String seekerJobDetails = "/seeker/jobs/:id";
  static const String seekerApplications = "/seeker/applications";
  static const String seekerApplicationDetails = "/seeker/applications/:id";
  static const String seekerProfile = "/seeker/profile";

  // Recruiter
  static const String recruiterDashboard = "/recruiter/dashboard";
  static const String recruiterJobs = "/recruiter/jobs";
  static const String recruiterJobCreate = "/recruiter/jobs/create";
  static const String recruiterJobEdit = "/recruiter/jobs/:id/edit";
  static const String recruiterApplications = "/recruiter/applications";
  static const String recruiterProfile = "/recruiter/profile";

  // Admin
  static const String adminDashboard = "/admin/dashboard";
  static const String adminUsers = "/admin/users";
  static const String adminJobs = "/admin/jobs";
  static const String adminApplications = "/admin/applications";

  static String seekerJobDetailsPath(String id) => "/seeker/jobs/$id";
  static String seekerApplicationDetailsPath(String id) => "/seeker/applications/$id";
  static String recruiterJobEditPath(String id) => "/recruiter/jobs/$id/edit";
}
