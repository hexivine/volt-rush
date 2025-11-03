// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/main.dart';
import 'package:volt_rush/providers/game_provider.dart';

void main() {
  testWidgets('Starts on home screen and can start game', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the game starts on the home screen.
    expect(find.text('High Score'), findsOneWidget);

    // Tap the play button and trigger a frame.
    await tester.tap(find.text('Play'));
    await tester.pump();

    // Verify that the game has started.
    final GameProvider gameProvider = tester.element(find.byType(MaterialApp)).findAncestorWidgetOfExactType<MultiProvider>().p.first as GameProvider;
    expect(gameProvider.gameState, GameState.playing);
  });
}
