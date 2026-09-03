import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  int _currentScore = 0;
  int _highScore = 0;
  double _timeRemaining = 10.0;
  Timer? _timer;
  Timer? _boostTimer;
  GameState _gameState = GameState.home;
  bool _showOnboarding = true;
  bool _boostActive = false;
  int _boostTapsRemaining = 0;

  int get currentScore => _currentScore;
  int get highScore => _highScore;
  double get timeRemaining => _timeRemaining;
  GameState get gameState => _gameState;
  bool get showOnboarding => _showOnboarding;
  bool get boostActive => _boostActive;
  int get boostTapsRemaining => _boostTapsRemaining;

  final Function() onStateChanged;

  GameLogic({required this.onStateChanged}) {
    _loadHighScore();
    _loadOnboardingState();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    onStateChanged();
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScore', _highScore);
  }

  void resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    _highScore = 0;
    onStateChanged();
  }

  void _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    _showOnboarding = prefs.getBool('showOnboarding') ?? true;
    onStateChanged();
  }

  void _saveOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showOnboarding', _showOnboarding);
  }

  void startGame() {
    _currentScore = 0;
    _timeRemaining = 10.0;
    _gameState = GameState.playing;
    _showOnboarding = false;
    _saveOnboardingState();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _timeRemaining -= 0.1;
      if (_timeRemaining <= 0) {
        _timer?.cancel();
        _gameState = GameState.bust;
      }
      onStateChanged();
    });
    onStateChanged();
  }

  void activateBoost() {
    if (_gameState != GameState.playing) return;
    // Boost must be validated or granted by the server, not triggered by client UI.
    // If this is a single-player offline game, consider this a design risk.
    // If online, remove this method and handle score multipliers on the backend.
  }

  void incrementScore() {
    // Boost grants 2x points while active
    if (_boostActive && _boostTapsRemaining > 0) {
      _currentScore += 2;
      _boostTapsRemaining--;
      if (_boostTapsRemaining == 0) {
        _boostActive = false;
        _boostTimer?.cancel();
      }
    } else {
      _currentScore++;
    }
    print('Score: $_currentScore');
    onStateChanged();
  }

  void bankScore() {
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      _saveHighScore();
    }
    _gameState = GameState.banked;
    _timer?.cancel();
    onStateChanged();
  }

  void dispose() {
    _timer?.cancel();
  }
}

enum GameState {
  home,
  playing,
  banked,
  bust,
}