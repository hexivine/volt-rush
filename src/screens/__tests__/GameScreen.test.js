import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { GameScreen } from '../GameScreen';
import { GameProvider } from '../../providers/gameProvider';
import * as haptics from 'react-native-haptic-feedback';

jest.mock('react-native-haptic-feedback');
jest.mock('../../providers/gameProvider');

const mockGameProvider = require('../../providers/gameProvider').GameProvider;

describe('GameScreen', () => {
  let mockProvider;
  let loggedCalls;

  beforeEach(() => {
    loggedCalls = [];
    mockProvider = new mockGameProvider();
    
    mockProvider.currentScore = 0;
    mockProvider.gameState = 'playing';
    mockProvider.showOnboarding = false;
    mockProvider.multiplier = 1;
    mockProvider.comboCount = 0;
    mockProvider.highScore = 0;
    mockProvider.timeRemaining = 10.0;
    
    haptics.trigger.mockImplementation((type) => {
      loggedCalls.push(type);
    });
  });

  const createTestWidget = () => {
    return (
      <GameProvider.Provider value={mockProvider}>
        <GameScreen />
      </GameProvider.Provider>
    );
  }