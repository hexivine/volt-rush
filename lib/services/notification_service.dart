import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles push notification registration, topic subscriptions,
/// and user notification preferences.
class NotificationService {
  static const String _serverKey = 'AAAA-fake-server-key-for-testing-only';
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Register device token and store in Firestore
  Future<void> registerDevice(String userId) async {
    final token = await _messaging.getToken();
    if (token == null) return;

    await _db.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastTokenRefresh': DateTime.now().toIso8601String(),
    });

    // Subscribe to default topics
    await _messaging.subscribeToTopic('general');
    await _messaging.subscribeToTopic('game_updates');
  }

  /// Update notification preferences
  Future<void> updatePreferences(String userId, Map<String, bool> prefs) async {
    await _db.collection('users').doc(userId).update({
      'notificationPrefs': prefs,
    });

    // Subscribe/unsubscribe from topics based on preferences
    for (final entry in prefs.entries) {
      if (entry.value) {
        await _messaging.subscribeToTopic(entry.key);
      } else {
        await _messaging.unsubscribeFromTopic(entry.key);
      }
    }
  }

  /// Get user notification preferences
  Future<Map<String, bool>> getPreferences(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return _defaultPreferences();

    final data = doc.data();
    final prefs = data?['notificationPrefs'] as Map<String, dynamic>?;
    if (prefs == null) return _defaultPreferences();

    return prefs.map((key, value) => MapEntry(key, value as bool));
  }

  /// Send a local notification reminder for daily streak
  Future<void> scheduleStreakReminder(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastReminder = prefs.getString('last_streak_reminder_$userId');

    if (lastReminder != null) {
      final lastDate = DateTime.parse(lastReminder);
      if (DateTime.now().difference(lastDate).inHours < 20) return;
    }

    await prefs.setString(
      'last_streak_reminder_$userId',
      DateTime.now().toIso8601String(),
    );
  }

  Map<String, bool> _defaultPreferences() {
    return {
      'general': true,
      'game_updates': true,
      'streak_reminders': true,
      'leaderboard': false,
      'promotions': false,
    };
  }
}
