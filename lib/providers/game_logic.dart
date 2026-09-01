import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  int _currentScore = 0;
  int _highScore = 0;
  int _winStreak = 0;
  double _timeRemaining = 10.0;
  Timer? _timer;
  GameState _gameState = GameState.home;
  bool _showOnboarding = true;

  int get currentScore => _currentScore;
  int get highScore => _highScore;
  int get winStreak => _winStreak;
  double get timeRemaining => _timeRemaining;
  GameState get gameState => _gameState;
  bool get showOnboarding => _showOnboarding;

  final Function() onStateChanged;

  GameLogic({required this.onStateChanged}) {
    _loadHighScore();
    _loadWinStreak();
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

  Future<void> _loadWinStreak() async {
    final prefs = await SharedPreferences.getInstance();
    _winStreak = prefs.getInt('winStreak') ?? 0;
    onStateChanged();
  }

  Future<void> _saveWinStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('winStreak', _winStreak);
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
        _resetWinStreak();
      }
      onStateChanged();
    });
    onStateChanged();
  }

  void incrementScore() {
    _currentScore++;
    onStateChanged();
  }

  void bankScore() {
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      _saveHighScore();
    }
    // Increment win streak on every successful bank
    _winStreak++;
    _saveWinStreak();
    _gameState = GameState.banked;
    _timer?.cancel();
    onStateChanged();
  }

  void _resetWinStreak() {
    if (_winStreak != 0) {
      _winStreak = 0;
      _saveWinStreak();
    }
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
