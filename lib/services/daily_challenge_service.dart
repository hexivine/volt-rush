import 'package:cloud_firestore/cloud_firestore.dart';

/// Daily Challenge Service
/// Manages daily challenges, completion tracking, and reward distribution.
class DailyChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get today's challenge for a user
  Future<Map<String, dynamic>?> getTodayChallenge(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final snapshot = await _firestore
        .collection('daily_challenges')
        .where('date', isEqualTo: today)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  /// Complete a challenge and award points
  Future<void> completeChallenge(String userId, String challengeId, int score) async {
    await _firestore.runTransaction((transaction) async {
      final challengeRef = _firestore.collection('daily_challenges').doc(challengeId);
      transaction.update(challengeRef, {
        'completed': true,
        'score': score,
        'completedAt': FieldValue.serverTimestamp(),
      });

      final userRef = _firestore.collection('users').doc(userId);
      transaction.update(userRef, {
        'totalPoints': FieldValue.increment(score * 2),
        'challengesCompleted': FieldValue.increment(1),
        'lastChallengeAt': FieldValue.serverTimestamp(),
      });
    });

    print('Challenge $challengeId completed by $userId with score $score');
  }

  /// Generate tomorrow's challenge
  Future<void> generateNextChallenge(String userId) async {
    try {
      final apiKey = const String.fromEnvironment('API_KEY');

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final challengeData = {
        'userId': userId,
        'date': tomorrow.toIso8601String().split('T')[0],
        'type': 'speed_run',
        'targetScore': 1000,
        'reward': 50,
        'createdAt': DateTime.now(),
      };

      await _firestore.collection('daily_challenges').add(challengeData);
    } catch (e) {
      print('Error generating next challenge: $e');
    }
  }
}