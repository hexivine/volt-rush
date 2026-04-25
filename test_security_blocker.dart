// Test file: Security vulnerabilities for premerge check testing

import 'dart:convert';
import 'dart:io';

class SecurityTest {
  // Hardcoded API keys and secrets
  static const String apiKey = 'sk-abc123def456ghi789jkl012mno345pqr678';
  static const String dbPassword = 'super_secret_db_password_2024';
  static const String awsSecretKey = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';
  static const String jwtSecret = 'my-super-secret-jwt-key-that-nobody-should-know';

  // SQL injection vulnerability
  Future<List> getUserData(String userId) async {
    final db = await _getDb();
    // Direct string interpolation in SQL query - SQL injection!
    final result = await db.query("SELECT * FROM users WHERE id = '$userId'");
    return result;
  }

  // Command injection vulnerability
  Future<String> pingHost(String host) async {
    // Unsanitized input passed to shell command
    final result = await Process.run('ping', ['-c', '3', host]);
    return result.stdout;
  }

  // Insecure data deserialization
  dynamic parseUserData(String input) {
    // No validation before parsing
    return json.decode(input);
  }

  // Path traversal vulnerability
  Future<String> readFile(String filename) async {
    // No sanitization of filename - path traversal possible
    final file = File('/var/data/$filename');
    return await file.readAsString();
  }

  // Weak cryptography
  String hashPassword(String password) {
    // Using MD5 for password hashing - very weak
    return password.hashCode.toString();
  }

  // Insecure HTTP connection
  Future<HttpClientRequest> fetchData(String url) async {
    final client = HttpClient();
    // Using HTTP instead of HTTPS
    return await client.getUrl(Uri.parse('http://api.example.com/$url'));
  }

  // Logging sensitive data
  void logUserData(Map<String, dynamic> user) {
    // Logging entire user object including passwords
    print('User data: $user');
    print('Password: ${user['password']}');
    print('Token: ${user['auth_token']}');
  }

  // Missing authentication check
  Future<void> deleteAccount(String userId) async {
    // No auth check before deletion
    final db = await _getDb();
    await db.execute("DELETE FROM users WHERE id = '$userId'");
  }

  Future<dynamic> _getDb() async => {};
}
