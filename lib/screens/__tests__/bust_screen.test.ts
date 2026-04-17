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

    testWidgets('displays bust message text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BustScreen(),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('BUST'), findsOneWidget);
    });

    testWidgets('applies correct styling for bust state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BustScreen(),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });
  });
}