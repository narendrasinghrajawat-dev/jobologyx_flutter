import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

/// Raw HTTP calls for applications — job-seeker side (Phase 4) and
/// recruiter side (Phase 5). Admin's `/admin/applications` is separate.
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

  Future<Map<String, dynamic>> getRecruiterApplications(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiEndpoints.recruiterApplications, queryParameters: queryParams);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateApplicationStatus(String id, String status) async {
    final response = await _dio.patch(ApiEndpoints.applicationStatus(id), data: {"status": status});
    return response.data["data"] as Map<String, dynamic>;
  }
}
