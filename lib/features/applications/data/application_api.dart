import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

/// Raw HTTP calls for the job-seeker side of applications. Recruiter/admin
/// endpoints (`/applications/recruiter`, status updates) land in Phase 5-6.
class ApplicationApi {
  ApplicationApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> apply({required String jobId, required String coverLetter}) async {
    final response = await _dio.post(ApiEndpoints.applications, data: {
      "jobId": jobId,
      "coverLetter": coverLetter,
    });
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyApplications(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiEndpoints.myApplications, queryParameters: queryParams);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getApplicationById(String id) async {
    final response = await _dio.get(ApiEndpoints.applicationById(id));
    return response.data["data"] as Map<String, dynamic>;
  }
}
