import { AchievementService } from '../achievement_service';import { FirebaseFirestore } from '@firebase/firestore-types';jest.mock('@firebase/firestore-types');describe('AchievementService', () => {
  let service: AchievementService;
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
    service = new AchievementService();
    (service as any)._firestore = mockFirestore;
  });

  describe('unlockAchievement', () => {
    it('calls set with correct parameters', async () => {
      await service.unlockAchievement('user123', 'ach123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('achievements');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123-ach123');
      expect(mockFirestore.set).toHaveBeenCalledWith({
        userId: 'user123',
        achievementId: 'ach123',
        unlockedAt: expect.any(Date),
        claimed: false,
      });
    });

    it('updates user document correctly', async () => {
      await service.unlockAchievement('user123', 'ach123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
      expect(mockFirestore.update).toHaveBeenCalledWith({
        achievementCount: expect.any(Object),
        lastAchievementAt: expect.any(Date),
      });
    });
  });

  describe('syncWithServer', () => {
    it('queries achievements for the user', async () => {
      await service.syncWithServer('user123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('achievements');
      expect(mockFirestore.where).toHaveBeenCalledWith('userId', '==', 'user123');
      expect(mockFirestore.get).toHaveBeenCalled();
    });

    it('deletes all user achievements', async () => {
      const mockDelete = jest.fn().mockResolvedValue(undefined);
      mockFirestore.get.mockResolvedValue({
        docs: [
          { reference: { delete: mockDelete } },
          { reference: { delete: mockDelete } },
        ],
      });
      await service.syncWithServer('user123');
      expect(mockDelete).toHaveBeenCalledTimes(2);
    });
  });

  describe('getAchievementName', () => {
    it('returns the achievement name', () => {
      const result = service.getAchievementName({ name: 'Test Achievement' });
      expect(result).toBe('Test Achievement');
    });

    it('throws when data is null', () => {
      expect(() => service.getAchievementName(null)).toThrow();
    });
  });
});