import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../jobs/models/job_model.dart';
import '../../../jobs/models/job_options.dart';
import '../../../jobs/providers/job_details_provider.dart';
import '../../../jobs/repositories/job_repository.dart';

/// Create when [jobId] is null, edit otherwise. Company name/logo are never
/// collected here — the backend auto-fills them from the recruiter's own
/// profile at creation time (§41) — shown read-only instead, for
/// confirmation.
class CreateEditJobScreen extends ConsumerStatefulWidget {
  const CreateEditJobScreen({super.key, this.jobId});

  final String? jobId;

  @override
  ConsumerState<CreateEditJobScreen> createState() => _CreateEditJobScreenState();
}

class _CreateEditJobScreenState extends ConsumerState<CreateEditJobScreen> {
  bool get _isEditing => widget.jobId != null;

  @override
  Widget build(BuildContext context) {
    if (!_isEditing) {
      return Scaffold(
        appBar: AppBar(title: const Text("Post a Job")),
        body: _JobForm(initialJob: null),
      );
    }

    final jobAsync = ref.watch(jobDetailsProvider(widget.jobId!));
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Job")),
      body: jobAsync.when(
        loading: () => const AppLoader(),
        error: (error, stackTrace) => AppErrorWidget(
          message: "Couldn't load this job.",
          onRetry: () => ref.invalidate(jobDetailsProvider(widget.jobId!)),
        ),
        data: (job) => _JobForm(initialJob: job),
      ),
    );
  }
}

class _JobForm extends ConsumerStatefulWidget {
  const _JobForm({required this.initialJob});

  final JobModel? initialJob;

  @override
  ConsumerState<_JobForm> createState() => _JobFormState();
}

class _JobFormState extends ConsumerState<_JobForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.initialJob?.title ?? "");
  late final _descriptionController = TextEditingController(text: widget.initialJob?.description ?? "");
  late final _locationController = TextEditingController(text: widget.initialJob?.location ?? "");
  late final _salaryMinController = TextEditingController(text: widget.initialJob?.salaryMin.toString() ?? "");
  late final _salaryMaxController = TextEditingController(text: widget.initialJob?.salaryMax.toString() ?? "");
  final _skillInputController = TextEditingController();

  String? _jobType;
  String? _workMode;
  String? _category;
  String? _experience;
  String _status = "active";
  DateTime? _applicationDeadline;
  late final List<String> _skills = List<String>.from(widget.initialJob?.skills ?? []);

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final job = widget.initialJob;
    _jobType = job?.jobType;
    _workMode = job?.workMode;
    _category = job?.category.isNotEmpty == true ? job!.category : null;
    _experience = job?.experience.isNotEmpty == true ? job!.experience : null;
    _status = job?.status ?? "active";
    _applicationDeadline = job?.applicationDeadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill(String value) {
    final skill = value.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() {
      _skills.add(skill);
      _skillInputController.clear();
    });
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _applicationDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _applicationDeadline = picked);
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_jobType == null || _workMode == null) {
      setState(() => _errorMessage = "Job Type and Work Mode are required");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final data = <String, dynamic>{
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "location": _locationController.text.trim(),
      "jobType": _jobType,
      "workMode": _workMode,
      "salaryMin": num.tryParse(_salaryMinController.text.trim()) ?? 0,
      "salaryMax": num.tryParse(_salaryMaxController.text.trim()) ?? 0,
      "experience": _experience ?? "",
      "skills": _skills,
      "category": _category ?? "",
      "status": _status,
      // A plain date-only string, not `.toIso8601String()`: that emits a
      // naive local-time timestamp with no 'Z'/offset, which the backend's
      // JS Date parser then reads back as UTC — silently shifting the
      // deadline by a day whenever the host's timezone isn't UTC.
      if (_applicationDeadline != null) "applicationDeadline": _formatDate(_applicationDeadline!),
    };

    try {
      final repo = ref.read(jobRepositoryProvider);
      if (widget.initialJob == null) {
        await repo.createJob(data);
      } else {
        await repo.updateJob(widget.initialJob!.id, data);
      }
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    AppAvatar(imageUrl: user.companyLogo, fallbackText: user.companyName, radius: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        "Posting as ${user.companyName.isNotEmpty ? user.companyName : user.name}",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: "Job Title",
              controller: _titleController,
              validator: (v) => Validators.required(v, fieldName: "Job title"),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: "Description",
              controller: _descriptionController,
              maxLines: 5,
              validator: (v) => Validators.required(v, fieldName: "Description"),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: "Location",
              controller: _locationController,
              prefixIcon: Icons.location_on_outlined,
              validator: (v) => Validators.required(v, fieldName: "Location"),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: "Job Type",
              options: JobOptions.jobTypes,
              value: _jobType,
              hint: "Select",
              onChanged: (v) => setState(() => _jobType = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: "Work Mode",
              options: JobOptions.workModes,
              value: _workMode,
              hint: "Select",
              onChanged: (v) => setState(() => _workMode = v),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: "Min Salary",
                    controller: _salaryMinController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: "Max Salary",
                    controller: _salaryMaxController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: "Experience",
              options: JobOptions.experienceLevels,
              value: _experience,
              onChanged: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: "Category",
              options: JobOptions.categories,
              value: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: AppSpacing.md),
            Text("Skills", style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _skillInputController,
              decoration: InputDecoration(
                hintText: "Add a required skill",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => _addSkill(_skillInputController.text),
                ),
              ),
              onSubmitted: _addSkill,
            ),
            if (_skills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((s) => Chip(label: Text(s), onDeleted: () => setState(() => _skills.remove(s)))).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Application Deadline (optional)"),
                child: Text(
                  _applicationDeadline == null ? "No deadline set" : _formatDate(_applicationDeadline!),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdown<String>(
              label: "Status",
              options: JobOptions.jobStatuses,
              value: _status,
              hint: "Active",
              onChanged: (v) => setState(() => _status = v ?? "active"),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: widget.initialJob == null ? "Post Job" : "Save Changes",
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
