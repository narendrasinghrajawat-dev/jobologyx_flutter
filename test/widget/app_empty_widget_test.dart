import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/widgets/app_empty_widget.dart';

void main() {
  testWidgets('AppEmptyWidget shows its message and only renders an action when both label and callback are given', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppEmptyWidget(message: 'No jobs match these filters.'))),
    );

    expect(find.text('No jobs match these filters.'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);

    var actionTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyWidget(
            message: 'No jobs match these filters.',
            actionLabel: 'Clear filters',
            onAction: () => actionTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Clear filters'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    expect(actionTapped, isTrue);
  });
}
