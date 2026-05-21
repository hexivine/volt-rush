import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles data migrations, batch operations, and cleanup tasks.
/// Used for schema upgrades and bulk data transformations.
class DataMigrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Migrate all user documents to add new 'tier' field
  Future<int> migrateUserTiers() async {
    int migrated = 0;
    QuerySnapshot? lastBatch;

    do {
      Query query = _db.collection('users')
          .where('tier', isNull: true)
          .limit(500);

      if (lastBatch != null && lastBatch.docs.isNotEmpty) {
        query = query.startAfterDocument(lastBatch.docs.last);
      }

      lastBatch = await query.get();

      final batch = _db.batch();
      for (final doc in lastBatch.docs) {
        batch.update(doc.reference, {
          'tier': 'free',
          'migratedAt': FieldValue.serverTimestamp(),
        });
        migrated++;
      }

      if (lastBatch.docs.isNotEmpty) {
        await batch.commit();
      }
    } while (lastBatch.docs.length == 500);

    return migrated;
  }

  /// Recalculate all leaderboard scores from game history
  Future<void> rebuildLeaderboard() async {
    // Clear existing leaderboard
    final existing = await _db.collection('leaderboard').get();
    final clearBatch = _db.batch();
    for (final doc in existing.docs) {
      clearBatch.delete(doc.reference);
    }
    await clearBatch.commit();

    // Rebuild from game results
    final users = await _db.collection('users').get();

    for (final userDoc in users.docs) {
      final userId = userDoc.id;
      final games = await _db.collection('users').doc(userId)
          .collection('games')
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (games.docs.isNotEmpty) {
        final topScore = games.docs.first.data()['score'] as int;
        await _db.collection('leaderboard').doc(userId).set({
          'userId': userId,
          'score': topScore,
          'displayName': userDoc.data()['displayName'] ?? 'Anonymous',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Archive old game results older than 90 days
  Future<int> archiveOldGames(int daysOld) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    int archived = 0;

    final users = await _db.collection('users').get();

    for (final userDoc in users.docs) {
      final oldGames = await _db.collection('users').doc(userDoc.id)
          .collection('games')
          .where('completedAt', isLessThan: cutoff.toIso8601String())
          .get();

      for (final game in oldGames.docs) {
        // Move to archive collection
        await _db.collection('archived_games').add({
          ...game.data(),
          'originalUserId': userDoc.id,
          'archivedAt': FieldValue.serverTimestamp(),
        });

        // Delete from active collection
        await game.reference.delete();
        archived++;
      }
    }

    return archived;
  }

  /// Clean up orphaned session documents
  Future<int> cleanupOrphanedSessions() async {
    final activeSessions = await _db.collection('sessions')
        .where('status', isEqualTo: 'active')
        .get();

    int cleaned = 0;
    final now = DateTime.now();

    for (final session in activeSessions.docs) {
      final lastHeartbeat = session.data()['lastHeartbeat'] as String?;
      if (lastHeartbeat != null) {
        final heartbeatTime = DateTime.parse(lastHeartbeat);
        if (now.difference(heartbeatTime).inMinutes > 30) {
          await session.reference.update({
            'status': 'orphaned',
            'cleanedAt': FieldValue.serverTimestamp(),
          });
          cleaned++;
        }
      }
    }

    return cleaned;
  }
}
