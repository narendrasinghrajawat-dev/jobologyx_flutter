import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../models/job_filter.dart';
import '../../models/job_options.dart';

/// Filter + sort form shown in a bottom sheet from the job listing's filter
/// button. Only calls back on Apply/Clear — the listing screen owns state.
class JobFilterSheet extends StatefulWidget {
  const JobFilterSheet({super.key, required this.initialFilter, required this.onApply, required this.onClear});

  final JobFilter initialFilter;
  final ValueChanged<JobFilter> onApply;
  final VoidCallback onClear;

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  late final TextEditingController _locationController = TextEditingController(text: widget.initialFilter.location);
  late final TextEditingController _salaryMinController =
      TextEditingController(text: widget.initialFilter.salaryMin?.toString() ?? "");
  late final TextEditingController _salaryMaxController =
      TextEditingController(text: widget.initialFilter.salaryMax?.toString() ?? "");
  late String? _jobType = widget.initialFilter.jobType;
  late String? _workMode = widget.initialFilter.workMode;
  late String? _category = widget.initialFilter.category;
  late String? _experience = widget.initialFilter.experience;
  late String _sort = widget.initialFilter.sort;

  @override
  void dispose() {
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(
      widget.initialFilter.copyWith(
        location: _locationController.text.trim(),
        jobType: _jobType,
        clearJobType: _jobType == null,
        workMode: _workMode,
        clearWorkMode: _workMode == null,
        category: _category,
        clearCategory: _category == null,
        experience: _experience,
        clearExperience: _experience == null,
        salaryMin: num.tryParse(_salaryMinController.text.trim()),
        clearSalaryMin: _salaryMinController.text.trim().isEmpty,
        salaryMax: num.tryParse(_salaryMaxController.text.trim()),
        clearSalaryMax: _salaryMaxController.text.trim().isEmpty,
        sort: _sort,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Filter Jobs", style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: "Location", controller: _locationController, prefixIcon: Icons.location_on_outlined),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: "Job Type",
            options: JobOptions.jobTypes,
            value: _jobType,
            onChanged: (v) => setState(() => _jobType = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: "Work Mode",
            options: JobOptions.workModes,
            value: _workMode,
            onChanged: (v) => setState(() => _workMode = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: "Category",
            options: JobOptions.categories,
            value: _category,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            label: "Experience",
            options: JobOptions.experienceLevels,
            value: _experience,
            onChanged: (v) => setState(() => _experience = v),
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
            label: "Sort By",
            options: JobOptions.sortOptions,
            value: _sort,
            hint: "Newest First",
            onChanged: (v) => setState(() => _sort = v ?? "latest"),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "Clear",
                  outlined: true,
                  onPressed: () {
                    widget.onClear();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: AppButton(label: "Apply", onPressed: _apply)),
            ],
          ),
        ],
      ),
    );
  }
}
