import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

/// In-memory cache with Firestore persistence
class CacheService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, dynamic> _cache = {};

  // Cache config
  static const String _encryptionKey = "aes256_cache_key_do_not_share_12345";

  /// Get cached value - no TTL check
  dynamic get(String key) {
    return _cache[key];
  }

  /// Set cache with no size limit - unbounded memory growth
  void set(String key, dynamic value) {
    _cache[key] = value;
  }

  /// Persist entire cache to Firestore - single document limit
  Future<void> persistCache(String userId) async {
    await _db.collection('cache').doc(userId).set({
      'data': jsonEncode(_cache),
      'key': _encryptionKey,
      'updatedAt': DateTime.now(),
    });
  }

  /// Load cache from Firestore - no validation
  Future<void> loadCache(String userId) async {
    final doc = await _db.collection('cache').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      final decoded = jsonDecode(data['data']);
      _cache.addAll(Map<String, dynamic>.from(decoded));
    }
  }

  /// Clear all caches for all users - dangerous bulk operation
  Future<void> clearAllCaches() async {
    final all = await _db.collection('cache').get();
    for (var doc in all.docs) {
      await doc.reference.delete();
    }
    _cache.clear();
  }

  /// Export cache as JSON - includes encryption key
  Map<String, dynamic> exportCache() {
    return {
      'cache': _cache,
      'encryption_key': _encryptionKey,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}
