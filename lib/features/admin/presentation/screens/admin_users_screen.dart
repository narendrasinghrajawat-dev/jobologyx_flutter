import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_filter_menu.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/admin_users_provider.dart';

const List<AppDropdownOption<String>> _roleOptions = [
  AppDropdownOption(UserRole.jobSeeker, "Job Seekers"),
  AppDropdownOption(UserRole.recruiter, "Recruiters"),
  AppDropdownOption(UserRole.admin, "Admins"),
];

const List<AppDropdownOption<String>> _activeOptions = [
  AppDropdownOption("true", "Active"),
  AppDropdownOption("false", "Inactive"),
];

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(adminUsersProvider);
    if (state.users.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(adminUsersProvider.notifier).loadInitial());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminUsersProvider.notifier).loadMore();
    }
  }

  Future<void> _toggleActive(UserModel user) async {
    final success = await ref.read(adminUsersProvider.notifier).toggleActive(user.id, !user.isActive);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "User ${user.isActive ? 'deactivated' : 'activated'}" : "Couldn't update user")),
    );
  }

  Future<void> _confirmDelete(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete user?"),
        content: Text('This will permanently delete "${user.name}". This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Delete")),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "User deleted" : "Couldn't delete this user")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);

    ref.listen(adminUsersProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        actions: [
          AppFilterMenu(
            value: state.roleFilter,
            options: _roleOptions,
            onChanged: (value) => ref
                .read(adminUsersProvider.notifier)
                .setFilters(role: value, clearRole: value == null),
            icon: Icons.filter_list_rounded,
            allLabel: "All Roles",
            tooltip: "Filter by role",
          ),
          AppFilterMenu(
            value: switch (state.activeFilter) { true => "true", false => "false", null => null },
            options: _activeOptions,
            onChanged: (value) {
              final isActive = switch (value) { "true" => true, "false" => false, _ => null };
              ref.read(adminUsersProvider.notifier).setFilters(isActive: isActive, clearActive: isActive == null);
            },
            icon: Icons.toggle_on_outlined,
            allLabel: "All Statuses",
            tooltip: "Filter by status",
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, items: AdminNavItems.items),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AdminUsersState state) {
    if (state.isLoading && state.users.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.users.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminUsersProvider.notifier).loadInitial(),
      );
    }
    if (state.users.isEmpty) {
      return const AppEmptyWidget(message: "No users match these filters.", icon: Icons.people_outline_rounded);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.users.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.users.length) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: AppLoader());
          }
          final user = state.users[index];
          final isCurrentUser = user.id == ref.watch(authProvider.select((s) => s.user?.id));
          return _UserCard(
            user: user,
            isCurrentUser: isCurrentUser,
            onToggleActive: () => _toggleActive(user),
            onDelete: () => _confirmDelete(user),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isCurrentUser,
    required this.onToggleActive,
    required this.onDelete,
  });

  final UserModel user;

  /// The backend correctly 403s any further request once an account is
  /// deactivated — including one from an admin who just deactivated
  /// *themselves*, permanently locking them out with no way to self-
  /// reactivate. Hiding these actions on the admin's own row prevents that
  /// dead end entirely, rather than trying to recover from it after the fact.
  final bool isCurrentUser;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(imageUrl: user.profileImage, fallbackText: user.name, radius: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 15)),
                  Text(user.email, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      Chip(
                        label: Text(Formatters.snakeCaseToTitle(user.role)),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(user.isActive ? "Active" : "Inactive"),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: (user.isActive ? theme.colorScheme.primary : theme.colorScheme.error)
                            .withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("Joined ${Formatters.relativeDate(user.createdAt)}", style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text("You", style: theme.textTheme.bodySmall),
              )
            else
              PopupMenuButton<String>(
                onSelected: (value) => value == "toggle" ? onToggleActive() : onDelete(),
                itemBuilder: (context) => [
                  PopupMenuItem(value: "toggle", child: Text(user.isActive ? "Deactivate" : "Activate")),
                  const PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
