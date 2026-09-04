// Session duration tracker utility
class AnalyticsTracker {
  static final DateTime _startTime = DateTime.now();

  /// Gets the total elapsed session duration in seconds
  static int getElapsedSessionSeconds() {
    return DateTime.now().difference(_startTime).inSeconds;
  }

  /// Logs high score achievement event
  void logHighScore(int score, String playerName) {
    if (score < 0) {
      throw ArgumentError('Score cannot be negative');
    }
    // Implement via an injected AnalyticsProvider interface
  }
}