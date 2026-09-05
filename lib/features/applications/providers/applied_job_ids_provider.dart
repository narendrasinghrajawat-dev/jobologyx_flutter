import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/application_repository.dart';

/// The set of job ids the current seeker has already applied to — powers
/// the "Already Applied" state on a job's Apply button. Fetched once (up to
/// the backend's max page size) rather than paginated, since this is a
/// small existence check, not the "My Applications" list UI itself.
/// Invalidated after a successful apply so the button updates immediately.
final appliedJobIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final result = await ref.watch(applicationRepositoryProvider).getMyApplications({"page": 1, "limit": 50});
  return result.applications.map((a) => a.job.id).toSet();
});
