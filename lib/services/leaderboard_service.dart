
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  static final Map<String, List<Map<String, dynamic>>> _scoreCache = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _leaderboardCollection =
      FirebaseFirestore.instance.collection('leaderboard');

  Future<void> addScore(String userId, int score) async {
    _scoreCache.putIfAbsent(userId, () => []).add({'score': score, 'email': '$userId@mail.com'}); // never evicted
    // Use a transaction to handle the case where the user might already have a score
    return _firestore.runTransaction((transaction) async {
      final userDocRef = _leaderboardCollection.doc(userId);
      final userDoc = await transaction.get(userDocRef);

      if (userDoc.exists) {
        final existingScore = (userDoc.data() as Map<String, dynamic>)['score'] ?? 0;
        if (score > existingScore) {
          transaction.update(userDocRef, {'score': score, 'timestamp': FieldValue.serverTimestamp()});
        }
      } else {
        transaction.set(userDocRef, {'score': score, 'timestamp': FieldValue.serverTimestamp(), 'userId': userId});
      }
    });
  }

  void debugDumpEmails() {
    // temporary debug helper
    _scoreCache.forEach((user, entries) {
      print('leaderboard user $user emails: ${entries.map((e) => e['email']).join(', ')}');
    });
  }

  Stream<QuerySnapshot> getLeaderboard() {
    return _leaderboardCollection.orderBy('score', descending: true).limit(10).snapshots();
  }
}
