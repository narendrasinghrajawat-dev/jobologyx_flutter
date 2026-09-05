import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../models/application_model.dart';
import '../repositories/application_repository.dart';

class MyApplicationsState {
  const MyApplicationsState({
    this.applications = const [],
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<ApplicationModel> applications;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  MyApplicationsState copyWith({
    List<ApplicationModel>? applications,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    String? loadMoreError,
  }) {
    return MyApplicationsState(
      applications: applications ?? this.applications,
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

/// Drives the "My Applications" list — backend pagination, pull-to-refresh,
/// load-more. No search/filter here (the spec doesn't ask for any on this
/// screen), so it's a simpler sibling of `JobListNotifier`.
class MyApplicationsNotifier extends Notifier<MyApplicationsState> {
  @override
  MyApplicationsState build() => const MyApplicationsState();

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref
          .read(applicationRepositoryProvider)
          .getMyApplications({"page": 1, "limit": ApiConstants.defaultPageSize});
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
      final result = await ref
          .read(applicationRepositoryProvider)
          .getMyApplications({"page": 1, "limit": ApiConstants.defaultPageSize});
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
      final result = await ref
          .read(applicationRepositoryProvider)
          .getMyApplications({"page": state.page + 1, "limit": ApiConstants.defaultPageSize});
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
}

final myApplicationsProvider = NotifierProvider<MyApplicationsNotifier, MyApplicationsState>(
  MyApplicationsNotifier.new,
);
