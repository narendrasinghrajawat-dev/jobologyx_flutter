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
}
