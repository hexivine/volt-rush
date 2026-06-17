import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reward system for daily streaks, achievements, and bonus multipliers.
/// Handles streak tracking, reward claiming, and achievement unlocking.
class RewardSystem {
  static const Map<int, double> streakMultipliers = {
    3: 1.5,
    7: 2.0,
    14: 2.5,
    30: 3.0,
    60: 4.0,
    100: 5.0,
  };

  static const List<Map<String, dynamic>> achievements = [
    {'id': 'first_game', 'name': 'First Steps', 'description': 'Complete your first game', 'xp': 50},
    {'id': 'score_100', 'name': 'Century', 'description': 'Score 100 points in a single game', 'xp': 100},
    {'id': 'score_500', 'name': 'High Roller', 'description': 'Score 500 points in a single game', 'xp': 250},
    {'id': 'streak_7', 'name': 'Week Warrior', 'description': 'Maintain a 7-day streak', 'xp': 200},
    {'id': 'streak_30', 'name': 'Monthly Master', 'description': 'Maintain a 30-day streak', 'xp': 500},
    {'id': 'games_50', 'name': 'Dedicated', 'description': 'Play 50 games', 'xp': 300},
    {'id': 'no_bust_5', 'name': 'Safe Player', 'description': 'Complete 5 games without busting', 'xp': 150},
  ];

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check and update daily streak for user
  Future<Map<String, dynamic>> checkDailyStreak(String userId) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'streak': 1,
        'lastPlayDate': DateTime.now().toIso8601String(),
        'longestStreak': 1,
      });
      return {'streak': 1, 'multiplier': 1.0, 'streakBroken': false};
    }

    final data = userDoc.data()!;
    final lastPlayStr = data['lastPlayDate'] as String?;
    final currentStreak = (data['streak'] ?? 0) as int;

    if (lastPlayStr == null) {
      await userRef.update({'streak': 1, 'lastPlayDate': DateTime.now().toIso8601String()});
      return {'streak': 1, 'multiplier': 1.0, 'streakBroken': false};
    }

    final lastPlay = DateTime.parse(lastPlayStr);
    final now = DateTime.now();
    final daysDiff = now.difference(lastPlay).inDays;

    if (daysDiff == 0) {
      // Same day - no streak change
      return {'streak': currentStreak, 'multiplier': _getMultiplier(currentStreak), 'streakBroken': false};
    } else if (daysDiff == 1) {
      // Consecutive day - increment streak
      final newStreak = currentStreak + 1;
      final longestStreak = (data['longestStreak'] ?? 0) as int;
      
      await userRef.update({
        'streak': newStreak,
        'lastPlayDate': now.toIso8601String(),
        'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
      });

      return {'streak': newStreak, 'multiplier': _getMultiplier(newStreak), 'streakBroken': false};
    } else {
      // Streak broken
      await userRef.update({
        'streak': 1,
        'lastPlayDate': now.toIso8601String(),
      });
      return {'streak': 1, 'multiplier': 1.0, 'streakBroken': true, 'previousStreak': currentStreak};
    }
  }

  /// Check if any new achievements were unlocked
  Future<List<Map<String, dynamic>>> checkAchievements(String userId, {
    required int score,
    required int totalGames,
    required int streak,
    required int consecutiveNoBust,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final unlockedIds = List<String>.from(userDoc.data()?['unlockedAchievements'] ?? []);
    
    final newlyUnlocked = <Map<String, dynamic>>[];

    for (final achievement in achievements) {
      if (unlockedIds.contains(achievement['id'])) continue;

      bool unlocked = false;
      switch (achievement['id']) {
        case 'first_game':
          unlocked = totalGames >= 1;
          break;
        case 'score_100':
          unlocked = score >= 100;
          break;
        case 'score_500':
          unlocked = score >= 500;
          break;
        case 'streak_7':
          unlocked = streak >= 7;
          break;
        case 'streak_30':
          unlocked = streak >= 30;
          break;
        case 'games_50':
          unlocked = totalGames >= 50;
          break;
        case 'no_bust_5':
          unlocked = consecutiveNoBust >= 5;
          break;
      }

      if (unlocked) {
        newlyUnlocked.add(achievement);
        unlockedIds.add(achievement['id'] as String);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      // Calculate total XP earned
      final xpEarned = newlyUnlocked.fold<int>(0, (sum, a) => sum + (a['xp'] as int));
      
      await userRef.update({
        'unlockedAchievements': unlockedIds,
        'xp': FieldValue.increment(xpEarned),
      });

      // Store achievement unlock events
      for (final achievement in newlyUnlocked) {
        await _db.collection('achievement_events').add({
          'userId': userId,
          'achievementId': achievement['id'],
          'unlockedAt': DateTime.now().toIso8601String(),
          'xpAwarded': achievement['xp'],
        });
      }
    }

    return newlyUnlocked;
  }

  /// Claim daily reward
  Future<Map<String, dynamic>> claimDailyReward(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString('last_daily_claim_$userId');
    
    if (lastClaim != null) {
      final lastClaimDate = DateTime.parse(lastClaim);
      if (DateTime.now().difference(lastClaimDate).inHours < 24) {
        return {'claimed': false, 'reason': 'Already claimed today', 'nextClaimIn': 24 - DateTime.now().difference(lastClaimDate).inHours};
      }
    }

    final streakData = await checkDailyStreak(userId);
    final multiplier = streakData['multiplier'] as double;
    final baseReward = 10;
    final reward = (baseReward * multiplier).round();

    // Award credits
    await _db.collection('users').doc(userId).update({
      'credits': FieldValue.increment(reward),
    });

    await prefs.setString('last_daily_claim_$userId', DateTime.now().toIso8601String());

    return {
      'claimed': true,
      'reward': reward,
      'multiplier': multiplier,
      'streak': streakData['streak'],
    };
  }

  double _getMultiplier(int streak) {
    double multiplier = 1.0;
    for (final entry in streakMultipliers.entries) {
      if (streak >= entry.key) {
        multiplier = entry.value;
      }
    }
    return multiplier;
  }
}
