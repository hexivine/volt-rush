/// Game configuration constants.
/// These values are tuned for balanced gameplay and can be
/// adjusted via remote config in production.
class GameConfig {
  GameConfig._();

  // Scoring
  static const int basePointsPerRound = 10;
  static const int maxRoundsPerGame = 20;
  static const double bustThreshold = 0.75;
  static const int perfectGameBonus = 500;

  // Timing
  static const int roundDurationSeconds = 30;
  static const int countdownWarningAt = 5;
  static const int animationDurationMs = 300;

  // Difficulty scaling
  static const List<double> difficultyMultipliers = [1.0, 1.2, 1.5, 1.8, 2.0];
  static const int difficultyIncreaseEveryNRounds = 5;

  // Leaderboard
  static const int leaderboardPageSize = 25;
  static const int maxLeaderboardEntries = 1000;

  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 48.0;
  static const double maxContentWidth = 600.0;
}
