import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../models/job_filter.dart';
import '../../models/job_options.dart';
import '../../providers/featured_jobs_provider.dart';
import '../../providers/job_list_provider.dart';
import '../widgets/job_card.dart';

/// Guest landing page — shown at "/" once the splash check resolves to
/// unauthenticated. Lets a visitor search or browse jobs before signing up.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _goToJobs(WidgetRef ref, BuildContext context, {String? search, String? category}) {
    final notifier = ref.read(jobListProvider.notifier);
    if (search != null) {
      notifier.updateSearch(search);
    } else if (category != null) {
      notifier.applyFilters(const JobFilter().copyWith(category: category));
    }
    context.push(AppRoutes.seekerJobs);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featuredJobsAsync = ref.watch(featuredJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("JobologyX"),
        actions: [
          TextButton(onPressed: () => context.push(AppRoutes.login), child: const Text("Log In")),
          TextButton(onPressed: () => context.push(AppRoutes.register), child: const Text("Register")),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(featuredJobsProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Find your next opportunity", style: theme.textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    "Search thousands of jobs from companies that are hiring now.",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppSearchBar(
                    hint: "Job title, skill, or company",
                    onChanged: (query) {
                      if (query.isNotEmpty) _goToJobs(ref, context, search: query);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Popular Categories", style: theme.textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: JobOptions.categories
                  .map(
                    (c) => ActionChip(
                      label: Text(c.label),
                      onPressed: () => _goToJobs(ref, context, category: c.value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Featured Jobs", style: theme.textTheme.headlineSmall),
                TextButton(onPressed: () => context.push(AppRoutes.seekerJobs), child: const Text("View All")),
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
                      .map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: JobCard(
                            job: job,
                            onTap: () => context.push(AppRoutes.seekerJobDetailsPath(job.id)),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Column(
                children: [
                  Text("New to JobologyX?", style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(label: "Create an Account", onPressed: () => context.push(AppRoutes.register)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
