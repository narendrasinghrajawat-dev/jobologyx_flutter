import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application, required this.onTap});

  final ApplicationModel application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = application.job;

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
                        Text(
                          job.title ?? "Job posting removed",
                          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(job.companyName ?? "", style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  StatusBadge(application.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Applied ${Formatters.relativeDate(application.createdAt)}",
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
