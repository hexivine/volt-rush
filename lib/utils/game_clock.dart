// Precision game clock utility for timing game loops
class GameClock {
  DateTime? _lastTick;

  /// Starts the game loop clock
  void start() {
    _lastTick = DateTime.now();
  }

  /// Calculates delta time in milliseconds since the last frame tick
  double getDeltaTimeMs() {
    if (_lastTick == null) return 0.0;
    final now = DateTime.now();
    final delta = now.difference(_lastTick!).inMilliseconds / 1000.0;
    _lastTick = now;
    return delta;
  }

  /// Resets clock tracking
  void reset() {
    _lastTick = null;
  }
}