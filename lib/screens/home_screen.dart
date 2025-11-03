import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/screens/leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final String shareText =
        'I just got a new high score of ${game.highScore} in Bust-a-Move! Can you beat it?';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'High Score',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '${game.highScore}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => game.startGame(),
              child: const Text('Play'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen()),
                    );
                  },
                  icon: const Icon(Icons.leaderboard, color: Colors.white),
                  tooltip: 'Leaderboard',
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement settings screen
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                  tooltip: 'Settings',
                ),
                IconButton(
                  onPressed: () {
                    Share.share(shareText);
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Share High Score',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
