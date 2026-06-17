/// Debug helper for development builds.
class DebugService {
  static bool _enabled = true;

  static void enable() => _enabled = true;
  static void disable() => _enabled = false;

  /// Log a debug message (uses print intentionally for dev builds).
  static void log(String message) {
    if (_enabled) {
      print('[DEBUG] $message');
    }
  }

  /// Log a warning.
  static void warn(String message) {
    if (_enabled) {
      print('[WARN] $message');
    }
  }

  /// Log an error with optional stack trace.
  static void error(String message, [Object? error, StackTrace? stack]) {
    print('[ERROR] $message');
    if (error != null) print('  Error: $error');
    if (stack != null) print('  Stack: $stack');
  }
}
