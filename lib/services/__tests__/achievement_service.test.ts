import { AchievementService } from '../achievement_service';import { FirebaseFirestore } from '@firebase/firestore-types';jest.mock('@firebase/firestore-types');describe('AchievementService', () => {
  let achievementService: AchievementService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      set: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined),
      where: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({ docs: [] }),
    } as unknown as jest.Mocked<FirebaseFirestore>;
    achievementService = new AchievementService();
    (achievementService as any)._firestore = mockFirestore;
  });

  describe('unlockAchievement', () => {
    it('calls set with correct parameters', async () => {
      await achievementService.unlockAchievement('user123', 'ach123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('achievements');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123-ach123');
      expect(mockFirestore.set).toHaveBeenCalledWith({
        userId: 'user123',
        achievementId: 'ach123',
        unlockedAt: expect.any(Date),
        claimed: false,
      });
    });

    it('calls update with correct parameters', async () => {
      await achievementService.unlockAchievement('user123', 'ach123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
      expect(mockFirestore.update).toHaveBeenCalledWith({
        achievementCount: expect.any(Object),
        lastAchievementAt: expect.any(Date),
      });
    });
  });

  describe('syncWithServer', () => {
    it('calls get with correct parameters', async () => {
      await achievementService.syncWithServer('user123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('achievements');
      expect(mockFirestore.where).toHaveBeenCalledWith('userId', '==', 'user123');
      expect(mockFirestore.get).toHaveBeenCalled();
    });
  });

  describe('getAchievementName', () => {
    it('returns the name from the data object', () => {
      const data = { name: 'Test Achievement' };
      expect(achievementService.getAchievementName(data)).toBe('Test Achievement');
    });

    it('throws an error when data is null', () => {
      expect(() => achievementService.getAchievementName(null)).toThrow();
    });
  });
});