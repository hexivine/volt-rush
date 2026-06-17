/// Input validation utilities.
class Validators {
  /// Validate email format.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate username (alphanumeric, 3-20 chars).
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  /// Validate score is within acceptable range.
  static bool isValidScore(int score) {
    return score >= 0 && score <= 999999;
  }
}
