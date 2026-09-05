import 'package:flutter/material.dart';

import 'app_dropdown.dart';

/// A `PopupMenuButton`-based filter with a working "clear" option.
///
/// `PopupMenuButton` can never fire `onSelected` for a `null`-valued item —
/// Flutter's own implementation treats a `null` result from the underlying
/// `showMenu()` call as "dismissed without choosing" (it calls `onCanceled`
/// instead), which is indistinguishable from actually tapping an item whose
/// `value` is `null`. A `PopupMenuItem<T?>(value: null, ...)` is therefore
/// permanently unreachable. This wraps the button with a non-null sentinel
/// internally so callers can still work in terms of a nullable filter value.
class AppFilterMenu extends StatelessWidget {
  const AppFilterMenu({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.icon,
    this.allLabel = "All",
    this.tooltip,
  });

  /// The current filter value, or null for "no filter" / "All".
  final String? value;
  final List<AppDropdownOption<String>> options;
  final ValueChanged<String?> onChanged;
  final IconData icon;
  final String allLabel;
  final String? tooltip;

  static const String _kAll = "__all__";

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value ?? _kAll,
      tooltip: tooltip,
      icon: Icon(icon),
      onSelected: (selected) => onChanged(selected == _kAll ? null : selected),
      itemBuilder: (context) => [
        PopupMenuItem(value: _kAll, child: Text(allLabel)),
        ...options.map((o) => PopupMenuItem(value: o.value, child: Text(o.label))),
      ],
    );
  }
}
