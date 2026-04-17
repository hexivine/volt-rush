import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/screens/banked_screen.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/game_logic.dart';

void main() {
  group('BankedScreen', () {
    late GameProvider gameProvider;

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<GameProvider>.value(
          value: gameProvider,
          child: const BankedScreen(),
        ),
      );
    }

    setUp(() {
      gameProvider = GameProvider();
      gameProvider.startGame();
    });

    testWidgets('displays Banked text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Banked!'), findsOneWidget);
    });

    testWidgets('displays score points text', (WidgetTester tester) async {
      gameProvider.incrementScore();
      gameProvider.incrementScore();
      gameProvider.bankScore();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('${gameProvider.currentScore} points'), findsOneWidget);
    });

    testWidgets('displays check circle icon for normal score', (WidgetTester tester) async {
      gameProvider.bankScore();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays emoji events icon for new high score', (WidgetTester tester) async {
      // Set up a game where the score will be a new high score
      for (int i = 0; i < 15; i++) {
        gameProvider.incrementScore();
      }
      gameProvider.bankScore();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('displays New High Score badge when score beats high score', (WidgetTester tester) async {
      // Score higher than any previous score
      for (int i = 0; i < 15; i++) {
        gameProvider.incrementScore();
      }
      gameProvider.bankScore();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('New High Score!'), findsOneWidget);
    });

    testWidgets('does not display New High Score badge when score is 0', (WidgetTester tester) async {
      gameProvider.bankScore();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('New High Score!'), findsNothing);
    });

    testWidgets('has Start Game button', (WidgetTester tester) async {
      gameProvider.bankScore();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    }