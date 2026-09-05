import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../applications/models/application_model.dart';
import '../../../applications/presentation/widgets/application_card.dart';
import '../../../applications/providers/dashboard_applications_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/featured_jobs_provider.dart';
import '../widgets/job_card.dart';

/// The seeker's "Home" tab (§32-34): application status counts, recent
/// applications, and a latest-jobs list. Since there's no seeker stats
/// endpoint, counts come from [dashboardApplicationsProvider].
class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final summaryAsync = ref.watch(dashboardApplicationsProvider);
    final featuredJobsAsync = ref.watch(featuredJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("JobologyX")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, items: SeekerNavItems.items),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardApplicationsProvider);
          ref.invalidate(featuredJobsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text("Welcome back, ${user?.name ?? ''}", style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            summaryAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: AppLoader()),
              error: (error, stackTrace) => AppErrorWidget(
                message: "Couldn't load your application stats.",
                onRetry: () => ref.invalidate(dashboardApplicationsProvider),
              ),
              data: (summary) => _DashboardSummary(summary: summary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Latest Jobs", style: theme.textTheme.headlineSmall),
                TextButton(onPressed: () => context.go(AppRoutes.seekerJobs), child: const Text("View All")),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            featuredJobsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: AppLoader()),
              error: (error, stackTrace) => AppErrorWidget(
                message: "Couldn't load jobs right now.",
                onRetry: () => ref.invalidate(featuredJobsProvider),
              ),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Text("No jobs posted yet — check back soon.", style: theme.textTheme.bodyMedium);
                }
                return Column(
                  children: jobs
                      .take(3)
                      .map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: JobCard(job: job, onTap: () => context.push(AppRoutes.seekerJobDetailsPath(job.id))),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({required this.summary});

  final DashboardApplicationsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = <String, int>{};
    for (final application in summary.applications) {
      counts[application.status] = (counts[application.status] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatTile(label: "Total", count: summary.totalCount, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            _StatTile(label: "Reviewing", count: counts[ApplicationStatus.reviewing] ?? 0, color: AppColors.statusReviewing),
            const SizedBox(width: AppSpacing.sm),
            _StatTile(
              label: "Shortlisted",
              count: counts[ApplicationStatus.shortlisted] ?? 0,
              color: AppColors.statusShortlisted,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatTile(label: "Rejected", count: counts[ApplicationStatus.rejected] ?? 0, color: AppColors.statusRejected),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Applications", style: theme.textTheme.headlineSmall),
            if (summary.applications.isNotEmpty)
              TextButton(onPressed: () => context.go(AppRoutes.seekerApplications), child: const Text("View All")),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.applications.isEmpty)
          Text("You haven't applied to any jobs yet.", style: theme.textTheme.bodyMedium)
        else
          ...summary.applications.take(3).map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ApplicationCard(
                    application: application,
                    onTap: () => context.push(AppRoutes.seekerApplicationDetailsPath(application.id)),
                  ),
                ),
              ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text("$count", style: theme.textTheme.headlineMedium?.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
