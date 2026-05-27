import { render, screen, fireEvent, waitFor } from '@testing-library/react';import { AchievementsScreen } from '../achievements_screen';import { AchievementService } from '../../services/achievement_service';jest.mock('../../services/achievement_service');describe('AchievementsScreen', () => {
  const mockAchievements = [
    {
      id: '1',
      name: 'Achievement 1',
      description: 'Description 1',
      claimed: false,
    },
    {
      id: '2',
      name: 'Achievement 2',
      description: 'Description 2',
      claimed: true,
    },
  ];

  beforeEach(() => {
    AchievementService.prototype.syncWithServer.mockResolvedValue(mockAchievements);
    AchievementService.prototype.unlockAchievement.mockResolvedValue(undefined);
  });

  it('renders loading state initially', () => {
    render(<AchievementsScreen />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('renders achievements after loading', async () => {
    render(<AchievementsScreen />);
    await waitFor(() => {
      expect(screen.getByText('Achievement 1')).toBeInTheDocument();
      expect(screen.getByText('Achievement 2')).toBeInTheDocument();
    });
  });

  it('calls unlockAchievement when claim button is clicked', async () => {
    render(<AchievementsScreen />);
    await waitFor(() => {
      fireEvent.click(screen.getByText('Claim'));
    });
    expect(AchievementService.prototype.unlockAchievement).toHaveBeenCalledWith('user123', '1');
  });

  it('searches achievements correctly', async () => {
    render(<AchievementsScreen />);
    const searchInput = screen.getByPlaceholderText('Search achievements');
    fireEvent.change(searchInput, { target: { value: 'Achievement 1' } });
    await waitFor(() => {
      expect(screen.getByText('Achievement 1')).toBeInTheDocument();
      expect(screen.queryByText('Achievement 2')).not.toBeInTheDocument();
    });
  });
});