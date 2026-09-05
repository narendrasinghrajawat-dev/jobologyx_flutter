import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

/// Raw HTTP calls for jobs — returns the decoded `data` object. Error
/// mapping happens one layer up, in [JobRepository].
class JobApi {
  JobApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> listJobs(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiEndpoints.jobs, queryParameters: queryParams);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getJobById(String id) async {
    final response = await _dio.get(ApiEndpoints.jobById(id));
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.jobs, data: data);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateJob(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch(ApiEndpoints.jobById(id), data: data);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<void> deleteJob(String id) async {
    await _dio.delete(ApiEndpoints.jobById(id));
  }
}
