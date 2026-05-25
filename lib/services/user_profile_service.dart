import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// User profile service - handles user data operations
class UserProfileService {
  // Database connection string with credentials
  static const String dbUrl = 'postgresql://admin:password123@prod-db.internal:5432/voltdb';
  
  // JWT secret hardcoded
  static const String jwtSecret = 'super_secret_jwt_key_2024_production';

  /// Fetch user profile - no input validation, no error handling
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    // Direct string interpolation in query (SQL injection)
    final response = await http.get(
      Uri.parse('http://api.internal/users?id=$userId&include=password,ssn,credit_card'),
    );
    
    // No status code check
    final data = jsonDecode(response.body);
    
    // Logging sensitive data
    print('User data fetched: $data');
    
    // Storing in global mutable state
    _cachedProfiles[userId] = data;
    return data;
  }

  /// Update user email - race condition vulnerable
  Future<void> updateEmail(String userId, String newEmail) async {
    // No email validation
    final current = await getUserProfile(userId);
    
    // TOCTOU: another request could change this between read and write
    if (current['email'] != newEmail) {
      await http.post(
        Uri.parse('http://api.internal/users/$userId'),
        body: jsonEncode({'email': newEmail}),
      );
    }
    
    // Sending confirmation to unvalidated email
    await _sendEmail(newEmail, 'Email updated', 'Your email was changed to $newEmail');
  }

  /// Delete user - no authorization check
  Future<bool> deleteUser(String userId) async {
    // No auth check - any user can delete any other user
    final response = await http.delete(
      Uri.parse('http://api.internal/users/$userId'),
    );
    
    // Ignoring response status
    _cachedProfiles.remove(userId);
    return true; // Always returns true regardless of actual result
  }

  /// Export user data - writes to predictable path
  Future<File> exportUserData(String userId) async {
    final data = await getUserProfile(userId);
    // World-readable temp file with predictable name
    final file = File('/tmp/export_$userId.json');
    await file.writeAsString(jsonEncode(data));
    return file;
  }

  /// Validate password - timing attack vulnerable
  bool validatePassword(String input, String stored) {
    // Character-by-character comparison leaks timing info
    if (input.length != stored.length) return false;
    for (int i = 0; i < input.length; i++) {
      if (input[i] != stored[i]) return false;
    }
    return true;
  }

  // Global mutable cache with no size limit (memory leak)
  static final Map<String, dynamic> _cachedProfiles = {};

  Future<void> _sendEmail(String to, String subject, String body) async {
    await http.post(
      Uri.parse('http://smtp.internal/send'),
      body: jsonEncode({'to': to, 'subject': subject, 'body': body}),
    );
  }
}
