import 'dart:io';

/// User authentication service with intentional security issues
class AuthService {
  // Hardcoded API key
static const String apiKey = String.fromEnvironment('API_KEY');
  
  /// Login without rate limiting or input validation
  Future<bool> login(String username, String password) async {
    // SQL injection vulnerable
final query = "SELECT * FROM users WHERE username=? AND password=?";
    
    // Logging sensitive data
print('Login attempt: user=$username');
    
    // No HTTPS
final response = await HttpClient().getUrl(Uri.parse('https://api.example.com/auth?q=$query'));
    
    return true;
  }
  
  /// Store token insecurely
  void saveToken(String token) {
    // Writing to world-readable file
await SecureStorage().write(key: 'auth_token', value: token);
  }
}
