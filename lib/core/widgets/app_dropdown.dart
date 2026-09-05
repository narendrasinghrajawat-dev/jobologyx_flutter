import 'package:flutter/material.dart';

/// A single labeled option for [AppDropdown].
class AppDropdownOption<T> {
  const AppDropdownOption(this.value, this.label);

  final T value;
  final String label;
}

/// Standard labeled dropdown for filter forms. `value == null` shows [hint]
/// as an "Any" placeholder — used throughout the job filter sheet.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint = "Any",
  });

  final String label;
  final List<AppDropdownOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      hint: Text(hint),
      isExpanded: true,
      items: [
        DropdownMenuItem<T>(value: null, child: Text(hint)),
        ...options.map((o) => DropdownMenuItem<T>(value: o.value, child: Text(o.label))),
      ],
      onChanged: onChanged,
    );
  }
}
