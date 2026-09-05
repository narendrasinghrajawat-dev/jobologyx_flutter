import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../applications/presentation/widgets/apply_bottom_sheet.dart';
import '../../../applications/providers/applied_job_ids_provider.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/job_model.dart';
import '../../providers/job_details_provider.dart';

class JobDetailsScreen extends ConsumerWidget {
  const JobDetailsScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailsProvider(jobId));

    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),
      body: jobAsync.when(
        loading: () => const AppLoader(),
        error: (error, stackTrace) => AppErrorWidget(
          message: error is Exception ? error.toString().replaceFirst("Exception: ", "") : "Something went wrong.",
          onRetry: () => ref.invalidate(jobDetailsProvider(jobId)),
        ),
        data: (job) => _JobDetailsBody(job: job),
      ),
    );
  }
}

class _JobDetailsBody extends ConsumerWidget {
  const _JobDetailsBody({required this.job});

  final JobModel job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(imageUrl: job.companyLogo, fallbackText: job.companyName, radius: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.title, style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 2),
                          Text(job.companyName, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Chip(avatar: const Icon(Icons.location_on_outlined, size: 16), label: Text(job.location)),
                    Chip(
                      avatar: const Icon(Icons.work_outline_rounded, size: 16),
                      label: Text(Formatters.snakeCaseToTitle(job.jobType)),
                    ),
                    Chip(
                      avatar: const Icon(Icons.laptop_mac_outlined, size: 16),
                      label: Text(Formatters.snakeCaseToTitle(job.workMode)),
                    ),
                    if (job.experience.isNotEmpty)
                      Chip(avatar: const Icon(Icons.timeline_outlined, size: 16), label: Text(job.experience)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: "Compensation",
                  child: Text(
                    Formatters.salaryRange(job.salaryMin, job.salaryMax),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: "Description",
                  child: Text(job.description, style: theme.textTheme.bodyMedium),
                ),
                if (job.skills.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: "Skills",
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.skills.map((s) => Chip(label: Text(s))).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: "Posted",
                  child: Text(Formatters.relativeDate(job.createdAt), style: theme.textTheme.bodyMedium),
                ),
                if (job.applicationDeadline != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: "Application Deadline",
                    child: Text(Formatters.relativeDate(job.applicationDeadline), style: theme.textTheme.bodyMedium),
                  ),
                ],
              ],
            ),
          ),
        ),
        _buildActionBar(context, ref, user),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context, WidgetRef ref, UserModel? user) {
    final theme = Theme.of(context);
    final isSeekerOrGuest = user == null || user.isJobSeeker;
    if (!isSeekerOrGuest) return const SizedBox.shrink();

    String label;
    VoidCallback? onPressed;

    // Only fetched for a signed-in seeker — a guest has no applications to
    // check, and the endpoint requires auth anyway.
    final hasApplied = user != null &&
        ref.watch(appliedJobIdsProvider).maybeWhen(data: (ids) => ids.contains(job.id), orElse: () => false);

    if (!job.isAcceptingApplications) {
      label = "Applications Closed";
      onPressed = null;
    } else if (user == null) {
      label = "Sign In to Apply";
      onPressed = () => context.push(AppRoutes.login);
    } else if (hasApplied) {
      label = "Already Applied";
      onPressed = null;
    } else {
      label = "Apply Now";
      onPressed = () async {
        final applied = await AppBottomSheet.show<bool>(context, builder: (context) => ApplyBottomSheet(job: job));
        if (applied == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application submitted!")));
        }
      };
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(label: label, onPressed: onPressed),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
