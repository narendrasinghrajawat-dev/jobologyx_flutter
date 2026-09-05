import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_filter_menu.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../jobs/models/job_options.dart';
import '../../models/admin_job_view.dart';
import '../../providers/admin_jobs_provider.dart';

class AdminJobsScreen extends ConsumerStatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  ConsumerState<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends ConsumerState<AdminJobsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(adminJobsProvider);
    if (state.jobs.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(adminJobsProvider.notifier).loadInitial());
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
      ref.read(adminJobsProvider.notifier).loadMore();
    }
  }

  Future<void> _changeStatus(AdminJobView job, String newStatus) async {
    if (newStatus == job.status) return;
    final success = await ref.read(adminJobsProvider.notifier).updateStatus(job.id, newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Status updated" : "Couldn't update status")),
    );
  }

  Future<void> _confirmDelete(AdminJobView job) async {
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
    final success = await ref.read(adminJobsProvider.notifier).deleteJob(job.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Job deleted" : "Couldn't delete this job")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminJobsProvider);

    ref.listen(adminJobsProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobs"),
        actions: [
          AppFilterMenu(
            value: state.statusFilter,
            options: JobOptions.jobStatuses,
            onChanged: (value) => ref.read(adminJobsProvider.notifier).setStatusFilter(value),
            icon: Icons.filter_list_rounded,
            allLabel: "All Statuses",
            tooltip: "Filter by status",
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, items: AdminNavItems.items),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AdminJobsState state) {
    if (state.isLoading && state.jobs.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.jobs.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminJobsProvider.notifier).loadInitial(),
      );
    }
    if (state.jobs.isEmpty) {
      return const AppEmptyWidget(message: "No jobs match this filter.", icon: Icons.work_off_outlined);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminJobsProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.jobs.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.jobs.length) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: AppLoader());
          }
          final job = state.jobs[index];
          return _AdminJobCard(
            job: job,
            onView: () => context.push(AppRoutes.seekerJobDetailsPath(job.id)),
            onStatusChanged: (status) => _changeStatus(job, status),
            onDelete: () => _confirmDelete(job),
          );
        },
      ),
    );
  }
}

class _AdminJobCard extends StatelessWidget {
  const _AdminJobCard({required this.job, required this.onView, required this.onStatusChanged, required this.onDelete});

  final AdminJobView job;
  final VoidCallback onView;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 15)),
                        Text(job.companyName, style: theme.textTheme.bodyMedium),
                        Text("Posted by ${job.recruiterName}", style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  StatusBadge(job.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(Formatters.relativeDate(job.createdAt), style: theme.textTheme.bodySmall),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: "Change status",
                    onSelected: onStatusChanged,
                    itemBuilder: (context) => JobOptions.jobStatuses
                        .map((o) => PopupMenuItem(value: o.value, child: Text(o.label)))
                        .toList(),
                    icon: const Icon(Icons.sync_alt_rounded, size: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded, size: 20, color: theme.colorScheme.error),
                    tooltip: "Delete",
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
