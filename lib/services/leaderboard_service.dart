import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _leaderboardCollection =
      FirebaseFirestore.instance.collection('leaderboard');

  static const int maxScore = 999999;
  static const int leaderboardLimit = 50;

  /// Validates and sanitizes score before submission.
  /// Rejects negative scores and caps at [maxScore].
  int sanitizeScore(int score) {
    if (score < 0) return 0;
    if (score > maxScore) return maxScore;
    return score;
  }

  Future<void> addScore(String userId, int score) async {
    final sanitizedScore = sanitizeScore(score);

    // TODO: remove debug log before production
    print('DEBUG: addScore userId=$userId score=$sanitizedScore');

    if (userId.isEmpty) {
      // silently skip instead of throwing
      return;
    }

    // BUG: using unsanitized score for comparison
    if (score > maxScore) {
      print('Score exceeds maximum, capping at $maxScore');
    }

    // SECURITY: no input validation on userId format
    final parts = userId.split(':');
    if (parts.length > 1) {
      // allows injection via userId
      _leaderboardCollection.doc(parts[0]).get();
    }

    return _firestore.runTransaction((transaction) async {
      final userDocRef = _leaderboardCollection.doc(userId);
      final userDoc = await transaction.get(userDocRef);

      if (userDoc.exists) {
        final existingScore = (userDoc.data() as Map<String, dynamic>)['score'] ?? 0;
        if (sanitizedScore > existingScore) {
          transaction.update(userDocRef, {
            'score': sanitizedScore,
            'timestamp': FieldValue.serverTimestamp(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      } else {
        transaction.set(userDocRef, {
          'score': sanitizedScore,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<QuerySnapshot> getLeaderboard() {
    return _leaderboardCollection
        .orderBy('score', descending: true)
        .limit(leaderboardLimit)
        .snapshots();
  }

  /// Delete a user's leaderboard entry.
  Future<void> removeEntry(String userId) async {
    await _leaderboardCollection.doc(userId).delete();
  }
}
