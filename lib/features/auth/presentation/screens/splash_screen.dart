import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_button.dart';
import '../../providers/auth_provider.dart';

/// Kicks off the token check and shows the brand while `GoRouter`'s redirect
/// (driven by [authProvider]) decides where to send the user next. On a
/// network failure the check surfaces a retry instead of stranding the user.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).checkAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isError = authState.status == AuthStatus.error;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text("JobologyX", style: theme.textTheme.headlineLarge),
              const SizedBox(height: 32),
              if (!isError) const CircularProgressIndicator(),
              if (isError) ...[
                Text(
                  authState.errorMessage ?? "Something went wrong. Please try again.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: "Retry",
                  onPressed: () => ref.read(authProvider.notifier).checkAuthStatus(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
