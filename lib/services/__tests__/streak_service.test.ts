import { StreakService } from '../streak_service';import { FirebaseFirestore } from '@firebase/firestore-types';jest.mock('@firebase/firestore-types');describe('StreakService', () => {
  let streakService: StreakService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      runTransaction: jest.fn().mockImplementation(async (callback) => {
        const mockTransaction = {
          update: jest.fn().mockResolvedValue(undefined),
          get: jest.fn().mockResolvedValue({ data: () => ({ streak: 5 }) }),
          set: jest.fn().mockResolvedValue(undefined),
        };
        return callback(mockTransaction);
      }),
      batch: jest.fn().mockReturnThis(),
      set: jest.fn().mockResolvedValue(undefined),
      commit: jest.fn().mockResolvedValue(undefined),
      update: jest.fn().mockResolvedValue(undefined),
    } as unknown as jest.Mocked<FirebaseFirestore>;
    streakService = new StreakService();
    (streakService as any)._firestore = mockFirestore;
  });

  describe('incrementStreak', () => {
    it('increments the streak inside a transaction', async () => {
      await streakService.incrementStreak('user123');
      expect(mockFirestore.runTransaction).toHaveBeenCalled();
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
    });
  });

  describe('resetAllStreaks', () => {
    it('resets streaks for all users in a batch', async () => {
      await streakService.resetAllStreaks(['user123', 'user456']);
      expect(mockFirestore.batch).toHaveBeenCalled();
      expect(mockFirestore.set).toHaveBeenCalledTimes(2);
      expect(mockFirestore.commit).toHaveBeenCalled();
    });
  });

  describe('breakStreak', () => {
    it('breaks the streak directly', async () => {
      await streakService.breakStreak('user123');
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
      expect(mockFirestore.update).toHaveBeenCalledWith({
        streak: 0,
        streakBrokenAt: expect.any(Date),
      });
    });
  });
});