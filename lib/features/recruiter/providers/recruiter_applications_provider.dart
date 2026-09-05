import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../applications/models/application_model.dart';
import '../../applications/repositories/application_repository.dart';

class RecruiterApplicationsState {
  const RecruiterApplicationsState({
    this.applications = const [],
    this.jobFilter,
    this.statusFilter,
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<ApplicationModel> applications;
  final String? jobFilter;
  final String? statusFilter;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  RecruiterApplicationsState copyWith({
    List<ApplicationModel>? applications,
    String? jobFilter,
    bool clearJobFilter = false,
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
    return RecruiterApplicationsState(
      applications: applications ?? this.applications,
      jobFilter: clearJobFilter ? null : (jobFilter ?? this.jobFilter),
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

/// Drives `/recruiter/applications`: applicants across all of the
/// recruiter's jobs, filterable by job or status (§43), with backend
/// pagination and an inline status-update action per application.
class RecruiterApplicationsNotifier extends Notifier<RecruiterApplicationsState> {
  @override
  RecruiterApplicationsState build() => const RecruiterApplicationsState();

  Map<String, dynamic> _queryParams(int page) {
    final params = <String, dynamic>{"page": page, "limit": ApiConstants.defaultPageSize};
    if (state.jobFilter != null) params["job"] = state.jobFilter;
    if (state.statusFilter != null) params["status"] = state.statusFilter;
    return params;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref.read(applicationRepositoryProvider).getRecruiterApplications(_queryParams(1));
      state = state.copyWith(
        applications: result.applications,
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
      final result = await ref.read(applicationRepositoryProvider).getRecruiterApplications(_queryParams(1));
      state = state.copyWith(
        applications: result.applications,
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
      final result = await ref.read(applicationRepositoryProvider).getRecruiterApplications(_queryParams(state.page + 1));
      state = state.copyWith(
        applications: [...state.applications, ...result.applications],
        page: result.pagination.page,
        totalPages: result.pagination.totalPages,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: e.message);
    }
  }

  void setFilters({String? jobId, bool clearJob = false, String? status, bool clearStatus = false}) {
    state = state.copyWith(jobFilter: jobId, clearJobFilter: clearJob, statusFilter: status, clearStatusFilter: clearStatus);
    loadInitial();
  }

  Future<bool> updateStatus(String applicationId, String newStatus) async {
    try {
      // The response here doesn't include populated job/applicant (see
      // ApplicationModel.copyWith) — merge just the new status into the
      // card we already have instead of replacing it with a sparse one.
      await ref.read(applicationRepositoryProvider).updateApplicationStatus(applicationId, newStatus);
      state = state.copyWith(
        applications: state.applications
            .map((a) => a.id == applicationId ? a.copyWith(status: newStatus) : a)
            .toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final recruiterApplicationsProvider =
    NotifierProvider<RecruiterApplicationsNotifier, RecruiterApplicationsState>(RecruiterApplicationsNotifier.new);
