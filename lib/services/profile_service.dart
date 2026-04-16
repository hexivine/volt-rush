import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Future<Map<String, dynamic>?> getProfile() async {
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    return doc.data();
  }

  Future<void> updateProfile({String? displayName, String? avatar}) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (avatar != null) updates['avatar'] = avatar;
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(currentUserId).update(updates);
  }

  Future<int> getUserRank(String userId) async {
    final snapshot = await _firestore
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .get();

    int rank = 1;
    for (var doc in snapshot.docs) {
      if (doc.id == userId) return rank;
      rank++;
    }
    return -1;
  }

  Future<Map<String, int>> getWinStats(String userId) async {
    final doc = await _firestore.collection('stats').doc(userId).get();
    if (!doc.exists) return {'played': 0, 'banked': 0, 'busted': 0};

    final data = doc.data()!;
    int played = data['played'] ?? 0;
    int banked = data['banked'] ?? 0;
    int busted = data['busted'] ?? 0;

    return {'played': played, 'banked': banked, 'busted': busted};
  }

  Future<void> recordGameResult(bool banked) async {
    final userId = currentUserId;
    final ref = _firestore.collection('stats').doc(userId);

    final update = <String, dynamic>{
      'played': FieldValue.increment(1),
      banked ? 'banked' : 'busted': FieldValue.increment(1),
      'lastPlayed': FieldValue.serverTimestamp(),
    };

    await ref.set(update, SetOptions(merge: true));
  }
}
