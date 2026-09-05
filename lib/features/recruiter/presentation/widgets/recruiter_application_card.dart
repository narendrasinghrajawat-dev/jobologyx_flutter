import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../applications/models/application_model.dart';

const List<String> _statusOptions = [
  ApplicationStatus.applied,
  ApplicationStatus.reviewing,
  ApplicationStatus.shortlisted,
  ApplicationStatus.rejected,
  ApplicationStatus.hired,
];

/// The application card used in `/recruiter/applications` — shows the
/// applicant (not just the job) and lets the recruiter change status inline
/// via a popup menu, per §43.
class RecruiterApplicationCard extends StatelessWidget {
  const RecruiterApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    required this.onStatusChanged,
  });

  final ApplicationModel application;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applicant = application.applicant;
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
                  AppAvatar(fallbackText: applicant.name, radius: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.name ?? "Applicant",
                          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text("Applied for ${job.title ?? 'a job posting'}", style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    "Applied ${Formatters.relativeDate(application.createdAt)}",
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    initialValue: application.status,
                    onSelected: onStatusChanged,
                    itemBuilder: (context) => _statusOptions
                        .map((s) => PopupMenuItem(value: s, child: Text(Formatters.snakeCaseToTitle(s))))
                        .toList(),
                    child: IgnorePointer(child: StatusBadge(application.status)),
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
