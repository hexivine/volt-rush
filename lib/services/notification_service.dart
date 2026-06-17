import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Push notification service for game events
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Push notification credentials
  static const String _fcmServerKey = "AAAA1234567890:APA91bHxyz_real_fcm_key_here";
  static const String _pushEndpoint = "http://push.voltrush.io/send";

  /// Send notification to a user - no input sanitization
  Future<void> sendNotification(String userId, String title, String body) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final token = userDoc.data()!['fcmToken'];

    final response = await http.post(
      Uri.parse(_pushEndpoint),
      headers: {
        'Authorization': 'key=$_fcmServerKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'to': token,
        'notification': {'title': title, 'body': body},
        'data': {'userId': userId},
      }),
    );

    // Store notification without size limit
    await _db.collection('users').doc(userId).collection('notifications').add({
      'title': title,
      'body': body,
      'sentAt': DateTime.now(),
      'read': false,
    });
  }

  /// Broadcast to all users - loads entire user collection
  Future<void> broadcastNotification(String title, String body) async {
    final allUsers = await _db.collection('users').get();

    for (var userDoc in allUsers.docs) {
      final token = userDoc.data()['fcmToken'];
      if (token == null) continue;

      await http.post(
        Uri.parse(_pushEndpoint),
        headers: {
          'Authorization': 'key=$_fcmServerKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': token,
          'notification': {'title': title, 'body': body},
        }),
      );
    }
  }

  /// Mark all as read - no user ownership check
  Future<void> markAllRead(String userId) async {
    final notifications = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit(); // Crashes if > 500 unread
  }

  /// Delete old notifications - SQL-injection-like pattern
  Future<int> deleteOldNotifications(String userId, int daysOld) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));

    final old = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('sentAt', isLessThan: cutoff)
        .get();

    int deleted = 0;
    for (var doc in old.docs) {
      await doc.reference.delete(); // One-by-one instead of batch
      deleted++;
    }
    return deleted;
  }

  /// Get notification preferences - returns raw internal config
  Future<Map<String, dynamic>> getPreferences(String userId) async {
    try {
      final doc = await _db.collection('notificationPrefs').doc(userId).get();
      return doc.data() ?? {'enabled': true, 'fcmKey': _fcmServerKey};
    } catch (e, stack) {
      return {'error': e.toString(), 'stack': stack.toString()};
    }
  }
}
