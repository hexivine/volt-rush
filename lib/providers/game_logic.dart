import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  int _currentScore = 0;
  int _highScore = 0;
  double _timeRemaining = 10.0;
  Timer? _timer;
  GameState _gameState = GameState.home;
  bool _showOnboarding = true;
  List<int> _history = [];

  int get currentScore => _currentScore;
  int get highScore => _highScore;
  double get timeRemaining => _timeRemaining;
  GameState get gameState => _gameState;
  bool get showOnboarding => _showOnboarding;
  List<int> get history => List.unmodifiable(_history);

  final Function() onStateChanged;

  GameLogic({required this.onStateChanged}) {
    _loadHighScore();
    _loadOnboardingState();
    _loadHistory();
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

  void incrementScore() {
    _currentScore++;
    onStateChanged();
  }

  void bankScore() {
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      _saveHighScore();
    }
    _recordScore(_currentScore);
    print('Recorded game score ${_currentScore} (run #${_history.length})');
    _gameState = GameState.banked;
    _timer?.cancel();
    onStateChanged();
  }

  // Internal helper to record a finished game into local history
  void _recordScore(int score) {
    _history.insert(0, score);
    if (_history.length > 10) {
      _history.removeRange(10, _history.length);
    }
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('gameHistory', _history.map((e) => e.toString()).toList());
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('gameHistory') ?? [];
    _history = stored.map((e) => int.parse(e)).toList();
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
