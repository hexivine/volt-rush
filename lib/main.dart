
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const TheLastTapApp(),
    ),
  );
}

class TheLastTapApp extends StatelessWidget {
  const TheLastTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Last Tap',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.pressStart2pTextTheme(),
      ),
      home: const GameScreen(),
    );
  }
}

class GameProvider with ChangeNotifier {
  int _currentScore = 0;
  int _highScore = 0;
  double _timerValue = 1.0;
  bool _isPlaying = false;
  bool _isBusted = false;
  bool _isBanked = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController = ConfettiController();

  int get currentScore => _currentScore;
  int get highScore => _highScore;
  double get timerValue => _timerValue;
  bool get isPlaying => _isPlaying;
  bool get isBusted => _isBusted;
  bool get isBanked => _isBanked;
  ConfettiController get confettiController => _confettiController;

  GameProvider() {
    _loadHighScore();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    notifyListeners();
  }

  void _saveHighScore() async {
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _highScore);
    }
  }

  void startGame() {
    _currentScore = 0;
    _isBusted = false;
    _isBanked = false;
    _isPlaying = true;
    _timerValue = 1.0;
    notifyListeners();
  }

  void tap() {
    if (!_isPlaying) {
      startGame();
    }
    _currentScore++;
    _timer?.cancel();
    _timerValue *= 0.95;
    if (_timerValue < 0.2) {
      _timerValue = 0.2;
    }
    _startTimer();
    _audioPlayer.play(AssetSource('sounds/tap.wav'));
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer(Duration(milliseconds: (2000 * _timerValue).toInt()), () {
      _bust();
    });
  }

  void _bust() {
    _isPlaying = false;
    _isBusted = true;
    _timer?.cancel();
    Vibration.vibrate();
    _audioPlayer.play(AssetSource('sounds/bust.wav'));
    notifyListeners();
  }

  void bankScore() {
    _isPlaying = false;
    _isBanked = true;
    _saveHighScore();
    _timer?.cancel();
    _confettiController.play();
    _audioPlayer.play(AssetSource('sounds/bank.wav'));
    notifyListeners();
  }

  void resetGame() {
    _isPlaying = false;
    _isBusted = false;
    _isBanked = false;
    _currentScore = 0;
    _timerValue = 1.0;
    _timer?.cancel();
    notifyListeners();
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: game.isBusted
                    ? [Colors.red.shade700, Colors.red.shade900]
                    : [Colors.blue.shade700, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Best: ${game.highScore}',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    'Now: ${game.currentScore}',
                    style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 100),
                  if (game.isPlaying || !game.isBusted && !game.isBanked)
                    _buildTapButton(game, context),
                  if (game.isBusted || game.isBanked)
                    _buildEndScreen(game, context),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: game.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapButton(GameProvider game, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: game.timerValue,
                strokeWidth: 10,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
              ElevatedButton(
                onPressed: () => game.tap(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                ),
                child: const Text('TAP',
                    style: TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        if (game.isPlaying)
          ElevatedButton(
            onPressed: () => game.bankScore(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
            child: const Text('STOP', style: TextStyle(fontSize: 24)),
          ),
      ],
    );
  }

  Widget _buildEndScreen(GameProvider game, BuildContext context) {
    return Column(
      children: [
        Text(
          game.isBusted ? 'BUSTED!' : 'BANKED!',
          style: TextStyle(
              fontSize: 48,
              color: game.isBusted ? Colors.yellow : Colors.green,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () => game.resetGame(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          ),
          child: const Text('PLAY AGAIN', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}
