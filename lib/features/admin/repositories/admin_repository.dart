import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../../core/network/pagination.dart';
import '../../auth/models/user_model.dart';
import '../data/admin_api.dart';
import '../models/admin_application_view.dart';
import '../models/admin_job_view.dart';

typedef AdminDashboardStats = ({
  int totalUsers,
  int totalJobSeekers,
  int totalRecruiters,
  int totalJobs,
  int activeJobs,
  int totalApplications,
  int pendingApplications,
});

typedef AdminUserListResult = ({List<UserModel> users, Pagination pagination});
typedef AdminJobListResult = ({List<AdminJobView> jobs, Pagination pagination});
typedef AdminApplicationListResult = ({List<AdminApplicationView> applications, Pagination pagination});

class AdminRepository {
  AdminRepository(this._api);

  final AdminApi _api;

  Future<AdminDashboardStats> getDashboard() async {
    try {
      final data = await _api.getDashboard();
      final stats = data["stats"] as Map<String, dynamic>;
      return (
        totalUsers: stats["totalUsers"] as int,
        totalJobSeekers: stats["totalJobSeekers"] as int,
        totalRecruiters: stats["totalRecruiters"] as int,
        totalJobs: stats["totalJobs"] as int,
        activeJobs: stats["activeJobs"] as int,
        totalApplications: stats["totalApplications"] as int,
        pendingApplications: stats["pendingApplications"] as int,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AdminUserListResult> listUsers(Map<String, dynamic> queryParams) async {
    try {
      final data = await _api.listUsers(queryParams);
      final users = (data["users"] as List).map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList();
      return (users: users, pagination: Pagination.fromJson(data["pagination"] as Map<String, dynamic>));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<UserModel> updateUserStatus(String id, bool isActive) async {
    try {
      final data = await _api.updateUserStatus(id, isActive);
      return UserModel.fromJson(data["user"] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _api.deleteUser(id);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AdminJobListResult> listJobs(Map<String, dynamic> queryParams) async {
    try {
      final data = await _api.listJobs(queryParams);
      final jobs = (data["jobs"] as List).map((j) => AdminJobView.fromJson(j as Map<String, dynamic>)).toList();
      return (jobs: jobs, pagination: Pagination.fromJson(data["pagination"] as Map<String, dynamic>));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> updateJobStatus(String id, String status) async {
    try {
      await _api.updateJobStatus(id, status);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteJob(String id) async {
    try {
      await _api.deleteJob(id);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AdminApplicationListResult> listApplications(Map<String, dynamic> queryParams) async {
    try {
      final data = await _api.listApplications(queryParams);
      final applications =
          (data["applications"] as List).map((a) => AdminApplicationView.fromJson(a as Map<String, dynamic>)).toList();
      return (applications: applications, pagination: Pagination.fromJson(data["pagination"] as Map<String, dynamic>));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(AdminApi(ref.watch(dioClientProvider)));
});
