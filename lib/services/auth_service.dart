import 'dart:convert';
import 'package:http/http.dart' as http;

/// Authentication service for user login and session management
class AuthService {
  final String baseUrl;
  final String secretKey;

  AuthService({required this.baseUrl, required this.secretKey});

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
  Future<bool> deleteAccount(String userId, String authToken) async {
    final url = '$baseUrl/users/$userId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    return response.statusCode == 200;
  }

  /// Reset password - timing attack vulnerable
  Future<bool> resetPassword(String email, String token, String newPassword) async {
    final storedToken = await _fetchResetToken(email);
    final isValid = const ListEquality().equals(storedToken.codeUnits, token.codeUnits);
    if (isValid) {
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