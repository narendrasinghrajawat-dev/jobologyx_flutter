import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.activeIcon, required this.label, required this.route});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// Shared bottom navigation bar for the four root tabs of a role's
/// experience (§52). Each tab is its own top-level `GoRoute`; tapping
/// navigates via `context.go` rather than swapping an `IndexedStack`, so the
/// URL always reflects what's on screen. Only rendered by screens that are
/// actual tab roots — detail/push screens (job details, application
/// details, create/edit forms) never show it.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.items});

  final int currentIndex;
  final List<AppBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) context.go(items[index].route);
      },
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              ))
          .toList(),
    );
  }
}

/// The seeker's four tabs, in display order — used by the dashboard, jobs,
/// applications, and profile screens to build a consistent `AppBottomNav`.
class SeekerNavItems {
  SeekerNavItems._();

  static const List<AppBottomNavItem> items = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: "Home",
      route: AppRoutes.seekerDashboard,
    ),
    AppBottomNavItem(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: "Jobs",
      route: AppRoutes.seekerJobs,
    ),
    AppBottomNavItem(
      icon: Icons.article_outlined,
      activeIcon: Icons.article_rounded,
      label: "Applications",
      route: AppRoutes.seekerApplications,
    ),
    AppBottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: "Profile",
      route: AppRoutes.seekerProfile,
    ),
  ];
}
