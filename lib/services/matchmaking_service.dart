import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Real-time matchmaking service for multiplayer game modes.
/// Pairs players based on skill rating using an ELO-like system.
class MatchmakingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  static const int _matchTimeoutSeconds = 30;
  static const int _ratingTolerance = 200;
  static const int _maxQueueSize = 100;

  StreamSubscription? _queueSubscription;
  Timer? _timeoutTimer;

  /// Join the matchmaking queue
  Future<String> joinQueue(String userId, int rating) async {
    // Add player to queue
    final queueRef = await _db.collection('matchmaking_queue').add({
      'userId': userId,
      'rating': rating,
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'waiting',
    });

    // Start timeout timer
    _timeoutTimer = Timer(Duration(seconds: _matchTimeoutSeconds), () {
      _onTimeout(queueRef.id, userId);
    });

    // Try to find a match immediately
    await _attemptMatch(queueRef.id, userId, rating);

    return queueRef.id;
  }

  /// Leave the matchmaking queue
  Future<void> leaveQueue(String queueId) async {
    _timeoutTimer?.cancel();
    _queueSubscription?.cancel();

    await _db.collection('matchmaking_queue').doc(queueId).delete();
  }

  /// Listen for match found
  Stream<DocumentSnapshot> listenForMatch(String queueId) {
    return _db.collection('matchmaking_queue').doc(queueId).snapshots();
  }

  /// Calculate new ratings after a match
  Map<String, int> calculateNewRatings(int winnerRating, int loserRating) {
    const kFactor = 32;
    final expectedWinner = 1 / (1 + pow(10, (loserRating - winnerRating) / 400));
    final expectedLoser = 1 / (1 + pow(10, (winnerRating - loserRating) / 400));

    final newWinnerRating = (winnerRating + kFactor * (1 - expectedWinner)).round();
    final newLoserRating = (loserRating + kFactor * (0 - expectedLoser)).round();

    return {
      'winner': newWinnerRating,
      'loser': newLoserRating,
    };
  }

  /// Record match result and update ratings
  Future<void> recordMatchResult(String matchId, String winnerId, String loserId) async {
    final winnerDoc = await _db.collection('users').doc(winnerId).get();
    final loserDoc = await _db.collection('users').doc(loserId).get();

    final winnerRating = (winnerDoc.data()?['rating'] ?? 1000) as int;
    final loserRating = (loserDoc.data()?['rating'] ?? 1000) as int;

    final newRatings = calculateNewRatings(winnerRating, loserRating);

    // Update both players' ratings
    await _db.collection('users').doc(winnerId).update({
      'rating': newRatings['winner'],
      'wins': FieldValue.increment(1),
    });

    await _db.collection('users').doc(loserId).update({
      'rating': newRatings['loser'],
      'losses': FieldValue.increment(1),
    });

    // Record match history
    await _db.collection('matches').doc(matchId).update({
      'status': 'completed',
      'winnerId': winnerId,
      'completedAt': FieldValue.serverTimestamp(),
      'ratingChanges': newRatings,
    });
  }

  Future<void> _attemptMatch(String queueId, String userId, int rating) async {
    // Find players in queue within rating tolerance
    final candidates = await _db
        .collection('matchmaking_queue')
        .where('status', isEqualTo: 'waiting')
        .where('rating', isGreaterThan: rating - _ratingTolerance)
        .where('rating', isLessThan: rating + _ratingTolerance)
        .limit(10)
        .get();

    for (final candidate in candidates.docs) {
      if (candidate.id == queueId) continue;
      final candidateData = candidate.data();
      final candidateUserId = candidateData['userId'] as String;

      // Create match
      final matchRef = await _db.collection('matches').add({
        'players': [userId, candidateUserId],
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update both queue entries
      await _db.collection('matchmaking_queue').doc(queueId).update({
        'status': 'matched',
        'matchId': matchRef.id,
      });
      await _db.collection('matchmaking_queue').doc(candidate.id).update({
        'status': 'matched',
        'matchId': matchRef.id,
      });

      _timeoutTimer?.cancel();
      return;
    }
  }

  void _onTimeout(String queueId, String userId) {
    _db.collection('matchmaking_queue').doc(queueId).update({
      'status': 'timeout',
    });
  }
}

double pow(num base, num exponent) => base.toDouble() * exponent.toDouble();
