import 'package:flutter_test/flutter_test.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:volt_rush/providers/auth_provider.dart';

class MockGameLogic extends GameLogic {
  MockGameLogic({required super.onStateChanged});
}

class MockAuthProvider {
  dynamic user;
}

void main() {
  group('GameProvider', () {
    late GameProvider gameProvider;
    late MockGameLogic mockGameLogic;

    setUp(() {
      mockGameLogic = MockGameLogic(
        onStateChanged: () {},
      );
      gameProvider = GameProvider(
        gameLogic: mockGameLogic,
      );
    });

    group('comboCount', () {
      test('delegates to gameLogic.comboCount', () {
        expect(gameProvider.comboCount, mockGameLogic.comboCount);
      });

      test('returns 0 initially', () {
        expect(gameProvider.comboCount, 0);
      });

      test('reflects combo count after score increments', () {
        mockGameLogic.incrementScore();
        mockGameLogic.incrementScore();
        expect(gameProvider.comboCount, 2);
      });

      test('resets to 0 after banking score', () {
        mockGameLogic.incrementScore();
        mockGameLogic.incrementScore();
        expect(gameProvider.comboCount, 2);

        mockGameLogic.bankScore();
        expect(gameProvider.comboCount, 0);
      });
    });

    group('multiplier', () {
      test('delegates to gameLogic.multiplier', () {
        expect(gameProvider.multiplier, mockGameLogic.multiplier);
      });

      test('returns 1 initially', () {
        expect(gameProvider.multiplier, 1);
      });

      test('becomes 2 after combo reaches 5', () {
        for (int i = 0; i < 5; i++) {
          mockGameLogic.incrementScore();
        }
        expect(gameProvider.multiplier, 2);
      });

      test('becomes 3 after combo reaches 10', () {
        for (int i = 0; i < 10; i++) {
          mockGameLogic.incrementScore();
        }
        expect(gameProvider.multiplier, 3);
      });

      test('resets to 1 after banking score', () {
        for (int i = 0; i < 10; i++) {
          mockGameLogic.incrementScore();
        }
        expect(gameProvider.multiplier, 3);

        mockGameLogic.bankScore();
        expect(gameProvider.multiplier, 1);
      });
    });

    group('existing getters still work', () {
      test('currentScore getter works', () {
        mockGameLogic.incrementScore();
        expect(gameProvider.currentScore, 1);
      });

      test('gameState getter works', () {
        expect(gameProvider.gameState, GameState.home);
        mockGameLogic.startGame();
        expect(gameProvider.gameState, GameState.playing);
      });

      test('showOnboarding getter works', () {
        expect(gameProvider.showOnboarding, true);
      });
    });
  });
}