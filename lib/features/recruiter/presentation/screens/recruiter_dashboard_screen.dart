import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../applications/models/application_model.dart';
import '../../../applications/repositories/application_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../jobs/models/job_model.dart';
import '../../../jobs/repositories/job_repository.dart';
import '../../presentation/widgets/recruiter_application_card.dart';
import '../../presentation/widgets/recruiter_job_card.dart';
import '../../providers/recruiter_dashboard_provider.dart';

/// The recruiter's "Dashboard" tab (§38): job and application counts, plus
/// recent activity. Like the seeker dashboard, there's no dedicated stats
/// endpoint, so counts come from one batch fetch each in
/// [recruiterDashboardProvider].
class RecruiterDashboardScreen extends ConsumerWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final summaryAsync = ref.watch(recruiterDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("JobologyX")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, items: RecruiterNavItems.items),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(recruiterDashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text("Welcome back, ${user?.name ?? ''}", style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            summaryAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.lg), child: AppLoader()),
              error: (error, stackTrace) => AppErrorWidget(
                message: "Couldn't load your dashboard.",
                onRetry: () => ref.invalidate(recruiterDashboardProvider),
              ),
              data: (summary) => _DashboardSummary(summary: summary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummary extends ConsumerWidget {
  const _DashboardSummary({required this.summary});

  final RecruiterDashboardSummary summary;

  Future<void> _editJob(BuildContext context, WidgetRef ref, String jobId) async {
    final result = await context.push<bool>(AppRoutes.recruiterJobEditPath(jobId));
    if (result == true) ref.invalidate(recruiterDashboardProvider);
  }

  Future<void> _confirmDeleteJob(BuildContext context, WidgetRef ref, JobModel job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete job?"),
        content: Text('This will permanently delete "${job.title}". This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Delete")),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(jobRepositoryProvider).deleteJob(job.id);
      ref.invalidate(recruiterDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Job deleted")));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String applicationId, String status) async {
    try {
      await ref.read(applicationRepositoryProvider).updateApplicationStatus(applicationId, status);
      ref.invalidate(recruiterDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status updated")));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeJobs = summary.jobs.where((j) => j.isActive).length;
    final reviewing = summary.applications.where((a) => a.status == ApplicationStatus.reviewing).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatTile(label: "Total Jobs", count: summary.totalJobs, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            _StatTile(label: "Active Jobs", count: activeJobs, color: AppColors.statusActive),
            const SizedBox(width: AppSpacing.sm),
            _StatTile(label: "Applications", count: summary.totalApplications, color: AppColors.info),
            const SizedBox(width: AppSpacing.sm),
            _StatTile(label: "Reviewing", count: reviewing, color: AppColors.statusReviewing),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Jobs", style: theme.textTheme.headlineSmall),
            if (summary.jobs.isNotEmpty)
              TextButton(onPressed: () => context.go(AppRoutes.recruiterJobs), child: const Text("View All")),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.jobs.isEmpty)
          Text("You haven't posted any jobs yet.", style: theme.textTheme.bodyMedium)
        else
          ...summary.jobs.take(3).map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: RecruiterJobCard(
                    job: job,
                    onTap: () => context.push(AppRoutes.seekerJobDetailsPath(job.id)),
                    onEdit: () => _editJob(context, ref, job.id),
                    onDelete: () => _confirmDeleteJob(context, ref, job),
                  ),
                ),
              ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Applications", style: theme.textTheme.headlineSmall),
            if (summary.applications.isNotEmpty)
              TextButton(onPressed: () => context.go(AppRoutes.recruiterApplications), child: const Text("View All")),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.applications.isEmpty)
          Text("No applications yet.", style: theme.textTheme.bodyMedium)
        else
          ...summary.applications.take(3).map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: RecruiterApplicationCard(
                    application: application,
                    onTap: () => context.push(AppRoutes.seekerApplicationDetailsPath(application.id)),
                    onStatusChanged: (status) => _updateStatus(context, ref, application.id, status),
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
