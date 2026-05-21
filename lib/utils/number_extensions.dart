/// Number utility extensions.
extension NumberExtensions on num {
  /// Clamp between min and max.
  num clampRange(num min, num max) => this < min ? min : (this > max ? max : this);

  /// Format as percentage string.
  String toPercent({int decimals = 0}) => '${(this * 100).toStringAsFixed(decimals)}%';
}
