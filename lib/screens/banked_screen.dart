import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/widgets/custom_button.dart';

class BankedScreen extends StatelessWidget {
  const BankedScreen({super.key});

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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You Banked It!',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.greenAccent, shadows: [
                      Shadow(
                        blurRadius: 20.0,
                        color: Colors.greenAccent,
                        offset: Offset(0, 0),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Final Score: ${game.currentScore}',
                    style: const TextStyle(fontSize: 24, color: Colors.white70),
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'Play Again',
                    onPressed: () {
                      game.resetGame();
                      game.tap();
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
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: game.confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
