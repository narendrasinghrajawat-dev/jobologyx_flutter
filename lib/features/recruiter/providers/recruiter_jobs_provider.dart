import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/repositories/job_repository.dart';

class RecruiterJobsState {
  const RecruiterJobsState({
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

  final List<JobModel> jobs;

  /// null = all statuses (active/closed/draft), matching §39's "any status".
  final String? statusFilter;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  RecruiterJobsState copyWith({
    List<JobModel>? jobs,
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
    return RecruiterJobsState(
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

/// Drives `/recruiter/jobs` — the recruiter's own postings, any status
/// (`mine=true` bypasses the public "active only" default), with an
/// optional status filter and backend pagination.
class RecruiterJobsNotifier extends Notifier<RecruiterJobsState> {
  @override
  RecruiterJobsState build() => const RecruiterJobsState();

  Map<String, dynamic> _queryParams(int page) {
    final params = <String, dynamic>{"page": page, "limit": ApiConstants.defaultPageSize, "mine": "true"};
    if (state.statusFilter != null) params["status"] = state.statusFilter;
    return params;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref.read(jobRepositoryProvider).listJobs(_queryParams(1));
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
      final result = await ref.read(jobRepositoryProvider).listJobs(_queryParams(1));
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
      final result = await ref.read(jobRepositoryProvider).listJobs(_queryParams(state.page + 1));
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

  Future<bool> deleteJob(String jobId) async {
    try {
      await ref.read(jobRepositoryProvider).deleteJob(jobId);
      state = state.copyWith(jobs: state.jobs.where((j) => j.id != jobId).toList());
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final recruiterJobsProvider = NotifierProvider<RecruiterJobsNotifier, RecruiterJobsState>(
  RecruiterJobsNotifier.new,
);
