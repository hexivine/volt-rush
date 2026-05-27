import 'package:flutter/material.dart';
import '../services/achievement_service.dart';

/// Achievements Screen — DELIBERATELY has violations for testing
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // SHOULD TRIGGER: no-service-in-state (direct instantiation)
final _achievementService = AchievementService.getInstance();

  List<Map<String, dynamic>> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  // BUG: No error handling (expert_rules should catch)
  // BUG: No dispose of any subscriptions
  Future<void> _loadAchievements() async {
    final achievements = await _achievementService.syncWithServer('user123');
    setState(() {
      _loading = false;
    });
    print('Loaded achievements'); // SHOULD TRIGGER: no-print-statements
  }

  // SECURITY: SQL-injection-like pattern (concatenating user input)
  Future<void> _searchAchievements(String query) async {
    // BUG: No input validation/sanitization
final results = _achievements.where((a) =>
      a['name'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();

    // BUG: Potential null pointer — _achievements could be empty
    final firstResult = results.first; // Will throw if empty

    print('Found ${results.length} results for: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return ListTile(
                  title: Text(achievement['name']! as String), // Force unwrap
                  subtitle: Text(achievement['description'] as String),
                  trailing: achievement['claimed'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: () => _claimAchievement(achievement['id']),
                          child: const Text('Claim'),
                        ),
                );
              },
            ),
    );
  }

  // BUG: No error handling, no loading state management
  Future<void> _claimAchievement(String id) async {
    await _achievementService.unlockAchievement('user123', id);
    _loadAchievements(); // No await — fire and forget without error handling
  }
}
