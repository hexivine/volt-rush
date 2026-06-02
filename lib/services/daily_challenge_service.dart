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
  /// BUG: No transaction — race condition if called twice simultaneously
  /// BUG: Uses DateTime.now() instead of serverTimestamp
  Future<void> completeChallenge(String userId, String challengeId, int score) async {
    final challengeRef = _firestore.collection('daily_challenges').doc(challengeId);

    // Direct update without transaction — race condition risk
    await challengeRef.update({'completed': true, 'score': score});
    // Move user points update to a separate method, e.g., updateUserPoints
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
  /// BUG: Hardcoded API key
  /// BUG: No error handling
  Future<void> generateNextChallenge(String userId) async {
    final apiKey = Platform.environment['API_KEY'] ?? '';

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final challengeData = {
          'type': ChallengeType.speedRun,
          'targetScore': ChallengeConfig.targetScore,
          'reward': ChallengeConfig.reward,
        };
      'reward': 50,
      'createdAt': DateTime.now(),
    };

    await _firestore.collection('daily_challenges').add(challengeData);
  }
}
