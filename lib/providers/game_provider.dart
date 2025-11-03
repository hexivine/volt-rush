import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:myapp/providers/animation_provider.dart';

enum GameState { idle, playing, busted, banked, onboarding, settings, share }

class GameProvider with ChangeNotifier {
  GameState _gameState = GameState.onboarding;
  int _currentScore = 0;
  int _highScore = 0;
  double _timerValue = 1.0;
  Timer? _timer;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  double _timerDecrement = 0.001;
  bool isGameActive = false;
  final AnimationProvider _animationProvider;

  GameState get gameState => _gameState;
  int get currentScore => _currentScore;
  int get highScore => _highScore;
  double get timerValue => _timerValue;
  ConfettiController get confettiController => _confettiController;

  GameProvider(this._animationProvider) {
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadHighScore();
    _checkOnboarding();
  }

  void _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (hasSeenOnboarding) {
      _gameState = GameState.idle;
    }
    notifyListeners();
  }

  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    _gameState = GameState.idle;
    notifyListeners();
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
  
  void resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    _highScore = 0;
    notifyListeners();
  }

  void _playBustSound() async {
    await _sfxPlayer.play(AssetSource('audio/bust.mp3'));
  }

  void _playBankSound() async {
    await _sfxPlayer.play(AssetSource('audio/bank.mp3'));
  }

  void _playTapSound() async {
    await _sfxPlayer.play(AssetSource('audio/tap.mp3'));
  }

  void _startBackgroundMusic() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/background.mp3'));
  }

  void _stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  void tap() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
    if (!isGameActive) {
      isGameActive = true;
      _startTimer();
      _startBackgroundMusic();
    }

    if (_gameState == GameState.playing) {
      _currentScore++;
      _timerValue = 1.0;
      _timerDecrement += 0.0001;
      _playTapSound();
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

  void _bust() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 400);
    }
    _timer?.cancel();
    isGameActive = false;
    _gameState = GameState.busted;
    _playBustSound();
    _stopBackgroundMusic();
    _animationProvider.triggerShake();
    notifyListeners();
  }

  void bankScore() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    _timer?.cancel();
    isGameActive = false;
    _gameState = GameState.banked;
    _saveHighScore();
    _playBankSound();
    _stopBackgroundMusic();
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
    _stopBackgroundMusic();
    notifyListeners();
  }

  void showSettings() {
    _gameState = GameState.settings;
    notifyListeners();
  }

  void hideSettings() {
    _gameState = GameState.idle;
    notifyListeners();
  }

  void showShare() {
    _gameState = GameState.share;
    notifyListeners();
  }

  void hideShare() {
    _gameState = GameState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
