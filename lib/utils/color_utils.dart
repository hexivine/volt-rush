import 'dart:ui';

/// Color utilities for the game theme.
class ColorUtils {
  static Color darken(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).round(),
      (color.green * (1 - amount)).round(),
      (color.blue * (1 - amount)).round(),
    );
  }
}
