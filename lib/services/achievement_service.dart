import 'package:cloud_firestore/cloud_firestore.dart';

/// Achievement Service — DELIBERATELY has violations for testing CodePeel rules
class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SHOULD TRIGGER: firestore-use-transactions (direct .set without transaction)
  // SHOULD TRIGGER: no-datetime-now-in-firestore (DateTime.now())
  Future<void> unlockAchievement(String userId, String achievementId) async {
    final docRef = _firestore.collection('achievements').doc('$userId-$achievementId');

    // BAD: Direct set without transaction
await _firestore.runTransaction((transaction) async { transaction.set(docRef, {
      'userId': userId,
      'achievementId': achievementId,
      'unlockedAt': FieldValue.serverTimestamp(),
      'claimed': false,
    });

    // BAD: Direct update without transaction
await _firestore.collection('users').doc(userId).update({
      'achievementCount': FieldValue.increment(1),
      'lastAchievementAt': FieldValue.serverTimestamp(),
    });

    print('Achievement unlocked: $achievementId'); // SHOULD TRIGGER: no-print-statements
  }

  // SHOULD TRIGGER: no-hardcoded-urls
  Future<void> syncWithServer(String userId) async {
    final url = 'https://api.voltrush.com/achievements/sync'; // BAD: hardcoded URL
    print('Syncing achievements for $userId to $url'); // BAD: print statement

    // BUG: No error handling on async operation (expert_rules should catch this)
    final snapshot = await _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .get(); // BUG: No limit() — unbounded read (expert_rules should catch)

    for (final doc in snapshot.docs) {
      // BAD: Direct delete without transaction
      await doc.reference.delete();
    }
  }

  // SECURITY: Hardcoded API key (should trigger custom_patterns)
const String _apiKey = EnvironmentConfig.apiKey;

  // SHOULD TRIGGER: no-force-unwrap
  String getAchievementName(Map<String, dynamic>? data) {
    return data!['name'] as String; // BAD: Force unwrap on nullable
  }
}
