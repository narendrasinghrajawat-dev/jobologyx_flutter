import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_filter_menu.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../applications/models/application_model.dart';
import '../../models/admin_application_view.dart';
import '../../providers/admin_applications_provider.dart';

const List<AppDropdownOption<String>> _applicationStatusOptions = [
  AppDropdownOption(ApplicationStatus.applied, "Applied"),
  AppDropdownOption(ApplicationStatus.reviewing, "Reviewing"),
  AppDropdownOption(ApplicationStatus.shortlisted, "Shortlisted"),
  AppDropdownOption(ApplicationStatus.rejected, "Rejected"),
  AppDropdownOption(ApplicationStatus.hired, "Hired"),
];

class AdminApplicationsScreen extends ConsumerStatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  ConsumerState<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends ConsumerState<AdminApplicationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(adminApplicationsProvider);
    if (state.applications.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(adminApplicationsProvider.notifier).loadInitial());
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
      ref.read(adminApplicationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminApplicationsProvider);

    ref.listen(adminApplicationsProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Applications"),
        actions: [
          AppFilterMenu(
            value: state.statusFilter,
            options: _applicationStatusOptions,
            onChanged: (value) => ref.read(adminApplicationsProvider.notifier).setStatusFilter(value),
            icon: Icons.filter_list_rounded,
            allLabel: "All Statuses",
            tooltip: "Filter by status",
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3, items: AdminNavItems.items),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AdminApplicationsState state) {
    if (state.isLoading && state.applications.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.applications.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(adminApplicationsProvider.notifier).loadInitial(),
      );
    }
    if (state.applications.isEmpty) {
      return const AppEmptyWidget(message: "No applications match this filter.", icon: Icons.article_outlined);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminApplicationsProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.applications.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.applications.length) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: AppLoader());
          }
          return _AdminApplicationCard(application: state.applications[index]);
        },
      ),
    );
  }
}

class _AdminApplicationCard extends StatelessWidget {
  const _AdminApplicationCard({required this.application});

  final AdminApplicationView application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                      Text(application.applicantName, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 15)),
                      Text("Applied for ${application.jobTitle}", style: theme.textTheme.bodyMedium),
                      Text("Recruiter: ${application.recruiterName}", style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusBadge(application.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text("Applied ${Formatters.relativeDate(application.createdAt)}", style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
