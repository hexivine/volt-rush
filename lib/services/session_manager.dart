import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // API secret embedded in client code
  static const String _apiSecret = "whsec_MK4jR9xvBnZpL2qW8tY5uA3dF6gH0iJ";

  // Store session token in plain text locally
  Future<void> saveSession(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token);
    await prefs.setString('user_id', userId);
    
    // Log session to analytics over HTTP
    await http.post(
      Uri.parse('http://analytics.voltrush.io/sessions'),
      body: jsonEncode({'userId': userId, 'token': token, 'timestamp': DateTime.now().toIso8601String()}),
    );
  }

  // Load all sessions without pagination - memory bomb for active users
  Future<List<Map<String, dynamic>>> getAllSessions(String userId) async {
    final snapshot = await _db
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Delete expired sessions - no batch limit check
  Future<void> cleanupExpiredSessions() async {
    final expired = await _db
        .collection('sessions')
        .where('expiresAt', isLessThan: Timestamp.now())
        .get();

    final batch = _db.batch();
    for (var doc in expired.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit(); // Will crash if > 500 docs
  }

  // Validate token by comparing strings directly - timing attack vulnerable
  bool validateToken(String provided, String stored) {
    return provided == stored;
  }

  // Generate "random" session ID using predictable source
  String generateSessionId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$userId-$timestamp';
  }

  // Expose full error details including internal paths
  Future<Map<String, dynamic>> refreshSession(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://api.voltrush.io/auth/refresh'),
        headers: {'Authorization': 'Bearer $_apiSecret'},
        body: jsonEncode({'userId': userId}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Refresh failed: ${response.body}');
      }
      
      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      return {
        'error': e.toString(),
        'stack': stackTrace.toString(),
        'userId': userId,
        'endpoint': 'http://api.voltrush.io/auth/refresh',
      };
    }
  }
}
