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
    jest.clearAllMocks();
    mockGameLogic = new MockGameLogic();
    gameProvider = new GameProvider({
      gameLogic: mockGameLogic,
      authProvider: null,
    });
  });

  describe('constructor', () => {
    it('initializes with provided gameLogic instance', () => {
      expect(gameProvider.gameLogic).toBe(mockGameLogic);
    });

    it('initializes with provided authProvider instance', () => {
      const mockAuthProvider = new MockAuthProvider();
      const provider = new GameProvider({
        gameLogic: mockGameLogic,
        authProvider: mockAuthProvider,
      });
      expect(provider.authProvider).toBe(mockAuthProvider);
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

    it('returns correct count at boundary values', () => {
      mockGameLogic.comboCount = 4;
      expect(gameProvider.comboCount).toBe(4);
      mockGameLogic.comboCount = 5;
      expect(gameProvider.comboCount).toBe(5);
      mockGameLogic.comboCount = 9;
      expect(gameProvider.comboCount).toBe(9);
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

  describe('currentScore', () => {
    it('delegates to gameLogic.currentScore', () => {
      mockGameLogic.currentScore = 100;
      expect(gameProvider.currentScore).toBe(100);
    });

    it('returns 0 initially', () => {
      mockGameLogic.currentScore = 0;
      expect(gameProvider.currentScore).toBe(0);
    });
  });

  describe('highScore', () => {
    it('delegates to gameLogic.highScore', () => {
      mockGameLogic.highScore = 500;
      expect(gameProvider.highScore).toBe(500);
    });
  });

  describe('gameState', () => {
    it('delegates to gameLogic.gameState', () => {
      mockGameLogic.gameState = GameState.Playing;
      expect(gameProvider.gameState).toBe(GameState.Playing);
    }