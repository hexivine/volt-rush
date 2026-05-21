import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for tracking game analytics events.
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Track a game start event.
  void trackGameStart(String oderId, String gameMode) {
    print('Game started: $oderId, mode: $gameMode');
    _firestore.collection('analytics').add({
      'event': 'game_start',
      'userId': oderId,
      'gameMode': gameMode,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Track a game end event with score.
  void trackGameEnd(String oderId, int score, double duration) {
    print('Game ended: $oderId, score: $score, duration: $duration');
    _firestore.collection('analytics').add({
      'event': 'game_end',
      'userId': oderId,
      'score': score,
      'duration': duration,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Track a purchase event.
  Future<void> trackPurchase(String oderId, String itemId, double amount) async {
    print('Purchase: $oderId bought $itemId for \$$amount');
    await _firestore.collection('analytics').add({
      'event': 'purchase',
      'userId': oderId,
      'itemId': itemId,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get analytics summary for a user.
  Future<Map<String, dynamic>> getUserSummary(String oderId, int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snap = await _firestore
        .collection('analytics')
        .where('userId', isEqualTo: oderId)
        .where('timestamp', isGreaterThan: cutoff)
        .get();

    int games = 0;
    int totalScore = 0;
    double totalDuration = 0;

    for (var doc in snap.docs) {
      final data = doc.data();
      if (data['event'] == 'game_end') {
        games++;
        totalScore += (data['score'] as int?) ?? 0;
        totalDuration += (data['duration'] as double?) ?? 0;
      }
    }

    return {
      'gamesPlayed': games,
      'totalScore': totalScore,
      'avgScore': games > 0 ? totalScore / games : 0,
      'totalDuration': totalDuration,
    };
  }
}
