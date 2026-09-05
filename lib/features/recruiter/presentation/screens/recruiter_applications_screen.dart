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
import '../../../applications/models/application_model.dart';
import '../../providers/recruiter_applications_provider.dart';
import '../../providers/recruiter_job_options_provider.dart';
import '../widgets/recruiter_application_card.dart';

class RecruiterApplicationsScreen extends ConsumerStatefulWidget {
  const RecruiterApplicationsScreen({super.key});

  @override
  ConsumerState<RecruiterApplicationsScreen> createState() => _RecruiterApplicationsScreenState();
}

class _RecruiterApplicationsScreenState extends ConsumerState<RecruiterApplicationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(recruiterApplicationsProvider);
    if (state.applications.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(recruiterApplicationsProvider.notifier).loadInitial());
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
      ref.read(recruiterApplicationsProvider.notifier).loadMore();
    }
  }

  Future<void> _updateStatus(ApplicationModel application, String newStatus) async {
    if (newStatus == application.status) return;
    final success = await ref.read(recruiterApplicationsProvider.notifier).updateStatus(application.id, newStatus);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Status updated" : "Couldn't update status")),
    );
  }

  void _openFilters() {
    final current = ref.read(recruiterApplicationsProvider);
    AppBottomSheet.show(
      context,
      // A plain `ref.read` snapshot here would never rebuild once
      // `recruiterJobOptionsProvider` finishes loading (this builder runs
      // once when the sheet opens, not on every provider change) — wrap in
      // Consumer so the job list appears as soon as the fetch resolves.
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final jobsAsync = ref.watch(recruiterJobOptionsProvider);
          return ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text("All Jobs"),
                trailing: current.jobFilter == null ? const Icon(Icons.check_rounded) : null,
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(recruiterApplicationsProvider.notifier).setFilters(clearJob: true);
                },
              ),
              ...jobsAsync.maybeWhen(
                data: (jobs) => jobs.map(
                  (job) => ListTile(
                    title: Text(job.title),
                    trailing: current.jobFilter == job.id ? const Icon(Icons.check_rounded) : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(recruiterApplicationsProvider.notifier).setFilters(jobId: job.id);
                    },
                  ),
                ),
                loading: () => [const Padding(padding: EdgeInsets.all(AppSpacing.md), child: AppLoader())],
                orElse: () => const <Widget>[],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recruiterApplicationsProvider);

    ref.listen(recruiterApplicationsProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Applications"),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), tooltip: "Filter by job", onPressed: _openFilters),
          PopupMenuButton<String?>(
            initialValue: state.statusFilter,
            tooltip: "Filter by status",
            onSelected: (value) => ref.read(recruiterApplicationsProvider.notifier).setFilters(
                  status: value,
                  clearStatus: value == null,
                ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: null, child: Text("All Statuses")),
              PopupMenuItem(value: ApplicationStatus.applied, child: Text("Applied")),
              PopupMenuItem(value: ApplicationStatus.reviewing, child: Text("Reviewing")),
              PopupMenuItem(value: ApplicationStatus.shortlisted, child: Text("Shortlisted")),
              PopupMenuItem(value: ApplicationStatus.rejected, child: Text("Rejected")),
              PopupMenuItem(value: ApplicationStatus.hired, child: Text("Hired")),
            ],
            icon: const Icon(Icons.checklist_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, items: RecruiterNavItems.items),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RecruiterApplicationsState state) {
    if (state.isLoading && state.applications.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.applications.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(recruiterApplicationsProvider.notifier).loadInitial(),
      );
    }
    if (state.applications.isEmpty) {
      return const AppEmptyWidget(
        message: "No applications yet for your jobs.",
        icon: Icons.people_outline_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(recruiterApplicationsProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.applications.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.applications.length) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: AppLoader());
          }
          final application = state.applications[index];
          return RecruiterApplicationCard(
            application: application,
            onTap: () => context.push(AppRoutes.seekerApplicationDetailsPath(application.id)),
            onStatusChanged: (status) => _updateStatus(application, status),
          );
        },
      ),
    );
  }
}
