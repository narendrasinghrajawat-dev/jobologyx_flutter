import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobologyx_flutter/core/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge title-cases known statuses and falls back gracefully for unknown ones', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(children: [StatusBadge('shortlisted'), StatusBadge('some_unmapped_status')]),
        ),
      ),
    );

    expect(find.text('Shortlisted'), findsOneWidget);
    expect(find.text('Some Unmapped Status'), findsOneWidget);
  });
}
