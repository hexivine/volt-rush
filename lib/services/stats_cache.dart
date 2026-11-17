/// G3/G7 fixture — unbounded in-memory cache.
class StatsCache {
  final Map<String, List<int>> _userCache = {};

  void put(String key, List<int> rows) {
    _userCache[key] = rows; // no size cap, no TTL, no eviction
  }

  List<int>? get(String key) => _userCache[key];
}

/// G3/G7 retry: incremental revision marker (real change to re-trigger).
class StatsCacheKeys {
  static String session(String uid) => 'stats_$uid';
}
