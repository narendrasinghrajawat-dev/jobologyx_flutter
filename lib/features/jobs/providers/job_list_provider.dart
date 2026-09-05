import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../models/job_filter.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';

class JobListState {
  const JobListState({
    this.jobs = const [],
    this.filter = const JobFilter(),
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<JobModel> jobs;
  final JobFilter filter;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;

  /// Set only on a failed *initial* load or refresh — replaces the list with
  /// a full error state.
  final String? errorMessage;

  /// Set only on a failed *load-more* — the existing list stays visible, the
  /// screen just surfaces this as a transient snackbar.
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  JobListState copyWith({
    List<JobModel>? jobs,
    JobFilter? filter,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    String? loadMoreError,
  }) {
    return JobListState(
      jobs: jobs ?? this.jobs,
      filter: filter ?? this.filter,
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

/// Drives the public/seeker job listing: search, filters, sort and backend
/// pagination all flow through here — the screen never fetches-all-then
/// -filters-locally.
class JobListNotifier extends Notifier<JobListState> {
  @override
  JobListState build() => const JobListState();

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref.read(jobRepositoryProvider).listJobs(
            state.filter.toQueryParams(page: 1, limit: ApiConstants.defaultPageSize),
          );
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
      final result = await ref.read(jobRepositoryProvider).listJobs(
            state.filter.toQueryParams(page: 1, limit: ApiConstants.defaultPageSize),
          );
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
      final result = await ref.read(jobRepositoryProvider).listJobs(
            state.filter.toQueryParams(page: state.page + 1, limit: ApiConstants.defaultPageSize),
          );
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

  void updateSearch(String query) {
    state = state.copyWith(filter: state.filter.copyWith(search: query));
    loadInitial();
  }

  void applyFilters(JobFilter newFilter) {
    state = state.copyWith(filter: newFilter);
    loadInitial();
  }

  void clearFilters() {
    state = state.copyWith(filter: state.filter.clearFilterFields());
    loadInitial();
  }
}

final jobListProvider = NotifierProvider<JobListNotifier, JobListState>(JobListNotifier.new);
