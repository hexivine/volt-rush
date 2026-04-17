import 'package:flutter_test/flutter_test.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:volt_rush/providers/auth_provider.dart';

void main() {
  group('GameProvider', () {
    late GameProvider gameProvider;

    setUp(() {
      gameProvider = GameProvider();
    });

    group('comboCount', () {
      test('exposes comboCount from GameLogic', () {
        expect(gameProvider.comboCount, 0);
      });

      test('comboCount reflects GameLogic state after incrementScore', () {
        gameProvider.incrementScore();
        expect(gameProvider.comboCount, 1);
      });

      test('comboCount increases with multiple increments', () {
        gameProvider.incrementScore();
        gameProvider.incrementScore();
        gameProvider.incrementScore();
        expect(gameProvider.comboCount, 3);
      });

      test('comboCount resets after banking', () {
        gameProvider.incrementScore();
        gameProvider.incrementScore();
        expect(gameProvider.comboCount, 2);

        gameProvider.bankScore();
        expect(gameProvider.comboCount, 0);
      });
    });

    group('multiplier', () {
      test('exposes multiplier from GameLogic', () {
        expect(gameProvider.multiplier, 1);
      });

      test('multiplier is 1 initially', () {
        expect(gameProvider.multiplier, 1);
      });

      test('multiplier increases to 2 at combo 5', () {
        for (int i = 0; i < 5; i++) {
          gameProvider.incrementScore();
        }
        expect(gameProvider.multiplier, 2);
      });

      test('multiplier increases to 3 at combo 10', () {
        for (int i = 0; i < 10; i++) {
          gameProvider.incrementScore();
        }
        expect(gameProvider.multiplier, 3);
      });

      test('multiplier resets to 1 after banking', () {
        for (int i = 0; i < 7; i++) {
          gameProvider.incrementScore();
        }
        expect(gameProvider.multiplier, 2);

        gameProvider.bankScore();
        expect(gameProvider.multiplier, 1);
      });
    });

    group('game actions', () {
      test('startGame is available', () {
        expect(gameProvider.startGame, isA<Function>());
      });

      test('incrementScore is available', () {
        expect(gameProvider.incrementScore, isA<Function>());
      });

      test('bankScore is available', () {
        expect(gameProvider.bankScore, isA<Function>());
      });

      test('game actions can be called without error', () {
        expect(() => gameProvider.startGame(), returnsNormally);
        expect(() => gameProvider.incrementScore(), returnsNormally);
        expect(() => gameProvider.bankScore(), returnsNormally);
      });
    });

    group('existing properties remain accessible', () {
      test('gameState is accessible', () {
        expect(gameProvider.gameState, isA<GameState>());
      });

      test('currentScore is accessible', () {
        expect(gameProvider.currentScore, isA<int>());
      });

      test('highScore is accessible', () {
        expect(gameProvider.highScore, isA<int>());
      });

      test('timeRemaining is accessible', () {
        expect(gameProvider.timeRemaining, isA<double>());
      });

      test('showOnboarding is accessible', () {
        expect(gameProvider.showOnboarding, isA<bool>());
      });
    });
  });
}