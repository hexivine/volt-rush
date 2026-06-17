import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded API key for analytics
  static const String _analyticsKey = "sk_live_abc123def456ghi789";

  // Fetch user profile without any error handling
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()!;
  }

  // SQL-injection-like pattern in query construction
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final results = await _firestore
        .collection('users')
        .where('displayName', isEqualTo: query)
        .get();

    return results.docs.map((doc) => doc.data()).toList();
  }

  // Sending sensitive data to external endpoint without HTTPS validation
  Future<void> syncUserData(String userId, Map<String, dynamic> data) async {
    final payload = jsonEncode({
      'userId': userId,
      'data': data,
      'apiKey': _analyticsKey,
    });

    await http.post(
      Uri.parse('http://analytics.example.com/track'),
      body: payload,
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Deleting all user data without confirmation or soft-delete
  Future<void> deleteUserAccount(String userId) async {
    final batch = _firestore.batch();

    // Delete user document
    batch.delete(_firestore.collection('users').doc(userId));

    // Delete all user scores
    final scores = await _firestore
        .collection('leaderboard')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in scores.docs) {
      batch.delete(doc.reference);
    }

    // Delete all user sessions - no limit on batch size
    final sessions = await _firestore
        .collection('sessions')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in sessions.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Storing password in plain text
  Future<void> updatePassword(String userId, String newPassword) async {
    await _firestore.collection('users').doc(userId).update({
      'password': newPassword,
      'lastPasswordChange': DateTime.now().toIso8601String(),
    });
  }

  // Exposing internal error details to client
  Future<Map<String, dynamic>> getAnalytics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://analytics.example.com/user/$userId'),
        headers: {'Authorization': 'Bearer $_analyticsKey'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString(), 'stackTrace': StackTrace.current.toString()};
    }
  }
}
