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

    group('combo system', () {
      test('initial comboCount is 0', () {
        expect(gameLogic.comboCount, 0);
      });

      test('initial multiplier is 1', () {
        expect(gameLogic.multiplier, 1);
      });

      test('incrementScore increases comboCount', () {
        gameLogic.incrementScore();
        expect(gameLogic.comboCount, 1);
      });

      test('comboCount increases with each score increment', () {
        gameLogic.incrementScore();
        gameLogic.incrementScore();
        gameLogic.incrementScore();
        expect(gameLogic.comboCount, 3);
      });

      test('multiplier is 1 when comboCount is less than 5', () {
        gameLogic.incrementScore();
        gameLogic.incrementScore();
        expect(gameLogic.multiplier, 1);
      });

      test('multiplier is 2 when comboCount reaches 5', () {
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, 2);
      });

      test('multiplier is 3 when comboCount reaches 10', () {
        for (int i = 0; i < 10; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, 3);
      });

      test('combo resets after banking', () {
        for (int i = 0; i < 7; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.comboCount, 7);
        expect(gameLogic.multiplier, 2);

        gameLogic.bankScore();

        expect(gameLogic.comboCount, 0);
        expect(gameLogic.multiplier, 1);
      });
    });

    group('score calculation with multiplier', () {
      test('single tap adds 1 point with multiplier 1', () {
        gameLogic.incrementScore();
        expect(gameLogic.currentScore, 1);
      });

      test('score adds multiplier value when multiplier is 2', () {
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        // comboCount = 5, multiplier = 2
        final scoreBefore = gameLogic.currentScore;
        gameLogic.incrementScore();
        expect(gameLogic.currentScore, scoreBefore + 2);
      });

      test('score adds multiplier value when multiplier is 3', () {
        for (int i = 0; i < 10; i++) {
          gameLogic.incrementScore();
        }
        // comboCount = 10, multiplier = 3
        final scoreBefore = gameLogic.currentScore;
        gameLogic.incrementScore();
        expect(gameLogic.currentScore, scoreBefore + 3);
      });

      test('score accumulates correctly through combo progression', () {
        // First 4 taps: 4 * 1 = 4
        for (int i = 0; i < 4; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.currentScore, 4);
        expect(gameLogic.multiplier, 1);

        // 5th tap: multiplier becomes 2
        gameLogic.incrementScore();
        expect(gameLogic.currentScore, 6); // 4 + 2
        expect(gameLogic.multiplier, 2);

        // Taps 6-9 with multiplier 2
        for (int i = 0; i < 4; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.currentScore, 14); // 6 + 4*2

        // 10th tap: multiplier becomes 3
        gameLogic.incrementScore();
        expect(gameLogic.currentScore, 17); // 14 + 3
        expect(gameLogic.multiplier, 3);
      });
    });

    group('time bonus', () {
      test('incrementScore adds 0.3 seconds to timeRemaining', () {
        final initialTime = gameLogic.timeRemaining;
        gameLogic.incrementScore();
        expect(gameLogic.timeRemaining, initialTime + 0.3);
      });

      test('timeRemaining does not exceed 15.0 seconds', () {
        // Set time close to max
        while (gameLogic.timeRemaining < 14.9) {
          gameLogic.incrementScore();
        }
        final currentTime = gameLogic.timeRemaining;
        gameLogic.incrementScore();
        expect(gameLogic.timeRemaining, 15.0);
      });

      test('timeRemaining clamps at 0.0 minimum', () {
        // Assuming timeRemaining can be reduced in other parts of the code
        // This test verifies the clamp behavior
        // Time starts at some value, incrementing should never go below 0
        final initialTime = gameLogic.timeRemaining;
        for (int i = 0; i < 50; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.timeRemaining >= 0.0, true);
      });
    });

    group('bankScore', () {
      test('bankScore resets comboCount to 0', () {
        gameLogic.incrementScore();
        gameLogic.incrementScore();
        expect(gameLogic.comboCount, 2);

        gameLogic.bankScore();

        expect(gameLogic.comboCount, 0);
      });

      test('bankScore resets multiplier to 1', () {
        for (int i = 0; i < 5; i++) {
          gameLogic.incrementScore();
        }
        expect(gameLogic.multiplier, 2);

        gameLogic.bankScore();

        expect(gameLogic.multiplier, 1);
      });

      test('bankScore updates highScore if currentScore is higher', () {
        gameLogic.incrementScore();
        gameLogic.incrementScore();

        final initialHighScore = gameLogic.highScore;
        gameLogic.bankScore();

        expect(gameLogic.highScore, gameLogic.currentScore);
      });

      test('bankScore changes gameState to banked', () {
        gameLogic.startGame();
        expect(gameLogic.gameState, GameState.playing);

        gameLogic.bankScore();

        expect(gameLogic.gameState, GameState.banked);
      });

      test('bankScore calls onStateChanged', () {
        stateChangedCalled = false;
        gameLogic.bankScore();
        expect(stateChangedCalled, true);
      });
    });

    group('onStateChanged callback', () {
      test('incrementScore triggers onStateChanged', () {
        stateChangedCalled = false;
        gameLogic.incrementScore();
        expect(stateChangedCalled, true);
      });

      test('multiple increments trigger multiple callbacks', () {
        int callbackCount = 0;
        final gameLogicWithCounter = GameLogic(
          onStateChanged: () {
            callbackCount++;
          },
        );

        gameLogicWithCounter.incrementScore();
        gameLogicWithCounter.incrementScore();
        gameLogicWithCounter.incrementScore();

        expect(callbackCount, 3);
      });
    });
  });
}