import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../models/admin_job_view.dart';
import '../repositories/admin_repository.dart';

class AdminJobsState {
  const AdminJobsState({
    this.jobs = const [],
    this.statusFilter,
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<AdminJobView> jobs;
  final String? statusFilter;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  AdminJobsState copyWith({
    List<AdminJobView>? jobs,
    String? statusFilter,
    bool clearStatusFilter = false,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    String? loadMoreError,
  }) {
    return AdminJobsState(
      jobs: jobs ?? this.jobs,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      loadMoreError: loadMoreError,
    );
  }
}

/// Drives `/admin/jobs`: status filter, backend pagination, status change
/// and delete actions across every recruiter's jobs (not just the caller's).
class AdminJobsNotifier extends Notifier<AdminJobsState> {
  @override
  AdminJobsState build() => const AdminJobsState();

  Map<String, dynamic> _queryParams(int page) {
    final params = <String, dynamic>{"page": page, "limit": ApiConstants.defaultPageSize};
    if (state.statusFilter != null) params["status"] = state.statusFilter;
    return params;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref.read(adminRepositoryProvider).listJobs(_queryParams(1));
      state = state.copyWith(
        jobs: result.jobs,
        page: result.pagination.page,
        totalPages: result.pagination.totalPages,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final result = await ref.read(adminRepositoryProvider).listJobs(_queryParams(1));
      state = state.copyWith(
        jobs: result.jobs,
        page: result.pagination.page,
        totalPages: result.pagination.totalPages,
        isRefreshing: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isRefreshing: false, errorMessage: e.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, loadMoreError: null);
    try {
      final result = await ref.read(adminRepositoryProvider).listJobs(_queryParams(state.page + 1));
      state = state.copyWith(
        jobs: [...state.jobs, ...result.jobs],
        page: result.pagination.page,
        totalPages: result.pagination.totalPages,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: e.message);
    }
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    loadInitial();
  }

  // updateJobStatus's response isn't used to patch state (same class of
  // sparse-response risk as the recruiter application status bug — see
  // flutter_riverpod_gotchas memory #4) — refetch the one changed row's
  // status locally instead, since AdminJobView is small and we already know
  // the confirmed new value.
  Future<bool> updateStatus(String jobId, String newStatus) async {
    try {
      await ref.read(adminRepositoryProvider).updateJobStatus(jobId, newStatus);
      state = state.copyWith(
        jobs: state.jobs.map((j) => j.id == jobId ? j.copyWith(status: newStatus) : j).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      await ref.read(adminRepositoryProvider).deleteJob(jobId);
      state = state.copyWith(jobs: state.jobs.where((j) => j.id != jobId).toList());
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final adminJobsProvider = NotifierProvider<AdminJobsNotifier, AdminJobsState>(AdminJobsNotifier.new);
