/// All backend route paths, relative to [ApiConstants.baseUrl]. Matches
/// jobologyx_nodejs exactly — do not rename without updating the backend.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = "/auth/register";
  static const String login = "/auth/login";
  static const String me = "/auth/me";

  // Users
  static const String userMe = "/users/me";
  static const String userProfileImage = "/users/me/profile-image";
  static const String userResume = "/users/me/resume";
  static const String userCompanyLogo = "/users/me/company-logo";

  // Jobs
  static const String jobs = "/jobs";
  static String jobById(String id) => "/jobs/$id";

  // Applications
  static const String applications = "/applications";
  static const String myApplications = "/applications/my";
  static const String recruiterApplications = "/applications/recruiter";
  static String applicationById(String id) => "/applications/$id";
  static String applicationStatus(String id) => "/applications/$id/status";

  // Admin
  static const String adminDashboard = "/admin/dashboard";
  static const String adminUsers = "/admin/users";
  static String adminUserStatus(String id) => "/admin/users/$id/status";
  static String adminUserById(String id) => "/admin/users/$id";
  static const String adminJobs = "/admin/jobs";
  static String adminJobStatus(String id) => "/admin/jobs/$id/status";
  static String adminJobById(String id) => "/admin/jobs/$id";
  static const String adminApplications = "/admin/applications";
}
