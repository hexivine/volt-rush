import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Volt Rush!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Tap the screen to increase your score. Bank your score before the timer runs out!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Provider.of<GameProvider>(context, listen: false).startGame(),
              child: const Text('Let\'s Go!'),
            ),
          ],
        ),
      ),
    );
  }
}
