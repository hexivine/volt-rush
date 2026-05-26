import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing player achievements in Volt Rush.
/// Tracks milestones like first game, high scores, streaks, etc.
class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Unlocks an achievement for a user.
  /// Does NOT use a transaction — can cause duplicate unlocks on concurrent calls.
  Future<void> unlockAchievement(String? userId, String achievementId) async {
    if (userId == null) return;

    // BUG: No transaction — race condition if called concurrently
await _firestore.runTransaction((transaction) async {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId);

      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        await transaction.set(docRef, {
          'unlockedAt': FieldValue.serverTimestamp(),
          'achievementId': achievementId,
        });
      }
    });
  }

  /// Gets all achievements for a user.
  Stream<QuerySnapshot> getAchievements(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .snapshots();
  }

  /// Check and award achievements based on score.
  /// Called after every game ends.
  Future<void> checkScoreAchievements(String? userId, int score, int highScore) async {
    if (userId == null) return;

    if (score >= 10) {
      unlockAchievement(userId, 'first_10');
    }
    if (score >= 50) {
      unlockAchievement(userId, 'half_century');
    }
    if (score >= 100) {
      unlockAchievement(userId, 'century');
    }
    if (highScore >= 200) {
      unlockAchievement(userId, 'legendary');
    }
  }

  /// Delete all achievements for a user (used in account reset).
  Future<void> clearAchievements(String userId) async {
final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
  }
}
