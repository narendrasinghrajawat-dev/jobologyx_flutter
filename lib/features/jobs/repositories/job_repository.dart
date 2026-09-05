import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../../core/network/pagination.dart';
import '../data/job_api.dart';
import '../models/job_model.dart';

typedef JobListResult = ({List<JobModel> jobs, Pagination pagination});

class JobRepository {
  JobRepository(this._api);

  final JobApi _api;

  Future<JobListResult> listJobs(Map<String, dynamic> queryParams) async {
    try {
      final data = await _api.listJobs(queryParams);
      final jobs = (data["jobs"] as List).map((j) => JobModel.fromJson(j as Map<String, dynamic>)).toList();
      return (jobs: jobs, pagination: Pagination.fromJson(data["pagination"] as Map<String, dynamic>));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<JobModel> getJobById(String id) async {
    try {
      final data = await _api.getJobById(id);
      return JobModel.fromJson(data["job"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(JobApi(ref.watch(dioClientProvider)));
});
