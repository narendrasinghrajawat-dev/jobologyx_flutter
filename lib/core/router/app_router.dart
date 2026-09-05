import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/applications/presentation/screens/application_details_screen.dart';
import '../../features/applications/presentation/screens/my_applications_screen.dart';
import '../../features/jobs/presentation/screens/home_screen.dart';
import '../../features/jobs/presentation/screens/job_details_screen.dart';
import '../../features/jobs/presentation/screens/job_list_screen.dart';
import '../../features/jobs/presentation/screens/seeker_dashboard_screen.dart';
import '../../features/profile/presentation/screens/recruiter_profile_screen.dart';
import '../../features/profile/presentation/screens/seeker_profile_screen.dart';
import '../../features/recruiter/presentation/screens/create_edit_job_screen.dart';
import '../../features/recruiter/presentation/screens/recruiter_applications_screen.dart';
import '../../features/recruiter/presentation/screens/recruiter_dashboard_screen.dart';
import '../../features/recruiter/presentation/screens/recruiter_jobs_screen.dart';
import 'app_routes.dart';

/// Public/guest-accessible routes — a signed-out visitor can browse these
/// without being bounced to `/login` (per spec §25/§28: the landing page and
/// job browsing are open pre-login; only actions like applying require auth).
bool _isGuestAccessible(String location) {
  return location == AppRoutes.splash ||
      location == AppRoutes.login ||
      location == AppRoutes.register ||
      location == AppRoutes.seekerJobs ||
      location.startsWith("/seeker/jobs/");
}

/// Bridges Riverpod's [authProvider] into GoRouter's `refreshListenable` so a
/// login/logout/session-expiry immediately re-runs [_redirect] instead of
/// waiting for the next manual navigation.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }
}

final _routerRefreshProvider = Provider<_RouterRefreshNotifier>((ref) {
  return _RouterRefreshNotifier(ref);
});

String _homeForRole(String role) {
  switch (role) {
    case UserRole.recruiter:
      return AppRoutes.recruiterDashboard;
    case UserRole.admin:
      return AppRoutes.adminDashboard;
    case UserRole.jobSeeker:
    default:
      return AppRoutes.seekerDashboard;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Reads via the live container from `context` rather than the `ref`
      // captured when this GoRouter was built: that captured `ref` belongs
      // to `routerProvider`'s own build, and Riverpod flags it unsafe to
      // reuse from a callback invoked outside that build — this trips its
      // "ref used before provider rebuilt" guard as soon as `authProvider`
      // changes state. `ProviderContainer.read` has no such restriction.
      final authState = ProviderScope.containerOf(context).read(authProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == AppRoutes.login || location == AppRoutes.register;
      final isSplash = location == AppRoutes.splash;

      switch (authState.status) {
        case AuthStatus.initial:
        case AuthStatus.loading:
          return isSplash ? null : AppRoutes.splash;
        case AuthStatus.error:
          return isSplash ? null : AppRoutes.splash;
        case AuthStatus.unauthenticated:
          return _isGuestAccessible(location) ? null : AppRoutes.login;
        case AuthStatus.authenticated:
          if (isSplash || isAuthRoute) {
            return _homeForRole(authState.user!.role);
          }
          return null;
      }
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const _RootScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: AppRoutes.seekerJobs, builder: (context, state) => const JobListScreen()),
      GoRoute(
        path: AppRoutes.seekerJobDetails,
        builder: (context, state) => JobDetailsScreen(jobId: state.pathParameters["id"]!),
      ),
      GoRoute(path: AppRoutes.seekerDashboard, builder: (context, state) => const SeekerDashboardScreen()),
      GoRoute(path: AppRoutes.seekerApplications, builder: (context, state) => const MyApplicationsScreen()),
      GoRoute(
        path: AppRoutes.seekerApplicationDetails,
        builder: (context, state) => ApplicationDetailsScreen(applicationId: state.pathParameters["id"]!),
      ),
      GoRoute(path: AppRoutes.seekerProfile, builder: (context, state) => const SeekerProfileScreen()),
      GoRoute(path: AppRoutes.recruiterDashboard, builder: (context, state) => const RecruiterDashboardScreen()),
      GoRoute(path: AppRoutes.recruiterJobs, builder: (context, state) => const RecruiterJobsScreen()),
      GoRoute(path: AppRoutes.recruiterJobCreate, builder: (context, state) => const CreateEditJobScreen()),
      GoRoute(
        path: AppRoutes.recruiterJobEdit,
        builder: (context, state) => CreateEditJobScreen(jobId: state.pathParameters["id"]!),
      ),
      GoRoute(path: AppRoutes.recruiterApplications, builder: (context, state) => const RecruiterApplicationsScreen()),
      GoRoute(path: AppRoutes.recruiterProfile, builder: (context, state) => const RecruiterProfileScreen()),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const _RoleHomePlaceholderScreen(title: "Admin Dashboard"),
      ),
    ],
  );
});

/// "/" itself: the boot spinner/retry while auth status is still
/// initial/loading/error, then the guest Home screen once it resolves to
/// unauthenticated (authenticated users never see this — redirect sends
/// them to their role dashboard first).
class _RootScreen extends ConsumerWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authProvider.select((s) => s.status));
    if (status == AuthStatus.unauthenticated) return const HomeScreen();
    return const SplashScreen();
  }
}

/// Stand-in for the real admin dashboard, which lands in Phase 6 (seeker
/// and recruiter dashboards are real as of Phases 4-5 — see
/// `SeekerDashboardScreen` / `RecruiterDashboardScreen`). Proves role-based
/// routing and logout work end-to-end for admin in the meantime.
class _RoleHomePlaceholderScreen extends ConsumerWidget {
  const _RoleHomePlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Log out",
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Text(
                  (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : "?",
                  style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text("Welcome, ${user?.name ?? ''}", style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text(
                "This dashboard is built in a later phase — auth, role\nrouting and logout are already wired up.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("You'll need to log in again to continue."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Log out")),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}
