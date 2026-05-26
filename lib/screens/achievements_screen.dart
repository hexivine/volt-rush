import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:volt_rush/services/achievement_service.dart';

/// Screen displaying the player's unlocked achievements.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const Map<String, Map<String, String>> achievementMeta = {
    'first_10': {'title': 'Getting Started', 'desc': 'Score 10 points in a single game'},
    'half_century': {'title': 'Half Century', 'desc': 'Score 50 points in a single game'},
    'century': {'title': 'Century!', 'desc': 'Score 100 points in a single game'},
    'legendary': {'title': 'Legendary', 'desc': 'Reach a high score of 200'},
  };

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.user?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: const Center(child: Text('Please sign in to view achievements')),
      );
    }

    final service = AchievementService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getAchievements(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final unlockedIds = snapshot.data?.docs.map((d) => d.id).toSet() ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: achievementMeta.entries.map((entry) {
              final isUnlocked = unlockedIds.contains(entry.key);
              return Card(
                color: isUnlocked ? Colors.deepPurple.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                child: ListTile(
                  leading: Icon(
                    isUnlocked ? Icons.emoji_events : Icons.lock_outline,
                    color: isUnlocked ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  title: Text(
                    entry.value['title']!,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    entry.value['desc']!,
                    style: TextStyle(color: isUnlocked ? Colors.white70 : Colors.grey[600]),
                  ),
                  trailing: isUnlocked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
