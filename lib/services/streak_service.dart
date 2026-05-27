import 'package:cloud_firestore/cloud_firestore.dart';

/// Streak Service — Tests context-aware rule suppression
/// 
/// This file has TWO patterns:
/// 1. .update() INSIDE a transaction → should NOT be flagged
/// 2. .update() OUTSIDE a transaction → SHOULD be flagged
class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GOOD: .update() inside runTransaction — should NOT trigger firestore-use-transactions
  Future<void> incrementStreak(String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final doc = await transaction.get(userRef);
        final currentStreak = doc.data()?['streak'] ?? 0;

        // This .update() is inside a transaction — should be SUPPRESSED
        transaction.update(userRef, {
          'streak': currentStreak + 1,
          'lastStreakAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  // GOOD: .set() inside batch — should NOT trigger firestore-use-transactions
  Future<void> resetAllStreaks(List<String> userIds) async {
    try {
      final batch = _firestore.batch();
      for (final uid in userIds) {
        final ref = _firestore.collection('users').doc(uid);
        // This .set() is inside a batch — should be SUPPRESSED
        batch.set(ref, {'streak': 0}, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // BAD: .update() NOT inside a transaction — SHOULD trigger firestore-use-transactions
  Future<void> breakStreak(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);

    // This .update() is direct — should be FLAGGED
await userRef.update({
      'streak': 0,
      'streakBrokenAt': FieldValue.serverTimestamp(),
    });
      });
    });

    print('Streak broken for $userId'); // Triggers no-print-statements
  }
}
