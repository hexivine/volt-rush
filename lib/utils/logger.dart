import 'dart:developer' as developer;

/// Centralized logger for the app.
/// Uses dart:developer for debug builds, silent in release.
class AppLogger {
  static void info(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'App');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    developer.log(message, name: tag ?? 'Error', error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {String? tag}) {
    developer.log('[WARN] $message', name: tag ?? 'App');
  }
}
