import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';

class BankedScreen extends StatelessWidget {
  const BankedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Banked!',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'You scored ${game.currentScore} points!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => game.startGame(),
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
