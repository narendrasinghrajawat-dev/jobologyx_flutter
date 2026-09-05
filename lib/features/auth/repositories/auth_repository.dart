import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../data/auth_api.dart';
import '../models/user_model.dart';

typedef AuthResult = ({UserModel user, String token});

/// Repository boundary for auth — providers/screens call this, never [AuthApi]
/// or [Dio] directly. Maps every Dio failure to a typed [ApiException].
class AuthRepository {
  AuthRepository(this._api);

  final AuthApi _api;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final data = await _api.register(name: name, email: email, password: password, role: role);
      return (
        user: UserModel.fromJson(data["user"] as Map<String, dynamic>),
        token: data["token"] as String,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final data = await _api.login(email: email, password: password);
      return (
        user: UserModel.fromJson(data["user"] as Map<String, dynamic>),
        token: data["token"] as String,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final data = await _api.me();
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(AuthApi(ref.watch(dioClientProvider)));
});
