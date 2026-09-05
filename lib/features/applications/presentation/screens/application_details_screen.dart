import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/application_model.dart';
import '../../providers/application_details_provider.dart';
import '../../repositories/application_repository.dart';

const Map<String, String> _statusDescriptions = {
  "applied": "Your application has been submitted and is waiting to be reviewed.",
  "reviewing": "The recruiter is currently reviewing your application.",
  "shortlisted": "You've been shortlisted — the recruiter may reach out soon.",
  "rejected": "The recruiter has decided not to move forward at this time.",
  "hired": "Congratulations — you've been hired for this role!",
};

class ApplicationDetailsScreen extends ConsumerWidget {
  const ApplicationDetailsScreen({super.key, required this.applicationId});

  final String applicationId;

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String newStatus) async {
    try {
      await ref.read(applicationRepositoryProvider).updateApplicationStatus(applicationId, newStatus);
      ref.invalidate(applicationDetailsProvider(applicationId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status updated")));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync = ref.watch(applicationDetailsProvider(applicationId));
    final isRecruiter = ref.watch(authProvider).user?.isRecruiter ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Details"),
        actions: [
          if (isRecruiter)
            PopupMenuButton<String>(
              tooltip: "Update status",
              icon: const Icon(Icons.edit_note_rounded),
              onSelected: (status) => _updateStatus(context, ref, status),
              itemBuilder: (context) => const [
                PopupMenuItem(value: ApplicationStatus.applied, child: Text("Applied")),
                PopupMenuItem(value: ApplicationStatus.reviewing, child: Text("Reviewing")),
                PopupMenuItem(value: ApplicationStatus.shortlisted, child: Text("Shortlisted")),
                PopupMenuItem(value: ApplicationStatus.rejected, child: Text("Rejected")),
                PopupMenuItem(value: ApplicationStatus.hired, child: Text("Hired")),
              ],
            ),
        ],
      ),
      body: applicationAsync.when(
        loading: () => const AppLoader(),
        error: (error, stackTrace) => AppErrorWidget(
          message: "Couldn't load this application.",
          onRetry: () => ref.invalidate(applicationDetailsProvider(applicationId)),
        ),
        data: (application) => _ApplicationDetailsBody(application: application, isRecruiter: isRecruiter),
      ),
    );
  }
}

class _ApplicationDetailsBody extends StatelessWidget {
  const _ApplicationDetailsBody({required this.application, required this.isRecruiter});

  final ApplicationModel application;
  final bool isRecruiter;

  Future<void> _openResume(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't open the resume link")));
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = application.job;
    final applicant = application.applicant;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAvatar(fallbackText: job.companyName ?? job.title, radius: 26),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title ?? "Job posting removed", style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(job.companyName ?? "", style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isRecruiter) ...[
          _SectionCard(
            title: "Applicant",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(applicant.name ?? "Unknown", style: theme.textTheme.bodyLarge),
                if (applicant.email != null) Text(applicant.email!, style: theme.textTheme.bodyMedium),
                if (applicant.phone != null && applicant.phone!.isNotEmpty)
                  Text(applicant.phone!, style: theme.textTheme.bodyMedium),
                if (applicant.skills != null && applicant.skills!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: applicant.skills!.map((s) => Chip(label: Text(s), visualDensity: VisualDensity.compact)).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Status", style: theme.textTheme.labelLarge),
                    const Spacer(),
                    StatusBadge(application.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _statusDescriptions[application.status] ?? "",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: "Applied",
          child: Text(Formatters.relativeDate(application.createdAt), style: theme.textTheme.bodyMedium),
        ),
        if (application.coverLetter.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: "Cover Letter",
            child: Text(application.coverLetter, style: theme.textTheme.bodyMedium),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: "Resume",
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: Text("Resume submitted with this application")),
              TextButton(onPressed: () => _openResume(context, application.resumeUrl), child: const Text("View")),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
