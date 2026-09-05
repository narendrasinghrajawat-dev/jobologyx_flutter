import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'app_button.dart';

/// Shared error state for a failed fetch — friendly copy, no stack traces,
/// with a retry action.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(label: "Retry", onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
