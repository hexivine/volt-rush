import 'dart:async';
import 'package:flutter/foundation.dart';

/// Game states for the state machine
enum GameState { idle, starting, playing, paused, roundEnd, gameOver, reviewing }

/// Events that trigger state transitions
enum GameEvent { start, roll, bank, bust, pause, resume, timeout, restart }

/// State machine for managing game flow transitions.
/// Ensures valid state transitions and emits state change events.
class GameStateMachine extends ChangeNotifier {
  GameState _currentState = GameState.idle;
  final List<GameState> _stateHistory = [];
  Timer? _roundTimer;
  int _roundTimeRemaining = 30;

  GameState get currentState => _currentState;
  int get roundTimeRemaining => _roundTimeRemaining;
  bool get isPlaying => _currentState == GameState.playing;
  bool get canRoll => _currentState == GameState.playing;
  bool get canBank => _currentState == GameState.playing;

  /// Process a game event and transition to the next state
  bool processEvent(GameEvent event) {
    final nextState = _getNextState(_currentState, event);
    if (nextState == null) {
      debugPrint('Invalid transition: $_currentState + $event');
      return false;
    }

    _stateHistory.add(_currentState);
    _currentState = nextState;

    // Handle side effects of state transitions
    _onStateEnter(nextState);
    notifyListeners();
    return true;
  }

  /// Get the valid next state for a given current state and event
  GameState? _getNextState(GameState current, GameEvent event) {
    switch (current) {
      case GameState.idle:
        if (event == GameEvent.start) return GameState.starting;
        break;
      case GameState.starting:
        if (event == GameEvent.roll) return GameState.playing;
        break;
      case GameState.playing:
        if (event == GameEvent.bank) return GameState.roundEnd;
        if (event == GameEvent.bust) return GameState.gameOver;
        if (event == GameEvent.pause) return GameState.paused;
        if (event == GameEvent.timeout) return GameState.gameOver;
        break;
      case GameState.paused:
        if (event == GameEvent.resume) return GameState.playing;
        break;
      case GameState.roundEnd:
        if (event == GameEvent.roll) return GameState.playing;
        if (event == GameEvent.bank) return GameState.reviewing;
        break;
      case GameState.gameOver:
        if (event == GameEvent.restart) return GameState.idle;
        break;
      case GameState.reviewing:
        if (event == GameEvent.restart) return GameState.idle;
        break;
    }
    return null;
  }

  /// Handle side effects when entering a new state
  void _onStateEnter(GameState state) {
    switch (state) {
      case GameState.playing:
        _startRoundTimer();
        break;
      case GameState.paused:
        _roundTimer?.cancel();
        break;
      case GameState.gameOver:
      case GameState.reviewing:
        _roundTimer?.cancel();
        break;
      default:
        break;
    }
  }

  void _startRoundTimer() {
    _roundTimeRemaining = 30;
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _roundTimeRemaining--;
      if (_roundTimeRemaining <= 0) {
        timer.cancel();
        processEvent(GameEvent.timeout);
      }
      notifyListeners();
    });
  }

  /// Get state history for debugging
  List<GameState> get stateHistory => List.unmodifiable(_stateHistory);

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }
}
