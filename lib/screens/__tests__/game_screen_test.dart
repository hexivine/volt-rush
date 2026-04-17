import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/screens/game_screen.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';

class MockGameProvider extends Mock implements GameProvider {}

class MockGameLogic extends Mock implements GameLogic {}

void main() {
  group('GameScreen', () {
    late MockGameProvider mockGameProvider;

    setUp(() {
      mockGameProvider = MockGameProvider();
      
      when(mockGameProvider.currentScore).thenReturn(0);
      when(mockGameProvider.gameState).thenReturn(GameState.playing);
      when(mockGameProvider.showOnboarding).thenReturn(false);
      when(mockGameProvider.multiplier).thenReturn(1);
      when(mockGameProvider.comboCount).thenReturn(0);
      when(mockGameProvider.highScore).thenReturn(0);
      when(mockGameProvider.timeRemaining).thenReturn(10.0);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<GameProvider>.value(
          value: mockGameProvider,
          child: const GameScreen(),
        ),
      );
    }

    testWidgets('displays current score', (WidgetTester tester) async {
      when(mockGameProvider.currentScore).thenReturn(42);
      await tester.pumpWidget(createTestWidget());
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('displays multiplier when greater than 1', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(2);
      await tester.pumpWidget(createTestWidget());
      expect(find.text('x2 COMBO!'), findsOneWidget);
    });

    testWidgets('displays x3 COMBO when multiplier is 3', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(3);
      await tester.pumpWidget(createTestWidget());
      expect(find.text('x3 COMBO!'), findsOneWidget);
    });

    testWidgets('does not display combo text when multiplier is 1', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(1);
      await tester.pumpWidget(createTestWidget());
      expect(find.textContaining('COMBO'), findsNothing);
    });

    testWidgets('combo text has amber background', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(2);
      await tester.pumpWidget(createTestWidget());
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('x2 COMBO!'),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.amber.withOpacity(0.8)));
    });

    testWidgets('calls incrementScore on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      verify(mockGameProvider.incrementScore()).called(1);
    });

    testWidgets('triggers haptic feedback on tap', (WidgetTester tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(loggedCalls, contains('lightImpact'));
    });

    testWidgets('combo text uses correct styling', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(2);
      await tester.pumpWidget(createTestWidget());
      final textWidget = tester.widget<Text>(
        find.text('x2 COMBO!'),
      );
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(textWidget.style?.fontSize, equals(18));
      expect(textWidget.style?.color, equals(Colors.black));
    });

    testWidgets('displays combo badge above score', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(2);
      await tester.pumpWidget(createTestWidget());
      final column = tester.widget<Column>(
        find.byType(Column).first,
      );
      expect(column.children.length, greaterThan(1));
    });

    testWidgets('has SizedBox spacing between combo text and score', (WidgetTester tester) async {
      when(mockGameProvider.multiplier).thenReturn(2);
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}