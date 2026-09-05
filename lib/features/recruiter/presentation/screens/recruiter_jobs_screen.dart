import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_filter_menu.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../jobs/models/job_model.dart';
import '../../../jobs/models/job_options.dart';
import '../../providers/recruiter_jobs_provider.dart';
import '../widgets/recruiter_job_card.dart';

class RecruiterJobsScreen extends ConsumerStatefulWidget {
  const RecruiterJobsScreen({super.key});

  @override
  ConsumerState<RecruiterJobsScreen> createState() => _RecruiterJobsScreenState();
}

class _RecruiterJobsScreenState extends ConsumerState<RecruiterJobsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(recruiterJobsProvider);
    if (state.jobs.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(recruiterJobsProvider.notifier).loadInitial());
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
      ref.read(recruiterJobsProvider.notifier).loadMore();
    }
  }

  Future<void> _confirmDelete(JobModel job) async {
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
    final success = await ref.read(recruiterJobsProvider.notifier).deleteJob(job.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Job deleted" : "Couldn't delete this job")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recruiterJobsProvider);

    ref.listen(recruiterJobsProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Jobs"),
        actions: [
          AppFilterMenu(
            value: state.statusFilter,
            options: JobOptions.jobStatuses,
            onChanged: (value) => ref.read(recruiterJobsProvider.notifier).setStatusFilter(value),
            icon: Icons.filter_list_rounded,
            allLabel: "All Statuses",
            tooltip: "Filter by status",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createOrEditJob(AppRoutes.recruiterJobCreate),
        icon: const Icon(Icons.add_rounded),
        label: const Text("New Job"),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1, items: RecruiterNavItems.items),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RecruiterJobsState state) {
    if (state.isLoading && state.jobs.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.jobs.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(recruiterJobsProvider.notifier).loadInitial(),
      );
    }
    if (state.jobs.isEmpty) {
      return AppEmptyWidget(
        message: "You haven't posted any jobs yet.",
        icon: Icons.work_off_outlined,
        actionLabel: "Post a Job",
        onAction: () => context.push(AppRoutes.recruiterJobCreate),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(recruiterJobsProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.jobs.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.jobs.length) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: AppLoader());
          }
          final job = state.jobs[index];
          return RecruiterJobCard(
            job: job,
            onTap: () => context.push(AppRoutes.seekerJobDetailsPath(job.id)),
            onEdit: () => _createOrEditJob(AppRoutes.recruiterJobEditPath(job.id)),
            onDelete: () => _confirmDelete(job),
          );
        },
      ),
    );
  }

  /// Create/Edit is a pushed screen that pops `true` on success — refresh
  /// the list on return so a newly-created or edited job shows up without
  /// the user having to pull-to-refresh manually.
  Future<void> _createOrEditJob(String route) async {
    final result = await context.push<bool>(route);
    if (result == true) {
      ref.read(recruiterJobsProvider.notifier).refresh();
    }
  }
}
