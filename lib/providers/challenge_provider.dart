import 'package:flutter/material.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:volt_rush/services/daily_challenge_service.dart';

class ChallengeProvider with ChangeNotifier {
  final DailyChallengeService _service = DailyChallengeService();
  final AuthProvider? _authProvider;

  DailyChallenge? _challenge;
  bool _isLoading = false;
  String? _error;

  ChallengeProvider({AuthProvider? authProvider}) : _authProvider = authProvider;

  DailyChallenge? get challenge => _challenge;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get bonusPoints {
    if (_challenge == null) return 0;
    if (_challenge!.completed) return 0;
    return _challenge!.targetScore * _challenge!.bonusMultiplier;
  }

  Future<void> loadChallenge() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _challenge = await _service.fetchTodaysChallenge(_authProvider?.user?.uid ?? '');
    } catch (e) {
      _error = e.toString();
      _challenge = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitScore(int score) async {
    final uid = _authProvider?.user?.uid;
    if (uid == null) return;

    if (score < _challenge!.targetScore) return;

    if (_challenge!.completed) return;

    await _service.completeChallenge(_challenge!.id, score);
    notifyListeners();
  }
}
