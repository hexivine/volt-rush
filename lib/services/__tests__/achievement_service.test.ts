import { AchievementService } from '../achievement_service';import { FirebaseFirestore } from '@firebase/firestore-types';jest.mock('@firebase/firestore-types');describe('AchievementService', () => {
  let service: AchievementService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      set: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined),
      runTransaction: jest.fn().mockImplementation(async (callback) => {
        await callback({
          get: jest.fn().mockResolvedValue({ data: () => ({}) }),          set: jest.fn(),          update: jest.fn(),          delete: jest.fn()
        });
      })
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
        claimed: false
      });
    });

    it('updates user document with increment', async () => {
      await service.unlockAchievement('user123', 'ach123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
      expect(mockFirestore.update).toHaveBeenCalledWith({
        achievementCount: expect.any(Object),
        lastAchievementAt: expect.any(Date)
      });
    });
  });

  describe('syncWithServer', () => {
    it('deletes all achievements for the user', async () => {
      const mockSnapshot = {
        docs: [
          { reference: { delete: jest.fn().mockResolvedValue(undefined) } }
        ]
      };
      mockFirestore.collection().where().get.mockResolvedValue(mockSnapshot);

      await service.syncWithServer('user123');
      expect(mockSnapshot.docs[0].reference.delete).toHaveBeenCalled();
    });
  });

  describe('getAchievementName', () => {
    it('returns the name from the data', () => {
      const data = { name: 'Test Achievement' };
      expect(service.getAchievementName(data)).toBe('Test Achievement');
    });

    it('throws when data is null', () => {
      expect(() => service.getAchievementName(null)).toThrow();
    });
  });
});