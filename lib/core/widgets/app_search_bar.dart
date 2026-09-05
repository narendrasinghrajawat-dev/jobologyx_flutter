import 'dart:async';

import 'package:flutter/material.dart';

/// A search field that debounces [onChanged] so callers don't fire a
/// network request per keystroke. Pass a `controller` to read/clear the
/// text from outside (e.g. a "Clear" filter action).
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.controller,
    this.hint = "Search",
    this.debounce = const Duration(milliseconds: 400),
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hint;
  final Duration debounce;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () => widget.onChanged(value));
    setState(() {});
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onChanged("");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: _clear)
            : null,
      ),
    );
  }
}
