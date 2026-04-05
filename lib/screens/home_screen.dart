import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/screens/leaderboard_screen.dart';
import 'package:volt_rush/screens/settings_screen.dart';
import 'package:volt_rush/theme.dart'; // Import ThemeProvider

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider
    final String shareText =
        "I just got a new high score of ${game.highScore} in Volt Rush! Can you beat it?";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volt Rush'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
        ],
      ),
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
            if (game.comboCount > 0) ...[
              const SizedBox(height: 10),
              Text(
                '${game.multiplier}x Multiplier Active!',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
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
                  icon: const Icon(Icons.emoji_events, color: Colors.white),
                  tooltip: 'Leaderboard',
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                  tooltip: 'Settings',
                ),
                IconButton(
                  onPressed: () async {
                    await Share.share(shareText);
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
