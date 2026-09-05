import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../providers/my_applications_provider.dart';
import '../widgets/application_card.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(myApplicationsProvider);
    if (state.applications.isEmpty && !state.isLoading) {
      Future.microtask(() => ref.read(myApplicationsProvider.notifier).loadInitial());
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
      ref.read(myApplicationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myApplicationsProvider);

    ref.listen(myApplicationsProvider.select((s) => s.loadMoreError), (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2, items: SeekerNavItems.items),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(MyApplicationsState state) {
    if (state.isLoading && state.applications.isEmpty) {
      return const AppLoader();
    }
    if (state.errorMessage != null && state.applications.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(myApplicationsProvider.notifier).loadInitial(),
      );
    }
    if (state.applications.isEmpty) {
      return AppEmptyWidget(
        message: "You haven't applied to any jobs yet.",
        icon: Icons.article_outlined,
        actionLabel: "Browse Jobs",
        onAction: () => context.go(AppRoutes.seekerJobs),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myApplicationsProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: state.applications.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= state.applications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: AppLoader(),
            );
          }
          final application = state.applications[index];
          return ApplicationCard(
            application: application,
            onTap: () => context.push(AppRoutes.seekerApplicationDetailsPath(application.id)),
          );
        },
      ),
    );
  }
}
