import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

class BankedScreen extends StatelessWidget {
  const BankedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final isNewHighScore = game.currentScore >= game.highScore && game.currentScore > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Icon(
                  isNewHighScore ? Icons.emoji_events : Icons.check_circle,
                  color: isNewHighScore ? Colors.amber : Colors.green,
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Text(
                  'Banked!',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${game.currentScore} points',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (isNewHighScore) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'New High Score!',
                      style: TextStyle(
                        color: Colors.amber[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                  ],
                ),
              ),
            ],
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
