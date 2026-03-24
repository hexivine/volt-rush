import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volt_rush/providers/game_logic.dart';
import 'package:volt_rush/providers/game_provider.dart';
import 'package:volt_rush/providers/auth_provider.dart';
import 'package:volt_rush/providers/leaderboard_provider.dart';
import 'package:volt_rush/services/leaderboard_service.dart';
import 'package:volt_rush/theme.dart';
import 'package:volt_rush/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock Providers
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  get user => null;
}

class MockLeaderboardProvider extends ChangeNotifier implements LeaderboardProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockLeaderboardService implements LeaderboardService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Home screen displays high score and max combo', (WidgetTester tester) async {
    // Mock shared preferences
    SharedPreferences.setMockInitialValues({'highScore': 100, 'maxCombo': 10});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
          ChangeNotifierProvider<GameProvider>(
            create: (_) => GameProvider(leaderboardService: MockLeaderboardService()),
          ),
          ChangeNotifierProvider<LeaderboardProvider>(create: (_) => MockLeaderboardProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify initial values from mock
    expect(find.text('High Score'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Max Combo: 10'), findsOneWidget);
  });
}
