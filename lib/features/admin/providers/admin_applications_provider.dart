import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../models/admin_application_view.dart';
import '../repositories/admin_repository.dart';

class AdminApplicationsState {
  const AdminApplicationsState({
    this.applications = const [],
    this.statusFilter,
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<AdminApplicationView> applications;
  final String? statusFilter;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  AdminApplicationsState copyWith({
    List<AdminApplicationView>? applications,
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
    return AdminApplicationsState(
      applications: applications ?? this.applications,
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

/// Drives `/admin/applications` — read-only per §48 (view + status filter
/// only, no status-change action for admin, unlike the recruiter screen).
class AdminApplicationsNotifier extends Notifier<AdminApplicationsState> {
  @override
  AdminApplicationsState build() => const AdminApplicationsState();

  Map<String, dynamic> _queryParams(int page) {
    final params = <String, dynamic>{"page": page, "limit": ApiConstants.defaultPageSize};
    if (state.statusFilter != null) params["status"] = state.statusFilter;
    return params;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref.read(adminRepositoryProvider).listApplications(_queryParams(1));
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
      final result = await ref.read(adminRepositoryProvider).listApplications(_queryParams(1));
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
      final result = await ref.read(adminRepositoryProvider).listApplications(_queryParams(state.page + 1));
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

  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
    loadInitial();
  }
}

final adminApplicationsProvider =
    NotifierProvider<AdminApplicationsNotifier, AdminApplicationsState>(AdminApplicationsNotifier.new);
