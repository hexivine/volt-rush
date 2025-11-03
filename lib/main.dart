import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/game_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/game_screen.dart';
import 'package:myapp/screens/bust_screen.dart';
import 'package:myapp/screens/banked_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Bust-a-Move',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.pressStart2pTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: Consumer<GameProvider>(
          builder: (context, game, child) {
            switch (game.gameState) {
              case GameState.playing:
                return const GameScreen();
              case GameState.busted:
                return const BustScreen();
              case GameState.banked:
                return const BankedScreen();
              case GameState.idle:
              default:
                return const HomeScreen();
            }
          },
        ),
      ),
    );
  }
}
