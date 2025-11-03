import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'dart:math' as math;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onTap: game.tap,
        child: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.isGameActive)
                Text(
                  'Score: ${game.currentScore}',
                  style: const TextStyle(fontSize: 24, color: Colors.white70),
                )
              else
                const Column(
                  children: [
                    Text(
                      'Tap to Score', 
                      style: TextStyle(fontSize: 24, color: Colors.white70)
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Keep tapping to increase your score.',
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bank your score before the timer runs out!',
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                height: 250,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + _animationController.value * 0.1,
                      child: CustomPaint(
                        painter: TimerPainter(
                          progress: game.isGameActive ? game.timerValue : 1.0,
                        ),
                        child: Center(
                          child: Text(
                            game.isGameActive ? game.currentScore.toString() : "Start",
                            style: TextStyle(
                              fontSize: game.isGameActive ? 60 : 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 20.0,
                                  color: Colors.cyanAccent,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),
              if (game.isGameActive)
                CustomButton(
                  text: 'Bank Score',
                  onPressed: game.bankScore,
                )
              else
                const SizedBox(height: 68), // To keep the layout consistent
            ],
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;

  TimerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint progressPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..shader = const LinearGradient(
        colors: [Colors.cyanAccent, Colors.pinkAccent],
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2));

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
