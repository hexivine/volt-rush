import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bust_app/screens/bust_screen.dart';

void main() {
  group('BustScreen', () {
    testWidgets('displays warning icon when bust occurs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BustScreen(),
        ),
      );

      // Simulate bust condition
      await tester.pump(const Duration(seconds: 1));

      // Verify warning icon is displayed
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}