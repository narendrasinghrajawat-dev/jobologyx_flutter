import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_model.dart';
import '../repositories/job_repository.dart';

/// One job's full details, keyed by id. `autoDispose` so a stale job isn't
/// held in memory after the user navigates away.
final jobDetailsProvider = FutureProvider.autoDispose.family<JobModel, String>((ref, jobId) {
  return ref.watch(jobRepositoryProvider).getJobById(jobId);
});
