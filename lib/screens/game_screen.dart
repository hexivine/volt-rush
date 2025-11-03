import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => game.incrementScore(),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${game.currentScore}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => game.bankScore(),
                    child: const Text('Bank'),
                  ),
                  Text(
                    'Time: ${game.timeRemaining.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
