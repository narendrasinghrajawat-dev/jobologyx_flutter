import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../applications/models/application_model.dart';
import '../../applications/repositories/application_repository.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/repositories/job_repository.dart';

typedef RecruiterDashboardSummary = ({
  List<JobModel> jobs,
  int totalJobs,
  List<ApplicationModel> applications,
  int totalApplications,
});

/// Powers the recruiter dashboard (§38): total/active jobs and
/// total/reviewing applications, plus recent-jobs and recent-applications
/// lists — all derived from one batch fetch each, the same pattern as the
/// seeker dashboard in Phase 4 (no dedicated recruiter stats endpoint
/// exists; `/admin/dashboard` is admin-only).
final recruiterDashboardProvider = FutureProvider.autoDispose<RecruiterDashboardSummary>((ref) async {
  final jobsFuture = ref.watch(jobRepositoryProvider).listJobs({"page": 1, "limit": 50, "mine": "true"});
  final applicationsFuture =
      ref.watch(applicationRepositoryProvider).getRecruiterApplications({"page": 1, "limit": 50});
  final results = await Future.wait([jobsFuture, applicationsFuture]);
  final jobsResult = results[0] as JobListResult;
  final applicationsResult = results[1] as ApplicationListResult;
  return (
    jobs: jobsResult.jobs,
    totalJobs: jobsResult.pagination.total,
    applications: applicationsResult.applications,
    totalApplications: applicationsResult.pagination.total,
  );
});
