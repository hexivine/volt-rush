import { StreakService } from '../streak_service';import { FirebaseFirestore } from '@firebase/firestore-types';jest.mock('@firebase/firestore-types');describe('StreakService', () => {
  let streakService: StreakService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      runTransaction: jest.fn().mockImplementation(async (callback) => {
        const transaction = {
          get: jest.fn().mockResolvedValue({ data: () => ({ streak: 5 }) }),
          update: jest.fn().mockResolvedValue(undefined),
        };
        await callback(transaction);
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
    it('increments streak for user', async () => {
      await streakService.incrementStreak('user123');

      expect(mockFirestore.runTransaction).toHaveBeenCalled();
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
    });
  });

  describe('resetAllStreaks', () => {
    it('resets streaks for all users', async () => {
      const userIds = ['user1', 'user2', 'user3'];
      await streakService.resetAllStreaks(userIds);

      expect(mockFirestore.batch).toHaveBeenCalled();
      userIds.forEach(uid => {
        expect(mockFirestore.collection).toHaveBeenCalledWith('users');
        expect(mockFirestore.doc).toHaveBeenCalledWith(uid);
      });
      expect(mockFirestore.set).toHaveBeenCalledTimes(userIds.length);
      expect(mockFirestore.commit).toHaveBeenCalled();
    });
  });

  describe('breakStreak', () => {
    it('breaks streak for user', async () => {
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