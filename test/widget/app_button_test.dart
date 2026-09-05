import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton shows its label and calls onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AppButton(label: 'Submit', onPressed: () => tapped = true)),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('AppButton shows a spinner instead of its label and ignores taps while loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AppButton(label: 'Submit', onPressed: () => tapped = true, isLoading: true)),
      ),
    );

    expect(find.text('Submit'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapped, isFalse);
  });
}
