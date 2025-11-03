import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.oswald(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => game.hideSettings(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reset High Score',
              style: GoogleFonts.oswald(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.resetHighScore();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('High score reset!'),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
