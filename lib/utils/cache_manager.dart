/// Generic in-memory cache with TTL support.
/// Used across services to reduce redundant Firestore reads.
class CacheManager<T> {
  final Duration ttl;
  final Map<String, _CacheEntry<T>> _store = {};

  CacheManager({this.ttl = const Duration(minutes: 5)});

  /// Get a cached value by key. Returns null if expired or missing.
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.createdAt) > ttl) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  /// Store a value in the cache.
  void set(String key, T value) {
    _store[key] = _CacheEntry(value: value, createdAt: DateTime.now());
  }

  /// Remove a specific key from cache.
  void invalidate(String key) {
    _store.remove(key);
  }

  /// Clear all cached entries.
  void clear() {
    _store.clear();
  }

  /// Get the number of cached entries.
  int get size => _store.length;

  /// Check if a key exists and is not expired.
  bool has(String key) => get(key) != null;
}

class _CacheEntry<T> {
  final T value;
  final DateTime createdAt;

  _CacheEntry({required this.value, required this.createdAt});
}
