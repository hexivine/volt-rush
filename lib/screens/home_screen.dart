import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                'Bust-a-Move',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.cyanAccent,
                    offset: Offset(0, 0),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              Text(
                'High Score: ${game.highScore}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              CustomButton(
                text: 'Play',
                onPressed: () {
                  game.setupGame();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
