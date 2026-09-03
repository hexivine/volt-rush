import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_rush/providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  IconData _medalForRank(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events_outlined;
      case 3:
        return Icons.emoji_events_outlined;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  Color _medalColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return const Color(0xFFB0BEC5);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<LeaderboardProvider>(context).leaderboardStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No scores yet!'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              var score = data.containsKey('score') ? data['score'] : 0;
              var userId = data.containsKey('userId') ? data['userId'] : 'Anonymous';
              var rank = index + 1;

              return ListTile(
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (rank <= 3)
                      Positioned(
                        left: -6,
                        top: -14,
                        child: Icon(_medalForRank(rank), color: _medalColor(rank), size: 18),
                      ),
                    Text(
                      '$rank',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                title: Text(
                  'User: ${userId.substring(0, 6)}...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  score.toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}