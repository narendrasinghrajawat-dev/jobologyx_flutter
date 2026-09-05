import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped by [DioClient]'s interceptor whenever a request comes back 401.
/// `AuthNotifier` watches this to clear the session and redirect to login —
/// this keeps the network layer decoupled from the auth feature.
class SessionExpiryNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notify() => state++;
}

final sessionExpiryProvider = NotifierProvider<SessionExpiryNotifier, int>(
  SessionExpiryNotifier.new,
);
