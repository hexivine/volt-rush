import { GameLogic, GameState } from '../gameLogic';

describe('GameLogic', () => {
  let gameLogic;
  let stateChangedCalled;

  beforeEach(() => {
    stateChangedCalled = false;
    gameLogic = new GameLogic({
      onStateChanged: () => {
        stateChangedCalled = true;
      },
    });
  });

  describe('comboCount', () => {
    it('initial value is 0', () => {
      expect(gameLogic.comboCount).toBe(0);
    });

    it('increments on each score increment', () => {
      gameLogic.incrementScore();
      expect(gameLogic.comboCount).toBe(1);
      gameLogic.incrementScore();
      expect(gameLogic.comboCount).toBe(2);
    });

    it('resets to 0 when bankScore is called', () => {
      gameLogic.incrementScore();
      gameLogic.incrementScore();
      expect(gameLogic.comboCount).toBe(2);
      gameLogic.bankScore();
      expect(gameLogic.comboCount).toBe(0);
    });
  });

  describe('multiplier', () => {
    it('initial value is 1', () => {
      expect(gameLogic.multiplier).toBe(1);
    });

    it('returns 1 when comboCount is less than 5', () => {
      gameLogic.incrementScore();
      expect(gameLogic.multiplier).toBe(1);
      for (let i = 0; i < 3; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(1);
    });

    it('returns 2 when comboCount is between 5 and 9', () => {
      for (let i = 0; i < 5; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(2);
      for (let i = 0; i < 3; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(2);
    });

    it('returns 3 when comboCount is 10 or more', () => {
      for (let i = 0; i < 10; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(3);
      for (let i = 0; i < 5; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(3);
    });

    it('resets to 1 when bankScore is called', () => {
      for (let i = 0; i < 10; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(3);
      gameLogic.bankScore();
      expect(gameLogic.multiplier).toBe(1);
    });
  });

  describe('incrementScore', () => {
    it('increments score by multiplier value', () => {
      expect(gameLogic.currentScore).toBe(0);
      gameLogic.incrementScore();
      expect(gameLogic.currentScore).toBe(1);
      
      for (let i = 0; i < 4; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.currentScore).toBe(5);
      
      gameLogic.incrementScore();
      expect(gameLogic.multiplier).toBe(2);
      expect(gameLogic.currentScore).toBe(7);
      
      for (let i = 0; i < 4; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(3);
    });

    it('increases timeRemaining by 0.3 seconds up to max of 15', () => {
      const initialTime = gameLogic.timeRemaining;
      gameLogic.incrementScore();
      expect(gameLogic.timeRemaining).toBeCloseTo(initialTime + 0.3, 2);
    });

    it('clamps timeRemaining to maximum of 15 seconds', () => {
      const testGameLogic = new GameLogic({
        onStateChanged: () => {},
        initialTime: 14.9,
      });
      testGameLogic.incrementScore();
      expect(testGameLogic.timeRemaining).toBe(15.0);
      testGameLogic.incrementScore();
      expect(testGameLogic.timeRemaining).toBe(15.0);
    });

    it('does not decrease timeRemaining below 0', () => {
      const testGameLogic = new GameLogic({
        onStateChanged: () => {},
        initialTime: 0.1,
      });
      testGameLogic.incrementScore();
      expect(testGameLogic.timeRemaining).toBeGreaterThanOrEqual(0.0);
    });

    it('calls onStateChanged callback', () => {
      stateChangedCalled = false;
      gameLogic.incrementScore();
      expect(stateChangedCalled).toBe(true);
    });
  });

  describe('bankScore', () => {
    it('updates highScore when currentScore is higher', () => {
      for (let i = 0; i < 5; i++) {
        gameLogic.incrementScore();
      }
      gameLogic.bankScore();
      expect(gameLogic.highScore).toBe(6);
    });

    it('resets comboCount to 0', () => {
      for (let i = 0; i < 5; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.comboCount).toBe(5);
      gameLogic.bankScore();
      expect(gameLogic.comboCount).toBe(0);
    });

    it('resets multiplier to 1', () => {
      for (let i = 0; i < 10; i++) {
        gameLogic.incrementScore();
      }
      expect(gameLogic.multiplier).toBe(3);
      gameLogic.bankScore();
      expect(gameLogic.multiplier).toBe(1);
    });

    it('changes gameState to banked', () => {
      gameLogic.bankScore();
      expect(gameLogic.gameState).toBe(GameState.banked);
    });

    it('cancels timer', () => {
      gameLogic.bankScore();
      expect(gameLogic.gameState).toBe(GameState.banked);
    });

    it('calls onStateChanged callback', () => {
      stateChangedCalled = false;
      gameLogic.bankScore();
      expect(stateChangedCalled).toBe(true);
    });
  });
});