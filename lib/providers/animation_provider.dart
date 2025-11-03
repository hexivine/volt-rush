import 'package:flutter/material.dart';

class AnimationProvider with ChangeNotifier {
  late AnimationController _shakeController;

  AnimationController get shakeController => _shakeController;

  void initialize(TickerProvider vsync) {
    _shakeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
  }

  void triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}
