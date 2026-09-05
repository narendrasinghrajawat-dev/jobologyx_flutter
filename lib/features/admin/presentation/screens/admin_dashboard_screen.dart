import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../repositories/admin_repository.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("You'll need to log in again to continue."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Log out")),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("JobologyX Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Log out",
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, items: AdminNavItems.items),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text("Welcome back, ${user?.name ?? ''}", style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            statsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: AppLoader()),
              error: (error, stackTrace) => AppErrorWidget(
                message: "Couldn't load platform stats.",
                onRetry: () => ref.invalidate(adminDashboardProvider),
              ),
              data: (stats) => _StatsGrid(stats: stats),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      (label: "Total Users", count: stats.totalUsers, color: theme.colorScheme.primary),
      (label: "Job Seekers", count: stats.totalJobSeekers, color: AppColors.info),
      (label: "Recruiters", count: stats.totalRecruiters, color: AppColors.statusShortlisted),
      (label: "Total Jobs", count: stats.totalJobs, color: theme.colorScheme.primary),
      (label: "Active Jobs", count: stats.activeJobs, color: AppColors.statusActive),
      (label: "Applications", count: stats.totalApplications, color: AppColors.info),
      (label: "Pending", count: stats.pendingApplications, color: AppColors.statusReviewing),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: tile.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${tile.count}", style: theme.textTheme.headlineMedium?.copyWith(color: tile.color)),
              const SizedBox(height: 2),
              Text(tile.label, style: theme.textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
