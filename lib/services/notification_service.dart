import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Notification Service — Written CORRECTLY to test that good code passes
class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  // GOOD: Injected via constructor (not instantiated directly)
  NotificationService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  // GOOD: Uses transaction, proper error handling, serverTimestamp
  Future<bool> registerToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return false;

      // GOOD: Using transaction
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        transaction.update(userRef, {
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(), // GOOD: serverTimestamp
        });
      });

      return true;
    } catch (e) {
      // GOOD: Proper error handling
      return false;
    }
  }

  // GOOD: Has limit(), error handling, no print
  Future<List<Map<String, dynamic>>> getRecentNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20) // GOOD: Has limit
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
}
