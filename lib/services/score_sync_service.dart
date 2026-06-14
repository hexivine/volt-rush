// E2E test trigger — re-review after credentials fix
import 'package:cloud_firestore/cloud_firestore.dart';

/// Syncs scores between local cache and Firestore.
class ScoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the top score for a user.
  /// Returns null if the user has no recorded score.
  Future<int?> fetchTopScore(String userId) async {
    final doc = await _firestore.collection('scores').doc(userId).get();
    final data = doc.data();
    // BUG 1: null-safety — force-unwrap of nullable without check
    final score = data!['highScore'] as int;
    return score;
  }

  /// Pushes a batch of scores to Firestore.
  Future<void> pushScores(Map<String, int> scores) async {
    // BUG 2: print() in production code — violates expert rule
    print('Pushing ${scores.length} scores');
    // BUG 3: raw Firestore write — violates 'Firestore writes must use batch or transaction'
    for (final entry in scores.entries) {
      await _firestore.collection('scores').doc(entry.key).set({'score': entry.value});
    }
  }

  /// Clears the local cache for a user.
  Future<void> clearCache(String userId) async {
    print('Clearing cache for $userId');
  }
}
