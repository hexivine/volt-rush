import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';import { AchievementsScreen } from '../achievements_screen';import { AchievementService } from '../../services/achievement_service';jest.mock('../../services/achievement_service');describe('AchievementsScreen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders loading indicator when achievements are being loaded', () => {
    render(<AchievementsScreen />);
    expect(screen.getByTestId('loading-indicator')).toBeTruthy();
  });

  it('displays achievements after loading', async () => {
    const mockAchievements = [
      { id: '1', name: 'Achievement 1', description: 'Description 1', claimed: false },
      { id: '2', name: 'Achievement 2', description: 'Description 2', claimed: true }
    ];
    AchievementService.prototype.syncWithServer.mockResolvedValue(mockAchievements);

    render(<AchievementsScreen />);
    await waitFor(() => {
      expect(screen.getByText('Achievement 1')).toBeTruthy();
      expect(screen.getByText('Achievement 2')).toBeTruthy();
    });
  });

  it('calls claimAchievement when claim button is pressed', async () => {
    const mockAchievements = [
      { id: '1', name: 'Achievement 1', description: 'Description 1', claimed: false }
    ];
    AchievementService.prototype.syncWithServer.mockResolvedValue(mockAchievements);
    AchievementService.prototype.unlockAchievement.mockResolvedValue(undefined);

    render(<AchievementsScreen />);
    await waitFor(() => {
      fireEvent.press(screen.getByText('Claim'));
    });

    expect(AchievementService.prototype.unlockAchievement).toHaveBeenCalledWith('user123', '1');
  });

  it('searches achievements when query is provided', async () => {
    const mockAchievements = [
      { id: '1', name: 'Achievement 1', description: 'Description 1', claimed: false },
      { id: '2', name: 'Achievement 2', description: 'Description 2', claimed: true }
    ];
    AchievementService.prototype.syncWithServer.mockResolvedValue(mockAchievements);

    render(<AchievementsScreen />);
    await waitFor(() => {
      fireEvent.changeText(screen.getByTestId('search-input'), 'Achievement 1');
    });

    expect(screen.getByText('Achievement 1')).toBeTruthy();
    expect(screen.queryByText('Achievement 2')).toBeNull();
  });
});