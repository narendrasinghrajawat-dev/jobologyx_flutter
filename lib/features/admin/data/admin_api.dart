import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

/// Raw HTTP calls for `/admin/*`. Admin-only, enforced server-side.
class AdminApi {
  AdminApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dio.get(ApiEndpoints.adminDashboard);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listUsers(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiEndpoints.adminUsers, queryParameters: queryParams);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUserStatus(String id, bool isActive) async {
    final response = await _dio.patch(ApiEndpoints.adminUserStatus(id), data: {"isActive": isActive});
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete(ApiEndpoints.adminUserById(id));
  }

  Future<Map<String, dynamic>> listJobs(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiEndpoints.adminJobs, queryParameters: queryParams);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateJobStatus(String id, String status) async {
    final response = await _dio.patch(ApiEndpoints.adminJobStatus(id), data: {"status": status});
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<void> deleteJob(String id) async {
    await _dio.delete(ApiEndpoints.adminJobById(id));
  }

  Future<Map<String, dynamic>> listApplications(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiEndpoints.adminApplications, queryParameters: queryParams);
    return response.data["data"] as Map<String, dynamic>;
  }
}
