import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../auth/models/user_model.dart';
import '../repositories/admin_repository.dart';

class AdminUsersState {
  const AdminUsersState({
    this.users = const [],
    this.roleFilter,
    this.activeFilter,
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.loadMoreError,
  });

  final List<UserModel> users;
  final String? roleFilter;

  /// null = both active and inactive.
  final bool? activeFilter;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  AdminUsersState copyWith({
    List<UserModel>? users,
    String? roleFilter,
    bool clearRoleFilter = false,
    bool? activeFilter,
    bool clearActiveFilter = false,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    String? loadMoreError,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      activeFilter: clearActiveFilter ? null : (activeFilter ?? this.activeFilter),
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

/// Drives `/admin/users`: role + active/inactive filters, backend
/// pagination, activate/deactivate and delete actions.
class AdminUsersNotifier extends Notifier<AdminUsersState> {
  @override
  AdminUsersState build() => const AdminUsersState();

  Map<String, dynamic> _queryParams(int page) {
    final params = <String, dynamic>{"page": page, "limit": ApiConstants.defaultPageSize};
    if (state.roleFilter != null) params["role"] = state.roleFilter;
    if (state.activeFilter != null) params["isActive"] = state.activeFilter.toString();
    return params;
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await ref.read(adminRepositoryProvider).listUsers(_queryParams(1));
      state = state.copyWith(
        users: result.users,
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
      final result = await ref.read(adminRepositoryProvider).listUsers(_queryParams(1));
      state = state.copyWith(
        users: result.users,
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
      final result = await ref.read(adminRepositoryProvider).listUsers(_queryParams(state.page + 1));
      state = state.copyWith(
        users: [...state.users, ...result.users],
        page: result.pagination.page,
        totalPages: result.pagination.totalPages,
        isLoadingMore: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: e.message);
    }
  }

  void setFilters({String? role, bool clearRole = false, bool? isActive, bool clearActive = false}) {
    state = state.copyWith(roleFilter: role, clearRoleFilter: clearRole, activeFilter: isActive, clearActiveFilter: clearActive);
    loadInitial();
  }

  Future<bool> toggleActive(String userId, bool newValue) async {
    try {
      final updated = await ref.read(adminRepositoryProvider).updateUserStatus(userId, newValue);
      state = state.copyWith(users: state.users.map((u) => u.id == userId ? updated : u).toList());
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await ref.read(adminRepositoryProvider).deleteUser(userId);
      state = state.copyWith(users: state.users.where((u) => u.id != userId).toList());
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    }
  }
}

final adminUsersProvider = NotifierProvider<AdminUsersNotifier, AdminUsersState>(AdminUsersNotifier.new);
