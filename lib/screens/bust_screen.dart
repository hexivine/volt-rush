import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/widgets/custom_button.dart';

class BustScreen extends StatelessWidget {
  const BustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF2E2E50),
              Color(0xFF1A1A2E),
            ],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Busted!',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.redAccent, shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.redAccent,
                    offset: Offset(0, 0),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              Text(
                'You scored: ${game.currentScore}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              CustomButton(
                text: 'Play Again',
                onPressed: () {
                  game.setupGame();
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Main Menu',
                onPressed: game.resetGame,
                color: Colors.grey[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
