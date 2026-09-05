import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';

/// Raw HTTP calls for the current user's own profile. Shared by job-seeker
/// (Phase 4) and recruiter (Phase 5) profile screens — both hit the same
/// `/users/me*` endpoints, just with different editable fields.
class UserApi {
  UserApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get(ApiEndpoints.userMe);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> updates) async {
    final response = await _dio.patch(ApiEndpoints.userMe, data: updates);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadProfileImage({required List<int> bytes, required String filename}) async {
    final formData = FormData.fromMap({
      "image": MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(ApiEndpoints.userProfileImage, data: formData);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadResume({required List<int> bytes, required String filename}) async {
    final formData = FormData.fromMap({
      "resume": MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(ApiEndpoints.userResume, data: formData);
    return response.data["data"] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadCompanyLogo({required List<int> bytes, required String filename}) async {
    final formData = FormData.fromMap({
      "logo": MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(ApiEndpoints.userCompanyLogo, data: formData);
    return response.data["data"] as Map<String, dynamic>;
  }
}
