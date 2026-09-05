import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../jobs/models/job_model.dart';
import '../../jobs/repositories/job_repository.dart';

/// A lightweight list of the recruiter's own jobs, used only to populate
/// the "Filter by Job" dropdown on `/recruiter/applications` — separate
/// from `recruiterJobsProvider` so visiting Applications directly doesn't
/// depend on the Jobs tab having been opened first.
final recruiterJobOptionsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final result = await ref.watch(jobRepositoryProvider).listJobs({"page": 1, "limit": 50, "mine": "true"});
  return result.jobs;
});
