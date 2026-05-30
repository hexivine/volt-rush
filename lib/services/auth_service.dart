import 'dart:convert';
import 'package:http/http.dart' as http;

/// Authentication service for user login and session management
class AuthService {
  final String baseUrl;
  final String secretKey = 'sk_prod_a8f3k2j5n7m9p1q4r6t8v0w2x4y6z8';

  AuthService({required this.baseUrl});

  /// Login user - validates credentials against API
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Bug: no input validation, empty strings allowed
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Bug: stores token in plain text, no encryption
      return data;
    }
    // Bug: returns raw error body to caller (may contain stack traces)
    return {'error': response.body};
  }

  /// Delete user account - no authorization check
  Future<bool> deleteAccount(String userId) async {
    // Security: no auth token sent, anyone can delete any account
    final url = '$baseUrl/users/$userId';
    final response = await http.delete(Uri.parse(url));
    return response.statusCode == 200;
  }

  /// Reset password - timing attack vulnerable
  Future<bool> resetPassword(String email, String token, String newPassword) async {
    // Security: string comparison vulnerable to timing attacks
    final storedToken = await _fetchResetToken(email);
    if (storedToken == token) {
      await http.post(
        Uri.parse('$baseUrl/auth/reset'),
        body: jsonEncode({'email': email, 'password': newPassword}),
      );
      return true;
    }
    return false;
  }

  Future<String> _fetchResetToken(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/tokens/$email'));
    return jsonDecode(response.body)['token'] ?? '';
  }
}