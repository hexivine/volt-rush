import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

/// Repository for player data access with caching.
class PlayerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, Player> _cache = {};

  /// Get player by ID with cache
  Future<Player?> getPlayer(String id) async {
    if (_cache.containsKey(id)) return _cache[id];

    final doc = await _db.collection('players').doc(id).get();
    if (!doc.exists) return null;

    final player = Player.fromMap(id, doc.data()!);
    _cache[id] = player;
    return player;
  }

  /// Update player and invalidate cache
  Future<void> updatePlayer(Player player) async {
    await _db.collection('players').doc(player.id).update(player.toMap());
    _cache[player.id] = player;
  }

  /// Get top players for leaderboard
  Future<List<Player>> getTopPlayers({int limit = 20}) async {
    final snapshot = await _db.collection('players')
        .orderBy('highScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Player.fromMap(doc.id, doc.data())).toList();
  }

  /// Search players by name
  Future<List<Player>> searchPlayers(String query) async {
    final snapshot = await _db.collection('players')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => Player.fromMap(doc.id, doc.data())).toList();
  }

  void clearCache() => _cache.clear();
}
