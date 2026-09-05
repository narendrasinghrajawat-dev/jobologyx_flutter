import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/job_list_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_sheet.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(jobListProvider);
    if (state.jobs.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(jobListProvider.notifier).loadInitial());
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
      ref.read(jobListProvider.notifier).loadMore();
    }
  }

  void _openFilters() {
    final current = ref.read(jobListProvider).filter;
    AppBottomSheet.show(
      context,
      builder: (context) => JobFilterSheet(
        initialFilter: current,
        onApply: (filter) => ref.read(jobListProvider.notifier).applyFilters(filter),
        onClear: () => ref.read(jobListProvider.notifier).clearFilters(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobListProvider);
    final user = ref.watch(authProvider).user;
    final showSeekerNav = user?.role == UserRole.jobSeeker;

    ref.listen(jobListProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jobs"),
        automaticallyImplyLeading: !showSeekerNav,
        actions: [
          IconButton(
            icon: Icon(state.filter.hasActiveFilters ? Icons.filter_alt_rounded : Icons.filter_alt_outlined),
            tooltip: "Filters",
            onPressed: _openFilters,
          ),
        ],
      ),
      bottomNavigationBar: showSeekerNav ? const AppBottomNav(currentIndex: 1, items: SeekerNavItems.items) : null,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            AppSearchBar(
              hint: "Search jobs, companies, skills...",
              onChanged: (query) => ref.read(jobListProvider.notifier).updateSearch(query),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(JobListState state) {
    if (state.isLoading && state.jobs.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.jobs.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(jobListProvider.notifier).loadInitial(),
      );
    }
    if (state.jobs.isEmpty) {
      return AppEmptyWidget(
        message: "No jobs match your search right now.",
        icon: Icons.work_off_outlined,
        actionLabel: state.filter.hasActiveFilters ? "Clear filters" : null,
        onAction: state.filter.hasActiveFilters ? () => ref.read(jobListProvider.notifier).clearFilters() : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(jobListProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.jobs.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.jobs.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: AppLoader(),
            );
          }
          final job = state.jobs[index];
          return JobCard(job: job, onTap: () => context.push(AppRoutes.seekerJobDetailsPath(job.id)));
        },
      ),
    );
  }
}
