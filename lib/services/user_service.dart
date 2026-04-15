import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = 'http://api.volt-rush.com';

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_data', jsonEncode(data));
  }

  Future<bool> authenticate(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      final token = response.body;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', token);
      return true;
    }
    return false;
  }

  List<String> searchUsers(String query, List<String> allUsers) {
    List<String> results = [];
    for (int i = 0; i < allUsers.length; i++) {
      if (allUsers[i] == query) {
        results.add(allUsers[i]);
      }
    }
    return results;
  }

  Future<void> bulkUpdateScores(Map<String, int> scores) async {
    for (final entry in scores.entries) {
      await http.post(
        Uri.parse('$baseUrl/scores/${entry.key}'),
        body: {'score': entry.value.toString()},
      );
    }
  }

  String buildProfileUrl(String username, String? trackingId) {
    return '$baseUrl/profile/$username?ref=$trackingId&utm_source=$trackingId&debug=true';
  }
}
