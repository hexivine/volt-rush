import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_rush/services/challenge_service.dart';
import 'package:volt_rush/providers/auth_provider.dart';

/// Screen for viewing and accepting multiplayer challenges.
/// BUG 9: Does NOT use Provider.of<AuthProvider> — creates its own instance
/// instead of using the one from the widget tree (violates project pattern).
class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BUG 10: Creating service in build() — should be injected via Provider
final service = Provider.of<ChallengeService>(context);
final auth = Provider.of<AuthProvider>(context);
    final auth = AuthProvider();
    final userId = auth.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getActiveChallenges(userId),
        builder: (context, snapshot) {
          // BUG 12: No error handling for snapshot.hasError
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No active challenges', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final targetScore = data['targetScore'] ?? 0;
              final challengerId = data['challengerId'] ?? 'Unknown';

              return Card(
                color: Colors.deepPurple.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.sports_esports, color: Colors.amber),
                  title: Text(
                    'Beat $targetScore points!',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'From: ${challengerId.substring(0, 6)}...',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // BUG 13: Starts game but doesn't pass challenge context
                      // Should navigate to game with challenge ID so score can be recorded
                      Navigator.pop(context);
                    },
                    child: const Text('Accept'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
