import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application_model.dart';
import '../repositories/application_repository.dart';

typedef DashboardApplicationsSummary = ({List<ApplicationModel> applications, int totalCount});

/// Powers the seeker dashboard's stat tiles and "Recent Applications" list.
/// There's no dedicated seeker stats endpoint (only `/admin/dashboard`
/// exists), so this fetches one batch (up to the backend's max page size)
/// and computes status counts client-side — `totalCount` still comes from
/// the accurate server-side `pagination.total`, so that one number stays
/// correct even for a seeker with more applications than fit in the batch.
final dashboardApplicationsProvider = FutureProvider.autoDispose<DashboardApplicationsSummary>((ref) async {
  final result = await ref.watch(applicationRepositoryProvider).getMyApplications({"page": 1, "limit": 50});
  return (applications: result.applications, totalCount: result.pagination.total);
});
