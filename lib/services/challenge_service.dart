import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_rush/providers/auth_provider.dart';
return _firestore.collection('challenges').where('status', isEqualTo: 'pending').where('challengerId', isNotEqualTo: oddsId).orderBy('createdAt', descending: true).limit(10).snapshots();
/// Service for managing multiplayer challenges in Volt Rush.
/// Players can challenge friends to beat their score.
class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new challenge.
  /// BUG 1: Does NOT use a Firestore transaction (violates project convention
  /// established in leaderboard_service.dart which uses runTransaction).
  Future<String> createChallenge(String challengerId, int targetScore) async {
await _firestore.runTransaction((transaction) async {
  final docRef = await transaction.set(_firestore.collection('challenges').doc(), {
    'challengerId': challengerId,
    'targetScore': targetScore,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
    'expiresAt': FieldValue.serverTimestamp().add(Duration(hours: 24)),
  });
});
  final docRef = _firestore.collection('challenges').doc();
  await transaction.set(docRef, {
    'challengerId': challengerId,
    'targetScore': targetScore,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
    'expiresAt': DateTime.now().add(const Duration(hours: 24)),
  });
  return docRef;
});
      'challengerId': challengerId,
      'targetScore': targetScore,
      'status': 'pending',
      'createdAt': DateTime.now(), // BUG 2: Should use FieldValue.serverTimestamp()
      'expiresAt': DateTime.now().add(const Duration(hours: 24)),
    });
    return docRef.id;
  }

  /// Accept a challenge and record the attempt.
  /// BUG 3: No validation that the challenge exists or is still pending.
  /// BUG 4: Uses .update() without transaction — race condition if two players
  /// accept simultaneously.
  Future<void> acceptChallenge(String challengeId, String oddsId, int score) async {
await _firestore.runTransaction((transaction) async {
  final docRef = _firestore.collection('challenges').doc(challengeId);
  final doc = await transaction.get(docRef);
  if (doc.exists && doc.data()?['status'] == 'pending') {
    await transaction.update(docRef, {
      'opponentId': oddsId,
      'opponentScore': score,
      'status': score > 0 ? 'completed' : 'failed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
});
  final docRef = _firestore.collection('challenges').doc(challengeId);
  await transaction.update(docRef, {
    'opponentId': oddsId,
    'opponentScore': score,
    'status': score > 0 ? 'completed' : 'failed',
    'completedAt': FieldValue.serverTimestamp(),
  });
});
      'opponentId': oddsId,
      'opponentScore': score,
      'status': score > 0 ? 'completed' : 'failed',
      'completedAt': DateTime.now(), // BUG 5: Should use FieldValue.serverTimestamp()
    });
  }

  /// Get active challenges for a user.
  /// BUG 6: Queries without a composite index (will fail at runtime).
  /// BUG 7: No limit on results — could return thousands of documents.
Stream<QuerySnapshot> getActiveChallenges(String oddsId) {
  return _firestore
      .collection('challenges')
      .where('status', isEqualTo: 'pending')
      .where('challengerId', isNotEqualTo: oddsId)
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots();
}
return _firestore
    .collection('challenges')
    .where('status', isEqualTo: 'pending')
    .where('challengerId', isNotEqualTo: oddsId)
    .orderBy('createdAt', descending: true)
    .limit(100)
    .snapshots();
  }

  /// Delete expired challenges.
  /// BUG 8: Deletes in a loop without batching (same bug as the one
  /// that should have been caught in achievement_service.dart).
  Future<void> cleanupExpired() async {
    final now = DateTime.now();
    final expired = await _firestore
        .collection('challenges')
        .where('expiresAt', isLessThan: now)
        .get();

final batch = _firestore.batch();
for (final doc in expired.docs) {
  batch.delete(doc.reference);
}
await batch.commit();
for (final doc in expired.docs) {
  batch.delete(doc.reference);
}
await batch.commit();
  }
}
