import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Consistent modal bottom sheet chrome (rounded top corners, drag handle,
/// scroll-safe padding) for filter sheets, the apply flow, etc.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(BuildContext context, {required WidgetBuilder builder}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          // Bounds the sheet to 90% of the screen so tall content (e.g. the
          // job filter form) scrolls internally instead of overflowing —
          // without this, a `Column(mainAxisSize: min)` wrapping a
          // `SingleChildScrollView` hands it an unbounded height and it
          // renders at full intrinsic size rather than scrolling.
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Flexible(child: Builder(builder: builder)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
