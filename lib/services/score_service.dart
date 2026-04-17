import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordHighScore(String userId, int score, String gameMode) async {
    final docRef = _firestore.collection('high_scores').doc('${userId}_${gameMode}');
    final existing = await docRef.get();

    int previousBest = 0;
    if (existing.exists) {
      previousBest = (existing.data() as Map<String, dynamic>)['score'] ?? 0;
    }

    if (score > previousBest) {
      await docRef.set({
        'userId': userId,
        'gameMode': gameMode,
        'score': score,
        'previousBest': previousBest,
        'improvement': score - previousBest,
        'achievedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String gameMode, {int limit = 10}) async {
    final snapshot = await _firestore
        .collection('high_scores')
        .where('gameMode', isEqualTo: gameMode)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> resetAllScores() async {
    final snapshot = await _firestore.collection('high_scores').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<double> getPlayerWinRate(String userId) async {
    final gamesSnapshot = await _firestore
        .collection('games')
        .where('userId', isEqualTo: userId)
        .get();

    if (gamesSnapshot.docs.isEmpty) return 0.0;

    int wins = 0;
    for (var doc in gamesSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'win') wins++;
    }

    return wins / gamesSnapshot.docs.length;
  }

  Stream<List<Map<String, dynamic>>> watchTopPlayers({int limit = 5}) {
    return _firestore
        .collection('high_scores')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
// trigger re-review
