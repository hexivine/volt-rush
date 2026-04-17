import { GameProvider } from '../gameProvider';
import { GameLogic, GameState } from '../gameLogic';

jest.mock('../gameLogic');
jest.mock('../authProvider');

const MockGameLogic = require('../gameLogic').GameLogic;
const MockAuthProvider = require('../authProvider').AuthProvider;

describe('GameProvider', () => {
  let gameProvider;
  let mockGameLogic;

  beforeEach(() => {
    mockGameLogic = new MockGameLogic();
    gameProvider = new GameProvider({
      gameLogic: mockGameLogic,
      authProvider: null,
    });
  });

  describe('comboCount', () => {
    it('delegates to gameLogic.comboCount', () => {
      mockGameLogic.comboCount = 5;
      expect(gameProvider.comboCount).toBe(5);
      expect(mockGameLogic.comboCount).toBe(5);
    });

    it('returns 0 when no combos have been made', () => {
      mockGameLogic.comboCount = 0;
      expect(gameProvider.comboCount).toBe(0);
    });

    it('returns correct count after multiple increments', () => {
      mockGameLogic.comboCount = 10;
      expect(gameProvider.comboCount).toBe(10);
    });
  });

  describe('multiplier', () => {
    it('delegates to gameLogic.multiplier', () => {
      mockGameLogic.multiplier = 2;
      expect(gameProvider.multiplier).toBe(2);
      expect(mockGameLogic.multiplier).toBe(2);
    });

    it('returns 1 when no combo is active', () => {
      mockGameLogic.multiplier = 1;
      expect(gameProvider.multiplier).toBe(1);
    });

    it('returns 2 during medium combo', () => {
      mockGameLogic.multiplier = 2;
      expect(gameProvider.multiplier).toBe(2);
    });

    it('returns 3 during high combo', () => {
      mockGameLogic.multiplier = 3;
      expect(gameProvider.multiplier).toBe(3);
    });
  });
});