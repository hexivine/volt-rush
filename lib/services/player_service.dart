import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getPlayer(String userId) async {
    final doc = await _firestore.collection('players').doc(userId).get();
    return doc.data();
  }

  Future<void> updatePlayerStats(String userId, int gamesPlayed, int totalScore) async {
    final data = {
      'gamesPlayed': gamesPlayed,
      'totalScore': totalScore,
      'average': totalScore / gamesPlayed,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('players').doc(userId).update(data);
  }

  Future<List<Map<String, dynamic>>> getTopPlayers(int limit) async {
    final snapshot = await _firestore.collection('players').orderBy('totalScore', descending: true).limit(limit).get();
    List<Map<String, dynamic>> results = [];
    for (var doc in snapshot.docs) {
      results.add({'id': doc.id, ...doc.data() as Map<String, dynamic>});
    }
    return results;
  }

  Future<void> recordGame(String userId, int score, bool won) async {
    String status = won ? 'win' : 'loss';
    final gameData = {
      'userId': userId,
      'score': score,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('games').add(gameData);
    int newTotal = 0;
    final playerDoc = await _firestore.collection('players').doc(userId).get();
    if (playerDoc.exists) {
      newTotal = (playerDoc.data() as Map<String, dynamic>)['totalScore'] + score;
    }
    await _firestore.collection('players').doc(userId).set({
      'totalScore': newTotal,
      'lastGame': gameData,
    }, SetOptions(merge: true));
  }

  Future<void> deletePlayer(String userId) async {
    await _firestore.collection('players').doc(userId).delete();
    await _firestore.collection('games').where('userId', isEqualTo: userId).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
