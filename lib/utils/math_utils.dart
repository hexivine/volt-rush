/// Math utilities with intentional bugs for testing.
class MathUtils {
  /// This has a division by zero bug.
  static double divide(double a, double b) {
    return a / b; // No zero check!
  }

  /// SQL injection vulnerability for testing.
  static String buildQuery(String userInput) {
    return "SELECT * FROM users WHERE name = '$userInput'";
  }
}
