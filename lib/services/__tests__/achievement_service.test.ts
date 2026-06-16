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
    it('unlocks achievement and updates user data', async () => {
      await achievementService.unlockAchievement('user123', 'achievement123');

      expect(mockFirestore.collection).toHaveBeenCalledWith('achievements');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123-achievement123');
      expect(mockFirestore.set).toHaveBeenCalledWith({
        userId: 'user123',
        achievementId: 'achievement123',
        unlockedAt: expect.any(Date),
        claimed: false,
      });

      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
      expect(mockFirestore.update).toHaveBeenCalledWith({
        achievementCount: expect.any(Object),
        lastAchievementAt: expect.any(Date),
      });
    });
  });

  describe('syncWithServer', () => {
    it('syncs achievements with server and deletes old achievements', async () => {
      const mockDocs = [
        { reference: { delete: jest.fn().mockResolvedValue(undefined) } },
        { reference: { delete: jest.fn().mockResolvedValue(undefined) } }
      ];
      mockFirestore.get.mockResolvedValue({ docs: mockDocs });

      await achievementService.syncWithServer('user123');

      expect(mockFirestore.collection).toHaveBeenCalledWith('achievements');
      expect(mockFirestore.where).toHaveBeenCalledWith('userId', '==', 'user123');
      expect(mockFirestore.get).toHaveBeenCalled();

      mockDocs.forEach(doc => {
        expect(doc.reference.delete).toHaveBeenCalled();
      });
    });
  });

  describe('getAchievementName', () => {
    it('returns achievement name from data', () => {
      const data = { name: 'Achievement 1' };
      const name = achievementService.getAchievementName(data);
      expect(name).toBe('Achievement 1');
    });

    it('throws error when data is null', () => {
      expect(() => achievementService.getAchievementName(null)).toThrow();
    });
  });
});