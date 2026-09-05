import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../jobs/models/job_model.dart';
import '../../providers/applied_job_ids_provider.dart';
import '../../providers/my_applications_provider.dart';
import '../../repositories/application_repository.dart';

/// Cover letter + submit, shown from Job Details. Resume is pulled from the
/// applicant's own profile — never re-uploaded here (per spec §31).
class ApplyBottomSheet extends ConsumerStatefulWidget {
  const ApplyBottomSheet({super.key, required this.job});

  final JobModel job;

  @override
  ConsumerState<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<ApplyBottomSheet> {
  final _coverLetterController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(applicationRepositoryProvider).applyToJob(
            jobId: widget.job.id,
            coverLetter: _coverLetterController.text.trim(),
          );
      ref.invalidate(appliedJobIdsProvider);
      ref.invalidate(myApplicationsProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final hasResume = (user?.resumeUrl.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Apply to ${widget.job.title}", style: theme.textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text(widget.job.companyName, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        if (!hasResume) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    "Upload a resume in your profile before applying.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: "Go to Profile",
            outlined: true,
            onPressed: () {
              Navigator.of(context).pop(false);
              context.push(AppRoutes.seekerProfile);
            },
          ),
        ] else ...[
          Row(
            children: [
              Icon(Icons.description_outlined, size: 18, color: theme.colorScheme.outline),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text("Your saved resume will be submitted with this application.", style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: "Cover Letter (optional)",
            controller: _coverLetterController,
            maxLines: 5,
            hint: "Tell the recruiter why you're a great fit...",
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(label: "Submit Application", isLoading: _isSubmitting, onPressed: _submit),
        ],
      ],
    );
  }
}
