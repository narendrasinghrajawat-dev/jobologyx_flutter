import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../jobs/models/job_model.dart';

/// The job card used in `/recruiter/jobs` — shows status (any, unlike the
/// public listing) and exposes edit/delete instead of an apply action.
class RecruiterJobCard extends StatelessWidget {
  const RecruiterJobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
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
                        Text(job.title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          "${Formatters.snakeCaseToTitle(job.jobType)} • ${job.location}",
                          style: theme.textTheme.bodyMedium,
                        ),
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
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: "Edit",
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
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
