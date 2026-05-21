import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

class BustScreen extends StatelessWidget {
  const BustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bust!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              'You scored ${game.currentScore} points',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => game.startGame(),
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 20),
            Text(
              'High Score: ${game.highScore}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
