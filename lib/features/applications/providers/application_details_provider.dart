import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application_model.dart';
import '../repositories/application_repository.dart';

final applicationDetailsProvider = FutureProvider.autoDispose.family<ApplicationModel, String>((ref, id) {
  return ref.watch(applicationRepositoryProvider).getApplicationById(id);
});
