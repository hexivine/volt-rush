import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap(GameProvider game) {
    game.incrementScore();
    _pulseController.forward(from: 0.0);
  }

  Color _getTimeColor(double timeRemaining) {
    if (timeRemaining > 7.0) return Colors.green;
    if (timeRemaining > 4.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => _onTap(game),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Text(
                      '${game.currentScore}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
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
              bottom: 100,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (game.timeRemaining / 10.0).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTimeColor(game.timeRemaining),
                  ),
                ),
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
                    '${game.timeRemaining.toStringAsFixed(1)}s',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _getTimeColor(game.timeRemaining),
                    ),
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
