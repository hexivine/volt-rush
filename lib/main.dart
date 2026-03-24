import 'package:flutter/material.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volt_rush/firebase_options.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:volt_rush/providers/leaderboard_provider.dart';
import 'package:volt_rush/screens/home_screen.dart';
import 'package:volt_rush/screens/game_screen.dart';
import 'package:volt_rush/screens/banked_screen.dart';
import 'package:volt_rush/screens/bust_screen.dart';
import 'package:volt_rush/theme.dart'; // Import the new theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, GameProvider>(
          create: (_) => GameProvider(leaderboardService: LeaderboardService()),
          update: (_, auth, game) => GameProvider(authProvider: auth, leaderboardService: LeaderboardService()),
        ),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add ThemeProvider
      ],
      child: Consumer<ThemeProvider>( // Wrap MaterialApp with Consumer
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Volt Rush',
            theme: AppTheme.lightTheme, // Use lightTheme from AppTheme
            darkTheme: AppTheme.darkTheme, // Use darkTheme from AppTheme
            themeMode: themeProvider.themeMode, // Use themeMode from ThemeProvider
            home: Consumer<GameProvider>(
              builder: (context, game, child) {
                if (game.showOnboarding) {
                  return const HomeScreen();
                }
                switch (game.gameState) {
                  case GameState.home:
                    return const HomeScreen();
                  case GameState.playing:
                    return const GameScreen();
                  case GameState.banked:
                    return const BankedScreen();
                  case GameState.bust:
                    return const BustScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
