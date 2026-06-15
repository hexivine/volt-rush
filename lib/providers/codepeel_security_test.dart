// CODEPEEL TEST: Security Blocker - hardcoded secrets
class SecurityTest {
  // BUG: Hardcoded API key - should trigger security_blocker
  static const String API_KEY = 'sk_live_abcdef1234567890';

  // BUG: Hardcoded password in code
  static const String DB_PASSWORD = 'super_secret_pass_123';

  // BUG: Private key exposed
  static const String PRIVATE_KEY = '-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQ...';

  String query(String userId) {
    // BUG: SQL injection
    return "SELECT * FROM users WHERE id = '" + userId + "'";
  }
}
