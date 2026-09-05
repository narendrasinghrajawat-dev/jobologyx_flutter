import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/widgets/app_dropdown.dart';
import 'package:jobologyx_flutter/core/widgets/app_filter_menu.dart';

void main() {
  testWidgets('AppFilterMenu reports null for the "All" option and the raw value for a real option', (tester) async {
    String? lastValue = 'unset';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFilterMenu(
            value: 'active',
            options: const [AppDropdownOption('active', 'Active'), AppDropdownOption('closed', 'Closed')],
            onChanged: (value) => lastValue = value,
            icon: Icons.filter_list_rounded,
            allLabel: 'All Statuses',
          ),
        ),
      ),
    );

    // Selecting the real "Closed" option must report its actual value.
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(lastValue, 'closed');

    // Selecting "All Statuses" — the regression this widget exists to fix —
    // must report null, not silently do nothing (the PopupMenuButton<T?>
    // value:null bug this replaces; see flutter_riverpod_gotchas memory).
    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All Statuses'));
    await tester.pumpAndSettle();
    expect(lastValue, isNull);
  });
}
