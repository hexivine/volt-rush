import 'dart:async';
import 'package:flutter/material.dart';

/// Animated countdown timer widget with pulse effect when time is low.
class CountdownTimer extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onComplete;
  final int warningThreshold;

  const CountdownTimer({
    super.key,
    required this.durationSeconds,
    required this.onComplete,
    this.warningThreshold = 5,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remaining--;
      });

      if (_remaining <= widget.warningThreshold && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }

      if (_remaining <= 0) {
        timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = _remaining <= widget.warningThreshold;
    final color = isWarning ? Colors.red : Colors.white;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isWarning ? 1.0 + (_pulseController.value * 0.15) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Text(
            _formatTime(_remaining),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
