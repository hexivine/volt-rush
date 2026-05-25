import 'package:cloud_firestore/cloud_firestore.dart';

/// Leaderboard service with in-memory caching and pagination support.
/// Caches the top scores to reduce Firestore reads and supports
/// cursor-based pagination for infinite scroll.
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _leaderboardCollection =
      FirebaseFirestore.instance.collection('leaderboard');

  // In-memory cache
  List<Map<String, dynamic>>? _cachedLeaderboard;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 5);
  static const _defaultPageSize = 20;

  /// Submit a score. Only updates if the new score is higher than existing.
  Future<void> addScore(String userId, int score, {String? displayName}) async {
    if (userId.isEmpty || score < 0) {
      throw ArgumentError('Invalid userId or score');
    }

    return _firestore.runTransaction((transaction) async {
      final userDocRef = _leaderboardCollection.doc(userId);
      final userDoc = await transaction.get(userDocRef);

      if (userDoc.exists) {
        final existingScore = (userDoc.data() as Map<String, dynamic>)['score'] ?? 0;
        if (score > existingScore) {
          transaction.update(userDocRef, {
            'score': score,
            'displayName': displayName,
            'timestamp': FieldValue.serverTimestamp(),
            'gamesPlayed': FieldValue.increment(1),
          });
        }
      } else {
        transaction.set(userDocRef, {
          'score': score,
          'displayName': displayName,
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
          'gamesPlayed': 1,
          'streak': 0,
        });
      }
    });

    // Invalidate cache after score submission
    _invalidateCache();
  }

  /// Get the top leaderboard entries as a real-time stream.
  Stream<QuerySnapshot> getLeaderboard({int limit = 10}) {
    return _leaderboardCollection
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Fetch a paginated leaderboard page using cursor-based pagination.
  /// Pass [lastDocument] from the previous page to get the next page.
  Future<LeaderboardPage> getLeaderboardPage({
    int pageSize = _defaultPageSize,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _leaderboardCollection
        .orderBy('score', descending: true)
        .limit(pageSize + 1); // Fetch one extra to detect hasMore

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;
    final hasMore = docs.length > pageSize;
    final pageDocs = hasMore ? docs.sublist(0, pageSize) : docs;

    return LeaderboardPage(
      entries: pageDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LeaderboardEntry(
          userId: data['userId'] ?? doc.id,
          displayName: data['displayName'] ?? 'Anonymous',
          score: data['score'] ?? 0,
          gamesPlayed: data['gamesPlayed'] ?? 0,
          streak: data['streak'] ?? 0,
          timestamp: data['timestamp'],
        );
      }).toList(),
      lastDocument: pageDocs.isNotEmpty ? pageDocs.last : null,
      hasMore: hasMore,
    );
  }

  /// Get cached top scores. Returns from cache if fresh, otherwise fetches.
  Future<List<Map<String, dynamic>>> getCachedTopScores({int limit = 10}) async {
    if (_isCacheValid()) {
      return _cachedLeaderboard!.take(limit).toList();
    }

    final snapshot = await _leaderboardCollection
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    _cachedLeaderboard = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'userId': data['userId'] ?? doc.id,
        'displayName': data['displayName'] ?? 'Anonymous',
        'score': data['score'] ?? 0,
        'gamesPlayed': data['gamesPlayed'] ?? 0,
      };
    }).toList();
    _cacheTimestamp = DateTime.now();

    return _cachedLeaderboard!;
  }

  /// Get a user's rank on the leaderboard.
  Future<int?> getUserRank(String oderId) async {
    final userDoc = await _leaderboardCollection.doc(oderId).get();
    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>;
    final userScore = userData['score'] ?? 0;

    // Count how many users have a higher score
    final higherScores = await _leaderboardCollection
        .where('score', isGreaterThan: userScore)
        .count()
        .get();

    return (higherScores.count ?? 0) + 1;
  }

  /// Delete a user's leaderboard entry (for account deletion).
  Future<void> deleteUserEntry(String oderId) async {
    await _leaderboardCollection.doc(oderId).delete();
    _invalidateCache();
  }

  bool _isCacheValid() {
    if (_cachedLeaderboard == null || _cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  void _invalidateCache() {
    _cachedLeaderboard = null;
    _cacheTimestamp = null;
  }
}

/// Represents a single page of leaderboard results.
class LeaderboardPage {
  final List<LeaderboardEntry> entries;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const LeaderboardPage({
    required this.entries,
    required this.lastDocument,
    required this.hasMore,
  });
}

/// A single leaderboard entry.
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int score;
  final int gamesPlayed;
  final int streak;
  final dynamic timestamp;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.gamesPlayed,
    required this.streak,
    this.timestamp,
  });
}
