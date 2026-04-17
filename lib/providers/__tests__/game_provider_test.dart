import 'package:flutter_test/flutter_test.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:mockito/mockito.dart';

class MockGameLogic extends Mock implements GameLogic {}

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  group('GameProvider', () {
    late GameProvider gameProvider;
    late MockGameLogic mockGameLogic;

    setUp(() {
      mockGameLogic = MockGameLogic();
      gameProvider = GameProvider(
        gameLogic: mockGameLogic,
        authProvider: null,
      );
    });

    group('comboCount', () {
      test('delegates to gameLogic.comboCount', () {
        when(mockGameLogic.comboCount).thenReturn(5);
        expect(gameProvider.comboCount, equals(5));
        verify(mockGameLogic.comboCount).called(1);
      });

      test('returns 0 when no combos have been made', () {
        when(mockGameLogic.comboCount).thenReturn(0);
        expect(gameProvider.comboCount, equals(0));
      });

      test('returns correct count after multiple increments', () {
        when(mockGameLogic.comboCount).thenReturn(10);
        expect(gameProvider.comboCount, equals(10));
      });
    });

    group('multiplier', () {
      test('delegates to gameLogic.multiplier', () {
        when(mockGameLogic.multiplier).thenReturn(2);
        expect(gameProvider.multiplier, equals(2));
        verify(mockGameLogic.multiplier).called(1);
      });

      test('returns 1 when no combo is active', () {
        when(mockGameLogic.multiplier).thenReturn(1);
        expect(gameProvider.multiplier, equals(1));
      });

      test('returns 2 during medium combo', () {
        when(mockGameLogic.multiplier).thenReturn(2);
        expect(gameProvider.multiplier, equals(2));
      });

      test('returns 3 during high combo', () {
        when(mockGameLogic.multiplier).thenReturn(3);
        expect(gameProvider.multiplier, equals(3));
      });
    });
  });
}