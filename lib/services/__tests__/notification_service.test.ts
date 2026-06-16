import { NotificationService } from '../notification_service';import { FirebaseFirestore } from '@firebase/firestore-types';import { FirebaseMessaging } from '@firebase/messaging-types';jest.mock('@firebase/firestore-types');jest.mock('@firebase/messaging-types');describe('NotificationService', () => {
  let notificationService: NotificationService;
  let mockFirestore: jest.Mocked<FirebaseFirestore>;
  let mockMessaging: jest.Mocked<FirebaseMessaging>;

  beforeEach(() => {
    mockFirestore = {
      collection: jest.fn().mockReturnThis(),
      doc: jest.fn().mockReturnThis(),
      runTransaction: jest.fn().mockImplementation(async (callback) => {
        const transaction = {
          update: jest.fn().mockResolvedValue(undefined),
        };
        await callback(transaction);
      }),
      where: jest.fn().mockReturnThis(),
      orderBy: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue({ docs: [] }),
    } as unknown as jest.Mocked<FirebaseFirestore>;

    mockMessaging = {
      getToken: jest.fn().mockResolvedValue('mock-token'),
    } as unknown as jest.Mocked<FirebaseMessaging>;

    notificationService = new NotificationService({
      firestore: mockFirestore,
      messaging: mockMessaging,
    });
  });

  describe('registerToken', () => {
    it('registers FCM token for user', async () => {
      const result = await notificationService.registerToken('user123');
      expect(result).toBe(true);

      expect(mockMessaging.getToken).toHaveBeenCalled();
      expect(mockFirestore.runTransaction).toHaveBeenCalled();
      expect(mockFirestore.collection).toHaveBeenCalledWith('users');
      expect(mockFirestore.doc).toHaveBeenCalledWith('user123');
    });

    it('returns false when token is null', async () => {
      mockMessaging.getToken.mockResolvedValue(null);
      const result = await notificationService.registerToken('user123');
      expect(result).toBe(false);
    });
  });

  describe('getRecentNotifications', () => {
    it('returns recent notifications for user', async () => {
      const mockNotifications = [
        { id: '1', message: 'Notification 1' },
        { id: '2', message: 'Notification 2' }
      ];
      mockFirestore.get.mockResolvedValue({ docs: mockNotifications.map(n => ({ data: () => n })) });

      const notifications = await notificationService.getRecentNotifications('user123');
      expect(notifications).toEqual(mockNotifications);

      expect(mockFirestore.collection).toHaveBeenCalledWith('notifications');
      expect(mockFirestore.where).toHaveBeenCalledWith('userId', '==', 'user123');
      expect(mockFirestore.orderBy).toHaveBeenCalledWith('createdAt', 'desc');
      expect(mockFirestore.limit).toHaveBeenCalledWith(20);
      expect(mockFirestore.get).toHaveBeenCalled();
    });

    it('returns empty array when error occurs', async () => {
      mockFirestore.get.mockRejectedValue(new Error('Failed to fetch notifications'));
      const notifications = await notificationService.getRecentNotifications('user123');
      expect(notifications).toEqual([]);
    });
  });
});