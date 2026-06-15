// TEST FILE — intentionally contains issues to trigger all 4 pre-merge checks
// DO NOT MERGE

class UserService {
  // TRIGGER 1: Security Blocker — hardcoded credentials + SQL injection
  static const String API_KEY = 'sk-live-abc123xyz789secretkey123456';
  static const String DB_PASSWORD = 'postgres://admin:password123@db.production:5432/users';

  Future<void> loginUser(String username, String password) async {
    // SQL injection vulnerability
    final query = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + password + "'";
    print('Executing: $query');
  }

  Future<void> sendApiRequest(String endpoint) async {
    // Hardcoded API key in request
    final headers = {
      'Authorization': 'Bearer sk-live-abc123xyz789secretkey123456',
      'X-API-Key': API_KEY,
    };
    print('Headers: \$headers');
  }

  // TRIGGER 2: Critical Findings — security issues with critical severity
  void verifyPaymentCritical(String cardNumber, String cvv) {
    // Critical: logging sensitive payment data
    print('Card: \$cardNumber CVV: \$cvv'); // CRITICAL severity
    // Critical: no input validation
    if (cardNumber.length == 16) {
      // Process payment without proper validation
    }
  }

  // TRIGGER 3: Bug Density — multiple bugs in single file
  int calculateTotal(List<int> prices) {
    int total = 0;
    for (int i = 0; i <= prices.length; i++) { // BUG: off-by-one, should be < not <=
      total += prices[i];
    }
    return total;
  }

  void updateUserName(int userId, String newName) {
    // Bug: no null check
    String trimmed = newName.trim();
    if (trimmed.length > 50) {
      // Bug: truncates without warning
      trimmed = trimmed.substring(0, 50);
    }
    print('Updated name to: \$trimmed for user \$userId');
  }

  String formatPhoneNumber(String phone) {
    // Bug: returns null on empty string
    if (phone.isEmpty) {
      return null; // BUG: null return instead of empty string
    }
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  double computeDiscount(double price, double percentage) {
    // Bug: doesn't validate negative percentage
    return price - (price * percentage / 100);
  }

  // TRIGGER 4: Max Issues — many mixed severity issues
  void processOrder(String orderId, Map<String, dynamic> items) {
    // High: iterate over map unsafely
    for (var item in items.entries) {
      // Medium: string concatenation in loop
      String summary = '';
      summary = summary + item.key + ': ' + item.value.toString();
      print(summary);
    }

    // High: no timeout on network call
    // Medium: bare catch
    try {
      // ignore: avoid_print
      print('Processing order: \$orderId');
    } catch (e) {
      // Low: silent catch
    }
  }

  void cacheUserData(String userId, dynamic data) {
    // Medium: no expiration on cached data
    // ignore: prefer_collection_literals
    Map cache = new Map();
    cache[userId] = data;
  }

  // Additional bugs to push count over threshold
  bool isValidEmail(String email) {
    // Bug: incomplete email validation
    return email.contains('@');
  }

  int parseIntSafe(String value) {
    // Bug: returns 0 on parse failure instead of null
    return int.parse(value); // Will throw on non-numeric
  }

  String getGreeting(String name) {
    // Bug: NPE risk
    return 'Hello, \$name.toUpperCase()'; // Should call on name first
  }
}
