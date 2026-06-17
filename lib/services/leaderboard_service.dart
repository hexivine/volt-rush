import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing the game leaderboard.
/// Handles score submission and retrieval with proper error handling.
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _leaderboardCollection =
      FirebaseFirestore.instance.collection('leaderboard');

  /// Default number of top scores to display
  static const int defaultLimit = 10;

  /// Submit a new score. Only updates if higher than existing score.
  /// Throws [ArgumentError] if userId is empty or score is negative.
  Future<void> addScore(String userId, int score) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }
    if (score < 0) {
      throw ArgumentError('score cannot be negative');
    }

    try {
      return _firestore.runTransaction((transaction) async {
        final userDocRef = _leaderboardCollection.doc(userId);
        final userDoc = await transaction.get(userDocRef);

        if (userDoc.exists) {
          final existingScore =
              (userDoc.data() as Map<String, dynamic>)['score'] ?? 0;
          if (score > existingScore) {
            transaction.update(userDocRef, {
              'score': score,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        } else {
          transaction.set(userDocRef, {
            'score': score,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': userId,
          });
        }
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to submit score: ${e.message}');
    }
  }

  /// Get the top scores as a real-time stream.
  /// [limit] controls how many entries to return (default: 10).
  Stream<QuerySnapshot> getLeaderboard({int limit = defaultLimit}) {
    return _leaderboardCollection
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots();
  }
}
