import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

/// Raw HTTP calls for auth — returns the decoded `data` object from the
/// backend envelope. Error mapping happens one layer up, in [AuthRepository].
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _dio.post(ApiEndpoints.register, data: {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    });
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiEndpoints.login, data: {
      "email": email,
      "password": password,
    });
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get(ApiEndpoints.me);
    return response.data["data"] as Map<String, dynamic>;
  }
}
