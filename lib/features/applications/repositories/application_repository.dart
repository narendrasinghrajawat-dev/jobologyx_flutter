import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../../core/network/pagination.dart';
import '../data/application_api.dart';
import '../models/application_model.dart';

typedef ApplicationListResult = ({List<ApplicationModel> applications, Pagination pagination});

class ApplicationRepository {
  ApplicationRepository(this._api);

  final ApplicationApi _api;

  Future<ApplicationModel> applyToJob({required String jobId, required String coverLetter}) async {
    try {
      final data = await _api.apply(jobId: jobId, coverLetter: coverLetter);
      return ApplicationModel.fromJson(data["application"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ApplicationListResult> getMyApplications(Map<String, dynamic> queryParams) async {
    try {
      final data = await _api.getMyApplications(queryParams);
      final applications = (data["applications"] as List)
          .map((a) => ApplicationModel.fromJson(a as Map<String, dynamic>))
          .toList();
      return (applications: applications, pagination: Pagination.fromJson(data["pagination"] as Map<String, dynamic>));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ApplicationModel> getApplicationById(String id) async {
    try {
      final data = await _api.getApplicationById(id);
      return ApplicationModel.fromJson(data["application"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ApplicationApi(ref.watch(dioClientProvider)));
});
