import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';

class BustScreen extends StatelessWidget {
  const BustScreen({super.key});

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
              'Bust!',
              style: GoogleFonts.oswald(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You scored ${game.currentScore} points!',
              style: GoogleFonts.oswald(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => game.resetGame(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
