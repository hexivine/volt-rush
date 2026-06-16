import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification service — violates expert_rules intentionally.
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Violates: "Never use print() — use AppLogger"
  void sendNotification(String userId, String message) {
    print('Sending notification to $userId: $message');
    // Violates: "Firestore writes must use batch or transaction"
    _db.collection('notifications').doc().set({
      'userId': userId,
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Violates: "All public methods must have documentation comments"
  void markAsRead(String notifId) {
    _db.collection('notifications').doc(notifId).update({'read': true});
  }
}
