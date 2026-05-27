import { NotificationService } from '../notification_service';import { FirebaseFirestore } from '@firebase/firestore-types';import { FirebaseMessaging } from '@firebase/messaging-types';jest.mock('@firebase/firestore-types');jest.mock('@firebase/messaging-types');describe('NotificationService', () => {
  let service: NotificationService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;
  let mockMessaging: jest.Mocked<FirebaseMessaging>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      runTransaction: jest.fn().mockImplementation(async (callback) => {
        await callback({
          get: jest.fn().mockResolvedValue({ data: jest.fn().mockReturnValue({}) }),
          update: jest.fn().mockResolvedValue(undefined),
        });
      }),
      where: jest.fn().mockReturnThis(),
      orderBy: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({ docs: [] }),
    } as unknown as jest.Mocked<FirebaseFirestore>;

    mockMessaging = {
      getToken: jest.fn().mockResolvedValue('test-token'),
    } as unknown as jest.Mocked<FirebaseMessaging>;

    service = new NotificationService({
      firestore: mockFirestore,
      messaging: mockMessaging,
    });
  });

  describe('registerToken', () => {
    it('registers token successfully', async () => {
      const result = await service.registerToken('user123');
      expect(result).toBe(true);
      expect(mockMessaging.getToken).toHaveBeenCalled();
      expect(mockFirestore.runTransaction).toHaveBeenCalled();
    });

    it('returns false when token is null', async () => {
      mockMessaging.getToken.mockResolvedValue(null);
      const result = await service.registerToken('user123');
      expect(result).toBe(false);
    });

    it('returns false when transaction fails', async () => {
      mockFirestore.runTransaction.mockRejectedValue(new Error('Transaction failed'));
      const result = await service.registerToken('user123');
      expect(result).toBe(false);
    });
  });

  describe('getRecentNotifications', () => {
    it('returns recent notifications', async () => {
      const mockNotifications = [
        { id: '1', message: 'Notification 1' },
        { id: '2', message: 'Notification 2' },
      ];
      mockFirestore.get.mockResolvedValue({
        docs: mockNotifications.map((n) => ({ data: () => n })),
      });
      const result = await service.getRecentNotifications('user123');
      expect(result).toEqual(mockNotifications);
      expect(mockFirestore.where).toHaveBeenCalledWith('userId', '==', 'user123');
      expect(mockFirestore.orderBy).toHaveBeenCalledWith('createdAt', 'desc');
      expect(mockFirestore.limit).toHaveBeenCalledWith(20);
    });

    it('returns empty array when query fails', async () => {
      mockFirestore.get.mockRejectedValue(new Error('Query failed'));
      const result = await service.getRecentNotifications('user123');
      expect(result).toEqual([]);
    });
  });
});