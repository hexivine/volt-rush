/// Utility for formatting game scores for display.
class ScoreFormatter {
  /// Format a score with thousands separators.
  /// Example: 1234567 -> "1,234,567"
  static String format(int score) {
    if (score < 0) return '-${format(-score)}';
    if (score < 1000) return score.toString();

    final str = score.toString();
    final buffer = StringBuffer();
    final remainder = str.length % 3;

    if (remainder > 0) {
      buffer.write(str.substring(0, remainder));
      if (str.length > remainder) buffer.write(',');
    }

    for (int i = remainder; i < str.length; i += 3) {
      buffer.write(str.substring(i, i + 3));
      if (i + 3 < str.length) buffer.write(',');
    }

    return buffer.toString();
  }

  /// Format score with suffix (K, M).
  /// Example: 1500 -> "1.5K", 2000000 -> "2.0M"
  static String formatCompact(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    }
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }

  /// Get a rank suffix (1st, 2nd, 3rd, 4th...).
  static String rankSuffix(int rank) {
    if (rank <= 0) return '';
    final lastTwo = rank % 100;
    if (lastTwo >= 11 && lastTwo <= 13) return '${rank}th';
    switch (rank % 10) {
      case 1: return '${rank}st';
      case 2: return '${rank}nd';
      case 3: return '${rank}rd';
      default: return '${rank}th';
    }
  }
}
