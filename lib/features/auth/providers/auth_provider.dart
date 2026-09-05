import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/network/session_expiry_notifier.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState copyWith({AuthStatus? status, UserModel? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// The single source of auth truth for the whole app. `SplashScreen` triggers
/// [checkAuthStatus] once; `GoRouter`'s redirect reads [AuthState.status] and
/// [AuthState.user]`.role` to decide where the user lands.
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository = ref.read(authRepositoryProvider);
  late final SecureStorageService _storage = ref.read(secureStorageServiceProvider);

  @override
  AuthState build() {
    // A 401 from anywhere in the app funnels through here so there is exactly
    // one place that reacts to session expiry.
    ref.listen(sessionExpiryProvider, (previous, next) {
      if (previous != null && next != previous) {
        _forceLogout();
      }
    });
    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _repository.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on NetworkException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
    } on ApiException {
      await _storage.deleteToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _repository.login(email: email, password: password);
      await _storage.saveToken(result.token);
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: e.message);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final result = await _repository.register(name: name, email: email, password: password, role: role);
      await _storage.saveToken(result.token);
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: e.message);
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _forceLogout() async {
    await _storage.deleteToken();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: "Your session has expired. Please log in again.",
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
