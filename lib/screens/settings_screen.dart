import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

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
          onPressed: () => Navigator.of(context).pop(),
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
            SwitchListTile(
              title: Text('Sound Effects', style: GoogleFonts.oswald(fontSize: 18)),
              subtitle: const Text('Play sounds during gameplay'),
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
            ),
            SwitchListTile(
              title: Text('Haptic Feedback', style: GoogleFonts.oswald(fontSize: 18)),
              subtitle: const Text('Vibrate on crash and bank'),
              value: _hapticEnabled,
              onChanged: (v) => setState(() => _hapticEnabled = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.resetHighScore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('High score reset! Sound=$_soundEnabled Haptic=$_hapticEnabled'),
                  ),
                );
              },
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
