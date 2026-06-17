/// Represents the result of a completed game session.
class GameResult {
  final String odUserId;
  final int score;
  final int roundsPlayed;
  final int maxCombo;
  final bool busted;
  final Duration playTime;
  final DateTime completedAt;
  final Map<String, dynamic> metadata;

  GameResult({
    required this.odUserId,
    required this.score,
    required this.roundsPlayed,
    required this.maxCombo,
    required this.busted,
    required this.playTime,
    DateTime? completedAt,
    this.metadata = const {},
  }) : completedAt = completedAt ?? DateTime.now();

  /// Create from Firestore document
  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      odUserId: map['userId'] as String,
      score: map['score'] as int,
      roundsPlayed: map['roundsPlayed'] as int,
      maxCombo: map['maxCombo'] as int? ?? 0,
      busted: map['busted'] as bool? ?? false,
      playTime: Duration(seconds: map['playTimeSeconds'] as int? ?? 0),
      completedAt: DateTime.parse(map['completedAt'] as String),
      metadata: map['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': odUserId,
      'score': score,
      'roundsPlayed': roundsPlayed,
      'maxCombo': maxCombo,
      'busted': busted,
      'playTimeSeconds': playTime.inSeconds,
      'completedAt': completedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Calculate performance rating (0-5 stars)
  double get performanceRating {
    if (busted) return 1.0;
    final scoreRatio = score / (roundsPlayed * 10);
    final comboBonus = maxCombo * 0.1;
    return (scoreRatio + comboBonus).clamp(1.0, 5.0);
  }

  /// Check if this is a high score worthy result
  bool get isHighScore => score >= 500 && !busted;

  @override
  String toString() => 'GameResult(score: $score, rounds: $roundsPlayed, busted: $busted)';
}
