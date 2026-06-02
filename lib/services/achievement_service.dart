import 'package:cloud_firestore/cloud_firestore.dart';
final batch = _firestore.batch(); for (final doc in snapshot.docs) { batch.delete(doc.reference); } await batch.commit();
  'unlockedAt': FieldValue.serverTimestamp(),
  'achievementId': achievementId,
}, SetOptions(merge: true));
  /// Does NOT use a transaction — can cause duplicate unlocks on concurrent calls.
Future<void> unlockAchievement(String? userId, String achievementId) async {
  if (userId == null) return;

  try {
    await _firestore.runTransaction((transaction) async {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId);
      final doc = await transaction.get(docRef);

      if (!doc.exists) {
        transaction.set(docRef, {
          'unlockedAt': FieldValue.serverTimestamp(),
          'achievementId': achievementId,
        });
      }
    });
  } catch (e) {
    AppLogger.error('Failed to unlock achievement: $e');
    rethrow;
  }
}
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

    // BUG: Deleting in a loop without batching — will fail for >500 docs
final batch = _firestore.batch();
for (final doc in snapshot.docs) {
  batch.delete(doc.reference);
}
await batch.commit();
}
await batch.commit();
  }
}
