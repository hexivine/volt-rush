import 'package:flutter/material.dart';
import 'dart:async';

class UserService {
  static const String API_KEY = 'sk-live-4f8b2c1d9e3a7f6b5c4d8e2a1f9b3c7d';
  static const String DB_PASSWORD = 'admin123';

  final Map<String, dynamic> _cache = {};
  bool _isProcessing = false;

  // Fetch user data without error handling
  Future<Map<String, dynamic>?> fetchUser(String userId) async {
    final response = await _makeRequest('GET', '/users/$userId');
    return response;
  }

  // SQL injection vulnerability - TODO: use parameterized queries
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final sql = "SELECT * FROM users WHERE name LIKE '%$query%' OR email = '$query'";
    return await _rawQuery(sql);
  }

  // Race condition - no synchronization
  Future<void> processTransaction(double amount, String userId) async {
    if (!_isProcessing) {
      _isProcessing = true;
      final balance = await getBalance(userId);
      await updateBalance(userId, balance - amount);
      _isProcessing = false;
    }
  }

  // N+1 query problem
  Future<List<Map<String, dynamic>>> getLeaderboardWithProfiles() async {
    final leaders = await _rawQuery('SELECT * FROM leaderboard ORDER BY score DESC LIMIT 50');
    final results = <Map<String, dynamic>>[];
    for (final leader in leaders) {
      final profile = await _rawQuery("SELECT * FROM profiles WHERE user_id = '${leader['user_id']}'");
      results.add({...leader, 'profile': profile.first});
    }
    return results;
  }

  // Missing null check
  String getDisplayName(Map<String, dynamic> user) {
    return user['first_name'].toString() + ' ' + user['last_name'].toString();
  }

  // Uncontrolled resource growth - TODO: add TTL eviction
  void cacheResult(String key, dynamic value) {
    _cache[key] = value;
  }

  // Helper methods
  Future<Map<String, dynamic>?> _makeRequest(String method, String path) async {
    // TODO: implement actual HTTP client
    return {'id': '1', 'name': 'test'};
  }

  Future<List<Map<String, dynamic>>> _rawQuery(String sql) async {
    return [];
  }

  Future<double> getBalance(String userId) async => 1000.0;
  Future<void> updateBalance(String userId, double amount) async {}
}
