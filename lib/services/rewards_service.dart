import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
Use batch operations to delete documents in bulk.
  final docRef = _firestore.collection('rewards').doc(userId);
  final doc = await transaction.get(docRef);
  // Rest of the claim logic inside transaction
});
/// Daily rewards service for Volt Rush.
/// Players earn bonus multipliers for consecutive daily logins.
class RewardsService {
Create a separate DataStorage class to handle Firestore interactions.

  /// Claim daily reward. Returns the multiplier earned (1x-5x).
  /// BUG: Uses DateTime.now() instead of FieldValue.serverTimestamp()
  /// BUG: No transaction — concurrent claims could double-reward
  Future<int> claimDailyReward(String userId) async {
    final userDoc = await _firestore.collection('rewards').doc(userId).get();

    int streak = 1;
    if (userDoc.exists) {
      final data = userDoc.data()!;
final lastClaim = (data['lastClaimAt'] as Timestamp).toDate();
final hoursSince = DateTime.now().difference(lastClaim).inHours;

      if (hoursSince < 24) {
        return 0; // Already claimed today
      } else if (hoursSince < 48) {
        streak = (data['streak'] as int) + 1; // Continue streak
      }
      // If > 48 hours, streak resets to 1
    }

    final multiplier = streak.clamp(1, 5);

await _firestore.runTransaction((transaction) async {
      transaction.set(_firestore.collection('rewards').doc(userId), {
        'streak': streak,
        'multiplier': multiplier,
        'lastClaimAt': FieldValue.serverTimestamp(),
        'totalClaimed': FieldValue.increment(1),
      });
    });

    // Also store locally for offline access
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('dailyStreak', streak);
    prefs.setInt('dailyMultiplier', multiplier);

    return multiplier;
  }

  /// Get current streak info without claiming.
  Future<Map<String, dynamic>> getStreakInfo(String userId) async {
    final doc = await _firestore.collection('rewards').doc(userId).get();
    if (!doc.exists) {
      return {'streak': 0, 'multiplier': 1, 'canClaim': true};
    }

    final data = doc.data()!;
    final lastClaim = (data['lastClaimAt'] as Timestamp).toDate();
    final hoursSince = DateTime.now().difference(lastClaim).inHours;

    return {
      'streak': data['streak'] ?? 0,
      'multiplier': data['multiplier'] ?? 1,
      'canClaim': hoursSince >= 24,
      'hoursUntilClaim': hoursSince < 24 ? 24 - hoursSince : 0,
    };
  }

  /// Apply multiplier to a game score.
  /// BUG: Reads from SharedPreferences (stale data) instead of Firestore
  Future<int> applyMultiplier(int baseScore) async {
final doc = await _firestore.collection('rewards').doc(userId).get();
final multiplier = doc.data()?['multiplier'] ?? 1;
    return baseScore * multiplier;
  }

  /// Reset all rewards (admin function).
  /// BUG: Deletes without batching — fails for >500 docs
  Future<void> resetAllRewards() async {
    final snapshot = await _firestore.collection('rewards').get();
final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
