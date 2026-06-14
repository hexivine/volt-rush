// E2E test trigger — re-review after secrets binding fix
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_logger/app_logger.dart';

/// Syncs scores between local cache and Firestore.
class ScoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the top score for a user.
  /// Returns null if the user has no recorded score.
  Future<int?> fetchTopScore(String userId) async {
    final doc = await _firestore.collection('scores').doc(userId).get();
    final data = doc.data();
    if (data == null || !data.containsKey('highScore')) {
      return null;
    }
    final score = data['highScore'];
    if (score is! int) {
      return null;
    }
    return score;
  }

  /// Pushes a batch of scores to Firestore.
  Future<void> pushScores(Map<String, int> scores) async {
    final batch = _firestore.batch();
    for (final entry in scores.entries) {
      final docRef = _firestore.collection('scores').doc(entry.key);
      batch.set(docRef, {'score': entry.value}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Clears the local cache for a user.
  Future<void> clearCache(String userId) async {
    AppLogger.debug('Clearing cache for user: $userId');
    // TODO: Implement actual local cache clearing logic
  }
}