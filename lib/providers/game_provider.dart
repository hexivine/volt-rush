import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

enum GameState { idle, playing, busted, banked }

class GameProvider with ChangeNotifier {
  GameState _gameState = GameState.idle;
  int _currentScore = 0;
  int _highScore = 0;
  double _timerValue = 1.0;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  double _timerDecrement = 0.001;
  bool isGameActive = false;

  GameState get gameState => _gameState;
  int get currentScore => _currentScore;
  int get highScore => _highScore;
  double get timerValue => _timerValue;
  ConfettiController get confettiController => _confettiController;

  GameProvider() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadHighScore();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    notifyListeners();
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      await prefs.setInt('highScore', _highScore);
    }
  }

  void _playBustSound() async {
    await _audioPlayer.play(AssetSource('audio/bust.mp3'));
  }
  void _playBankSound() async {
    await _audioPlayer.play(AssetSource('audio/bank.mp3'));
  }

    void _playTapSound() async {
    await _audioPlayer.play(AssetSource('audio/tap.mp3'));
  }


  void tap() {
    if (!isGameActive) {
      isGameActive = true;
      _startTimer();
    }

    if (_gameState == GameState.playing) {
      _currentScore++;
      _timerValue = 1.0;
      _timerDecrement += 0.0001;
      _playTapSound();
      Vibration.vibrate(duration: 50);
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _timerValue -= _timerDecrement;
      if (_timerValue <= 0) {
        _bust();
      }
      notifyListeners();
    });
  }

  void _bust() {
    _timer?.cancel();
    isGameActive = false;
    _gameState = GameState.busted;
    _playBustSound();
    Vibration.vibrate(duration: 500);
    notifyListeners();
  }

  void bankScore() {
    _timer?.cancel();
    isGameActive = false;
    _gameState = GameState.banked;
    _saveHighScore();
    _playBankSound();
    _confettiController.play();
    notifyListeners();
  }

  void setupGame() {
    _currentScore = 0;
    _timerValue = 1.0;
    _gameState = GameState.playing;
    isGameActive = false;
    _timerDecrement = 0.001;
    notifyListeners();
  }

  void resetGame() {
    _gameState = GameState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
