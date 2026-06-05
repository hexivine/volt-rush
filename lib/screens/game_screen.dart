import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_provider.dart';

class TapPopup {
  final String text;
  final Offset position;
  final Color color;

  TapPopup({required this.text, required this.position, required this.color});
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final List<TapPopup> _popups = [];
  int _lastScore = 0;

  void _onTap(Offset position, GameProvider game) {
    HapticFeedback.lightImpact();
    game.incrementScore();

    final diff = game.currentScore - _lastScore;
    _lastScore = game.currentScore;

    setState(() {
      _popups.add(TapPopup(
        text: diff > 1 ? '+$diff' : '+1',
        position: position,
        color: diff > 1 ? Colors.amber : Colors.white70,
      ));
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          if (_popups.isNotEmpty) _popups.removeAt(0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTapDown: (details) => _onTap(details.localPosition, game),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (game.multiplier > 1)
                    _ComboBadge(multiplier: game.multiplier),
                  if (game.multiplier > 1) const SizedBox(height: 8),
                  Text(
                    '${game.currentScore}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            // Floating score popups
            ..._popups.map((popup) => _FloatingText(
              text: popup.text,
              position: popup.position,
              color: popup.color,
            )),
            // Timer warning pulse
            if (game.timeRemaining <= 3 && game.timeRemaining > 0)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) => Opacity(
                    opacity: (sin(value * pi * 4) + 1) / 4 + 0.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${game.timeRemaining.toStringAsFixed(1)}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    'Time: ${game.timeRemaining.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.headlineSmall,
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

class _ComboBadge extends StatelessWidget {
  final int multiplier;

  const _ComboBadge({required this.multiplier});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: multiplier == 3 ? Colors.orange : Colors.amber,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (multiplier == 3 ? Colors.orange : Colors.amber).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            'x$multiplier COMBO!',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingText extends StatefulWidget {
  final String text;
  final Offset position;
  final Color color;

  const _FloatingText({required this.text, required this.position, required this.color});

  @override
  State<_FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<_FloatingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<double>(begin: 0.0, end: -60.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
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
      builder: (context, child) => Positioned(
        left: widget.position.dx - 20,
        top: widget.position.dy + _offset.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
