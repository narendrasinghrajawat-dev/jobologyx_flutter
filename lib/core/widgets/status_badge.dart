import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/formatters.dart';

/// Colored pill for a job or application status string (e.g. "active",
/// "shortlisted"). Colors come from [AppColors] — unknown values fall back
/// to a neutral gray rather than crashing.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final String status;

  static const Map<String, Color> _colors = {
    // Job status
    "active": AppColors.statusActive,
    "closed": AppColors.statusClosed,
    "draft": AppColors.statusDraft,
    // Application status
    "applied": AppColors.statusApplied,
    "reviewing": AppColors.statusReviewing,
    "shortlisted": AppColors.statusShortlisted,
    "rejected": AppColors.statusRejected,
    "hired": AppColors.statusHired,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        Formatters.snakeCaseToTitle(status),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
