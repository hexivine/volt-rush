import 'package:flutter/material.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volt_rush/firebase_options.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:volt_rush/providers/leaderboard_provider.dart';
import 'package:volt_rush/screens/home_screen.dart';
import 'package:volt_rush/screens/game_screen.dart';
import 'package:volt_rush/screens/banked_screen.dart';
import 'package:volt_rush/screens/bust_screen.dart';
import 'package:volt_rush/screens/onboarding_screen.dart';

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
          create: (_) => GameProvider(),
          update: (_, auth, game) => GameProvider(authProvider: auth),
        ),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'Volt Rush',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          textTheme: GoogleFonts.pressStart2pTextTheme(
            Theme.of(context).textTheme,
          ).copyWith(
            bodyLarge: const TextStyle(color: Colors.white),
            bodyMedium: const TextStyle(color: Colors.white),
            displayLarge: const TextStyle(color: Colors.white),
            displayMedium: const TextStyle(color: Colors.white),
            displaySmall: const TextStyle(color: Colors.white),
            headlineMedium: const TextStyle(color: Colors.white),
            headlineSmall: const TextStyle(color: Colors.white),
            titleLarge: const TextStyle(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              textStyle: GoogleFonts.pressStart2pTextTheme().labelLarge,
            ),
          ),
        ),
        home: Consumer<GameProvider>(
          builder: (context, game, child) {
            if (game.showOnboarding) {
              return const OnboardingScreen();
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
      ),
    );
  }
}
