import { StreakService } from '../streak_service';import { FirebaseFirestore } from '@firebase/firestore-types';jest.mock('@firebase/firestore-types');describe('StreakService', () => {
  let service: StreakService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      runTransaction: jest.fn().mockImplementation(async (callback) => {
        await callback({
          get: jest.fn().mockResolvedValue({ data: () => ({ streak: 5 }) }),          set: jest.fn(),          update: jest.fn(),          delete: jest.fn()
        });
      }),
      batch: jest.fn().mockReturnThis(),
      set: jest.fn().mockReturnThis(),
      commit: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined)
    } as unknown as jest.Mocked<FirebaseFirestore>;
    service = new StreakService();
    (service as any)._firestore = mockFirestore;
  });

  describe('incrementStreak', () => {
    it('increments the streak inside a transaction', async () => {
      await service.incrementStreak('user123');
      expect(mockFirestore.runTransaction).toHaveBeenCalled();
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
    });
  });

  describe('resetAllStreaks', () => {
    it('resets streaks for all users in a batch', async () => {
      await service.resetAllStreaks(['user1', 'user2']);
      expect(mockFirestore.batch).toHaveBeenCalled();
      expect(mockFirestore.set).toHaveBeenCalledTimes(2);
      expect(mockFirestore.commit).toHaveBeenCalled();
    });
  });

  describe('breakStreak', () => {
    it('breaks the streak with direct update', async () => {
      await service.breakStreak('user123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
      expect(mockFirestore.update).toHaveBeenCalledWith({
        streak: 0,
        streakBrokenAt: expect.any(Date)
      });
    });
  });
});