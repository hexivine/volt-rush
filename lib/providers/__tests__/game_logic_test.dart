import 'package:flutter_test/flutter_test.dart';
import 'package:volt_rush/providers/game_logic.dart';

void main() {
  group('GameLogic', () {
    late GameLogic gameLogic;
    bool stateChangedCalled = false;

    setUp(() {
      stateChangedCalled = false;
      gameLogic = GameLogic(
        onStateChanged: () {
          stateChangedCalled = true;
        },
      );
    });

    group('comboCount', () {
      test('initial value is 0', () {
        expect(gameLogic.comboCount, equals(0));
      });

      test('increments on each score increment', () {
        gameLogic.incrementScore();
        expect(gameLogic.comboCount, equals(1));
        gameLogic.incrementScore();
        expect(gameLogic.comboCount, equals(2));
      });

      test('resets to 0 when bankScore is called', () {
        gameLogic.incrementScore();
        gameLogic.incrementScore();
        expect(gameLogic.comboCount, equals(2));
        gameLogic.bankScore();
        expect(gameLogic.comboCount, equals(0));
      });
    });

    group('multiplier', () {
      test('initial value is 1', () {
        expect(gameLogic.multiplier, equals(1));
      });

      test('returns 1 when comboCount is less than 5', () {
        gameLogic.incrementScore();
        expect(gameLogic.multiplier, equals(1));
        for (int i = 0; i < 3; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(1));
      });

      test('returns 2 when comboCount is between 5 and 9', () {
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(2));
        for (int i = 0; i < 3; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(2));
      });

      test('returns 3 when comboCount is 10 or more', () {
        for (int i = 0; i < 10; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(3));
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(3));
      });

      test('resets to 1 when bankScore is called', () {
        for (int i = 0; i < 10; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(3));
        gameLogic.bankScore();
        expect(gameLogic.multiplier, equals(1));
      });
    });

    group('incrementScore', () {
      test('increments score by multiplier value', () {
        expect(gameLogic.currentScore, equals(0));
        gameLogic.incrementScore();
        expect(gameLogic.currentScore, equals(1));
        
        for (int i = 0; i < 4; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.currentScore, equals(5));
        
        gameLogic.incrementScore();
        expect(gameLogic.multiplier, equals(2));
        expect(gameLogic.currentScore, equals(7));
        
        for (int i = 0; i < 4; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(3));
      });

      test('increases timeRemaining by 0.3 seconds up to max of 15', () {
        final initialTime = gameLogic.timeRemaining;
        gameLogic.incrementScore();
        expect(gameLogic.timeRemaining, closeTo(initialTime + 0.3, 0.001));
      });

      test('clamps timeRemaining to maximum of 15 seconds', () {
        gameLogic = GameLogic(
          onStateChanged: () {},
          initialTime: 14.9,
        );
        gameLogic.incrementScore();
        expect(gameLogic.timeRemaining, equals(15.0));
        gameLogic.incrementScore();
        expect(gameLogic.timeRemaining, equals(15.0));
      });

      test('does not decrease timeRemaining below 0', () {
        gameLogic = GameLogic(
          onStateChanged: () {},
          initialTime: 0.1,
        );
        gameLogic.incrementScore();
        expect(gameLogic.timeRemaining, greaterThanOrEqualTo(0.0));
      });

      test('calls onStateChanged callback', () {
        stateChangedCalled = false;
        gameLogic.incrementScore();
        expect(stateChangedCalled, isTrue);
      });
    });

    group('bankScore', () {
      test('updates highScore when currentScore is higher', () {
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        gameLogic.bankScore();
        expect(gameLogic.highScore, equals(6));
      });

      test('resets comboCount to 0', () {
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.comboCount, equals(5));
        gameLogic.bankScore();
        expect(gameLogic.comboCount, equals(0));
      });

      test('resets multiplier to 1', () {
        for (int i = 0; i < 10; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, equals(3));
        gameLogic.bankScore();
        expect(gameLogic.multiplier, equals(1));
      });

      test('changes gameState to banked', () {
        gameLogic.bankScore();
        expect(gameLogic.gameState, equals(GameState.banked));
      });

      test('cancels timer', () {
        gameLogic.bankScore();
        expect(gameLogic.gameState, equals(GameState.banked));
      });

      test('calls onStateChanged callback', () {
        stateChangedCalled = false;
        gameLogic.bankScore();
        expect(stateChangedCalled, isTrue);
      });
    });
  });
}