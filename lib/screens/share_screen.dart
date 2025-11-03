import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myapp/providers/game_provider.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Share',
          style: GoogleFonts.oswald(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => game.hideShare(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Share Your High Score!',
              style: GoogleFonts.oswald(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'High Score: ${game.highScore}',
              style: GoogleFonts.oswald(
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Share.share(
                    'I just got a high score of ${game.highScore} in Bust-a-Move! Can you beat it?');
              },
              child: const Text('Share High Score'),
            ),
          ],
        ),
      ),
    );
  }
}
