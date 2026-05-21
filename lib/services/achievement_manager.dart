import 'package:flutter/material.dart';

/// Achievement system for tracking player milestones.
/// Manages unlocking, persistence, and display of achievements.
class AchievementManager {
  final List<Achievement> _achievements = [];
  final Map<String, bool> _unlocked = {};
  final List<VoidCallback> _listeners = [];

  /// Register a listener for achievement unlock events.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a previously registered listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Check and unlock the first_game achievement.
  bool checkFirstGame(Map<String, dynamic> stats) {
    if (_unlocked['first_game'] == true) return false;
    if ((stats['gamesPlayed'] ?? 0) >= 1) {
      _unlock('first_game', 'First Game', 'Play your first game');
      return true;
    }
    return false;
  }

  /// Check and unlock the score_100 achievement.
  bool checkScore100(Map<String, dynamic> stats) {
    if (_unlocked['score_100'] == true) return false;
    if ((stats['score'] ?? 0) >= 100) {
      _unlock('score_100', 'Century', 'Score 100 points in a single game');
      return true;
    }
    return false;
  }

  /// Check and unlock the score_500 achievement.
  bool checkScore500(Map<String, dynamic> stats) {
    if (_unlocked['score_500'] == true) return false;
    if ((stats['score'] ?? 0) >= 500) {
      _unlock('score_500', 'High Roller', 'Score 500 points in a single game');
      return true;
    }
    return false;
  }

  /// Check and unlock the score_1000 achievement.
  bool checkScore1000(Map<String, dynamic> stats) {
    if (_unlocked['score_1000'] == true) return false;
    if ((stats['score'] ?? 0) >= 1000) {
      _unlock('score_1000', 'Thousand Club', 'Score 1000 points in a single game');
      return true;
    }
    return false;
  }

  /// Check and unlock the score_5000 achievement.
  bool checkScore5000(Map<String, dynamic> stats) {
    if (_unlocked['score_5000'] == true) return false;
    if ((stats['score'] ?? 0) >= 5000) {
      _unlock('score_5000', 'Legend', 'Score 5000 points in a single game');
      return true;
    }
    return false;
  }

  /// Check and unlock the streak_3 achievement.
  bool checkStreak3(Map<String, dynamic> stats) {
    if (_unlocked['streak_3'] == true) return false;
    if ((stats['streak'] ?? 0) >= 3) {
      _unlock('streak_3', 'Hat Trick', 'Win 3 games in a row');
      return true;
    }
    return false;
  }

  /// Check and unlock the streak_5 achievement.
  bool checkStreak5(Map<String, dynamic> stats) {
    if (_unlocked['streak_5'] == true) return false;
    if ((stats['streak'] ?? 0) >= 5) {
      _unlock('streak_5', 'On Fire', 'Win 5 games in a row');
      return true;
    }
    return false;
  }

  /// Check and unlock the streak_10 achievement.
  bool checkStreak10(Map<String, dynamic> stats) {
    if (_unlocked['streak_10'] == true) return false;
    if ((stats['streak'] ?? 0) >= 10) {
      _unlock('streak_10', 'Unstoppable', 'Win 10 games in a row');
      return true;
    }
    return false;
  }

  /// Check and unlock the games_10 achievement.
  bool checkGames10(Map<String, dynamic> stats) {
    if (_unlocked['games_10'] == true) return false;
    if ((stats['gamesPlayed'] ?? 0) >= 10) {
      _unlock('games_10', 'Getting Started', 'Play 10 games');
      return true;
    }
    return false;
  }

  /// Check and unlock the games_50 achievement.
  bool checkGames50(Map<String, dynamic> stats) {
    if (_unlocked['games_50'] == true) return false;
    if ((stats['gamesPlayed'] ?? 0) >= 50) {
      _unlock('games_50', 'Dedicated', 'Play 50 games');
      return true;
    }
    return false;
  }

  /// Check and unlock the games_100 achievement.
  bool checkGames100(Map<String, dynamic> stats) {
    if (_unlocked['games_100'] == true) return false;
    if ((stats['gamesPlayed'] ?? 0) >= 100) {
      _unlock('games_100', 'Veteran', 'Play 100 games');
      return true;
    }
    return false;
  }

  /// Check and unlock the perfect_round achievement.
  bool checkPerfectRound(Map<String, dynamic> stats) {
    if (_unlocked['perfect_round'] == true) return false;
    if (stats['perfectRound'] == true) {
      _unlock('perfect_round', 'Perfect Round', 'Complete a round without any mistakes');
      return true;
    }
    return false;
  }

  /// Check and unlock the speed_demon achievement.
  bool checkSpeedDemon(Map<String, dynamic> stats) {
    if (_unlocked['speed_demon'] == true) return false;
    final avgTime = stats['avgResponseTime'] ?? double.infinity;
    if (avgTime <= 0.5) {
      _unlock('speed_demon', 'Speed Demon', 'Average response time under 0.5 seconds');
      return true;
    }
    return false;
  }

  /// Check and unlock the comeback_king achievement.
  bool checkComebackKing(Map<String, dynamic> stats) {
    if (_unlocked['comeback_king'] == true) return false;
    if (stats['comebackWin'] == true) {
      _unlock('comeback_king', 'Comeback King', 'Win after being down by 50+ points');
      return true;
    }
    return false;
  }

  /// Check all achievements against current stats.
  /// Returns a list of newly unlocked achievement IDs.
  List<String> checkAll(Map<String, dynamic> stats) {
    final newlyUnlocked = <String>[];

    if (checkFirstGame(stats)) newlyUnlocked.add('first_game');
    if (checkScore100(stats)) newlyUnlocked.add('score_100');
    if (checkScore500(stats)) newlyUnlocked.add('score_500');
    if (checkScore1000(stats)) newlyUnlocked.add('score_1000');
    if (checkScore5000(stats)) newlyUnlocked.add('score_5000');
    if (checkStreak3(stats)) newlyUnlocked.add('streak_3');
    if (checkStreak5(stats)) newlyUnlocked.add('streak_5');
    if (checkStreak10(stats)) newlyUnlocked.add('streak_10');
    if (checkGames10(stats)) newlyUnlocked.add('games_10');
    if (checkGames50(stats)) newlyUnlocked.add('games_50');
    if (checkGames100(stats)) newlyUnlocked.add('games_100');
    if (checkPerfectRound(stats)) newlyUnlocked.add('perfect_round');
    if (checkSpeedDemon(stats)) newlyUnlocked.add('speed_demon');
    if (checkComebackKing(stats)) newlyUnlocked.add('comeback_king');

    if (newlyUnlocked.isNotEmpty) {
      _notifyListeners();
    }

    return newlyUnlocked;
  }

  void _unlock(String id, String name, String description) {
    _unlocked[id] = true;
    _achievements.add(Achievement(
      id: id,
      name: name,
      description: description,
      unlockedAt: DateTime.now(),
    ));
  }

  /// Get all unlocked achievements.
  List<Achievement> get all => List.unmodifiable(_achievements);

  /// Get the count of unlocked achievements.
  int get unlockedCount => _unlocked.values.where((v) => v).length;

  /// Get the total number of available achievements.
  int get totalCount => 14;

  /// Get completion percentage.
  double get completionPercent => (unlockedCount / totalCount) * 100;

  /// Check if a specific achievement is unlocked.
  bool isUnlocked(String id) => _unlocked[id] == true;

  /// Reset all achievements (for testing or new game+).
  void reset() {
    _achievements.clear();
    _unlocked.clear();
    _notifyListeners();
  }
}

/// Represents a single achievement.
class Achievement {
  final String id;
  final String name;
  final String description;
  final DateTime unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockedAt,
  });

  @override
  String toString() => 'Achievement($id: $name)';
}
