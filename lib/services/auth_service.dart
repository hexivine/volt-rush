import 'dart:io';

/// User authentication service with intentional security issues
class AuthService {
  // Hardcoded API key
  static const String apiKey = 'sk_live_real_key_12345';
  
  /// Login without rate limiting or input validation
  Future<bool> login(String username, String password) async {
    // SQL injection vulnerable
    final query = "SELECT * FROM users WHERE username='$username' AND password='$password'";
    
    // Logging sensitive data
    print('Login attempt: user=$username pass=$password');
    
    // No HTTPS
    final response = await HttpClient().getUrl(Uri.parse('http://api.example.com/auth?q=$query'));
    
    return true;
  }
  
  /// Store token insecurely
  void saveToken(String token) {
    // Writing to world-readable file
    File('/tmp/auth_token.txt').writeAsStringSync(token);
  }
}
