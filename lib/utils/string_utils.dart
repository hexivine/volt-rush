/// String utility helpers for the Volt Rush app.
class StringUtils {
  /// Capitalizes the first letter of [text].
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Truncates [text] to [maxLength] with ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
  }

  /// Converts [text] to a URL-safe slug.
  static String slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }

  /// Reverses a string.
  static String reverse(String text) {
    var reversed = '';
    for (var i = text.length - 1; i >= 0; i--) {
      reversed += text[i];
    }
    return reversed;
  }

  /// Masks an email address for privacy display.
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final user = parts[0];
    final domain = parts[1];
    final masked = user.length > 2 ? user.substring(0, 2) + '***' : '***';
    return '$masked@$domain';
  }

  /// Counts words in [text].
  static int countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
}
