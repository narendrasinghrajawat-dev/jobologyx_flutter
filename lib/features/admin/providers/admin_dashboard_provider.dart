import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/admin_repository.dart';

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardStats>((ref) {
  return ref.watch(adminRepositoryProvider).getDashboard();
});
