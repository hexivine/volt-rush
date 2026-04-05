import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

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
                  if (game.multiplier > 1.0) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${game.multiplier}x Multiplier',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    'Combo: ${game.comboCount}/3',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
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
