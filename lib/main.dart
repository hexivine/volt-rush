import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/providers/animation_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/game_screen.dart';
import 'package:myapp/screens/banked_screen.dart';
import 'package:myapp/screens/bust_screen.dart';
import 'package:myapp/screens/onboarding_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/share_screen.dart';
import 'package:myapp/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimationProvider()),
        ChangeNotifierProxyProvider<AnimationProvider, GameProvider>(
          create: (context) => GameProvider(Provider.of<AnimationProvider>(context, listen: false)),
          update: (context, animationProvider, gameProvider) => GameProvider(animationProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Bust-a-Move',
        theme: AppTheme.theme,
        home: const GameController(),
      ),
    );
  }
}

class GameController extends StatefulWidget {
  const GameController({super.key});

  @override
  State<GameController> createState() => _GameControllerState();
}

class _GameControllerState extends State<GameController> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<AnimationProvider>(context, listen: false).initialize(this);
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final animation = Provider.of<AnimationProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          const NoiseTexture(),
          AnimatedBuilder(
            animation: animation.shakeController,
            builder: (context, child) {
              final sineValue = sin(4 * pi * animation.shakeController.value);
              return Transform.translate(
                offset: Offset(sineValue * 20, 0),
                child: child,
              );
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildScreen(game.gameState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(GameState gameState) {
    switch (gameState) {
      case GameState.onboarding:
        return const OnboardingScreen(key: ValueKey('onboarding'));
      case GameState.settings:
        return const SettingsScreen(key: ValueKey('settings'));
      case GameState.share:
        return const ShareScreen(key: ValueKey('share'));
      case GameState.playing:
        return const GameScreen(key: ValueKey('game'));
      case GameState.banked:
        return const BankedScreen(key: ValueKey('banked'));
      case GameState.busted:
        return const BustScreen(key: ValueKey('busted'));
      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }
}

class NoiseTexture extends StatefulWidget {
  const NoiseTexture({super.key});

  @override
  State<NoiseTexture> createState() => _NoiseTextureState();
}

class _NoiseTextureState extends State<NoiseTexture> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NoisePainter(time: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class NoisePainter extends CustomPainter {
  final double time;

  NoisePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5000; i++) {
      paint.color = Colors.black.withOpacity(random.nextDouble() * 0.1);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
