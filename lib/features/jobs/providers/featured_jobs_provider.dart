import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_model.dart';
import '../repositories/job_repository.dart';

/// The handful of newest active jobs shown on the guest Home screen — a
/// one-shot fetch, not paginated like the full listing.
final featuredJobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final result = await ref.watch(jobRepositoryProvider).listJobs({"limit": 6, "sort": "latest"});
  return result.jobs;
});
