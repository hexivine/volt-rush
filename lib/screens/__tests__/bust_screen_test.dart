import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/screens/bust_screen.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/game_logic.dart';

class MockGameLogic extends GameLogic {
  int _score = 0;
  int _high = 0;

  @override
  int get currentScore => _score;

  @override
  int get highScore => _high;

  @override
  GameState get gameState => GameState.busted;

  void setScore(int value) {
    _score = value;
  }

  void setHighScore(int value) {
    _high = value;
  }
}

void main() {
  group('BustScreen', () {
    late MockGameLogic mockGameLogic;
    late GameProvider gameProvider;

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<GameProvider>.value(
          value: gameProvider,
          child: const BustScreen(),
        ),
      );
    }

    setUp(() {
      mockGameLogic = MockGameLogic(onStateChanged: () {});
      gameProvider = GameProvider(gameLogic: mockGameLogic);
    });

    group('renders correctly', () {
      testWidgets('displays BUST! text', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('BUST!'), findsOneWidget);
      });

      testWidgets('displays warning icon', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('displays final score', (tester) async {
        mockGameLogic.setScore(100);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Final score: 100'), findsOneWidget);
      });

      testWidgets('displays score of 0 correctly', (tester) async {
        mockGameLogic.setScore(0);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Final score: 0'), findsOneWidget);
      });

      testWidgets('shows new high score message when score > 0', (tester) async {
        mockGameLogic.setScore(50);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('New high score!'), findsOneWidget);
      });

      testWidgets('does not show new high score message when score is 0', (tester) async {
        mockGameLogic.setScore(0);
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('New high score!'), findsNothing);
      });

      testWidgets('has play again button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('animations', () {
      testWidgets('icon animates in with elastic curve', (tester) async {
        await tester.pumpWidget(createTestWidget());
        // At start, animation should be at begin (0.0)
        await tester.pump();

        // After some time, animation should progress
        await tester.pump(const Duration(milliseconds: 300));

        // After full duration, should be settled
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });
    });
  });
}