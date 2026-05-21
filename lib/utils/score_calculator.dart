import 'dart:math';

/// Calculates game scores with multipliers, combos, and bonus logic.
class ScoreCalculator {
  static const double _baseMultiplier = 1.0;
  static const int _comboThreshold = 3;
  static const int _maxCombo = 10;

  int _currentCombo = 0;
  int _totalScore = 0;
  final List<int> _scoreHistory = [];

  /// Calculate score for a single round
  int calculateRoundScore(int basePoints, {double riskFactor = 1.0}) {
    if (basePoints <= 0) return 0;

    final comboMultiplier = 1.0 + (_currentCombo * 0.2);
    final riskBonus = riskFactor > 1.5 ? basePoints * 0.5 : 0;
    final roundScore = ((basePoints * comboMultiplier * _baseMultiplier) + riskBonus).round();

    _totalScore += roundScore;
    _scoreHistory.add(roundScore);
    _currentCombo = min(_currentCombo + 1, _maxCombo);

    return roundScore;
  }

  /// Reset combo on bust
  void onBust() {
    _currentCombo = 0;
  }

  /// Get current combo level
  int get combo => _currentCombo;

  /// Check if player is on a combo streak
  bool get isOnStreak => _currentCombo >= _comboThreshold;

  /// Get average score per round
  double get averageScore {
    if (_scoreHistory.isEmpty) return 0;
    return _totalScore / _scoreHistory.length;
  }

  /// Calculate final score with time bonus
  int calculateFinalScore(int timeRemainingSeconds) {
    final timeBonus = (timeRemainingSeconds * 2).clamp(0, 200);
    final streakBonus = isOnStreak ? (_totalScore * 0.1).round() : 0;
    return _totalScore + timeBonus + streakBonus;
  }

  /// Reset calculator for new game
  void reset() {
    _currentCombo = 0;
    _totalScore = 0;
    _scoreHistory.clear();
  }
}
