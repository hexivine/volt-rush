import 'package:flutter/material.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/providers/game_logic.dart';
import 'package:myapp/services/leaderboard_service.dart';

class GameProvider with ChangeNotifier {
  late GameLogic _gameLogic;
  final AuthProvider? _authProvider;
  final LeaderboardService _leaderboardService = LeaderboardService();

  GameProvider({AuthProvider? authProvider}) : _authProvider = authProvider {
    _gameLogic = GameLogic(onStateChanged: () => notifyListeners());
  }

  // Expose game state
  int get currentScore => _gameLogic.currentScore;
  int get highScore => _gameLogic.highScore;
  double get timeRemaining => _gameLogic.timeRemaining;
  GameState get gameState => _gameLogic.gameState;
  bool get showOnboarding => _gameLogic.showOnboarding;
  String? get userId => _authProvider?.user?.uid;

  // Expose game actions
  void startGame() => _gameLogic.startGame();
  void incrementScore() => _gameLogic.incrementScore();
  void bankScore() {
    final uid = _authProvider?.user?.uid;
    if (uid != null) {
      _leaderboardService.addScore(uid, _gameLogic.currentScore);
    }
    _gameLogic.bankScore();
  }

  @override
  void dispose() {
    _gameLogic.dispose();
    super.dispose();
  }
}
