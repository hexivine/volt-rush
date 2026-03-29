# Volt Rush UI Redesign Blueprint

## Overview
This blueprint outlines the plan to redesign the UI of the "Volt Rush" application to achieve a futuristic, energetic, and visually attractive game-like aesthetic, adhering to Material Design principles where applicable.

## Project Outline (Current State)
The application currently has a basic Flutter UI. The existing `lib/theme.dart` and `lib/main.dart` will be modified to implement the new design.

## Plan for Current Request: Implement a Super Design

### 1. Aesthetic & Color Palette
*   **Aesthetic:** Futuristic, energetic, and vibrant.
*   **Primary Seed Color:** Electric blue or deep purple.
*   **Accent Colors:** Complementary neon accents (e.g., lime green, bright orange) for interactive elements and highlights.
*   **Backgrounds:** Dark backgrounds to make neon elements pop.

### 2. Typography
*   **Titles/Important Info:** Modern, bold, and slightly stylized fonts (e.g., Oswald, Roboto).
*   **Body Text:** Clean and readable font (e.g., Open Sans).
*   **Tool:** `google_fonts` package will be used.

### 3. Key UI Elements
*   **Buttons:** "Glow" effect on press, slightly rounded corners, clear iconography.
*   **Backgrounds:** Subtle animated gradients or geometric patterns evoking energy/speed (to be considered in a later iteration).
*   **Navigation:** Clear, icon-based navigation with subtle animations.
*   **Animations/Transitions:** Fast, smooth transitions between screens, subtle particle effects on key interactions (to be considered in a later iteration).
## Project Outline (Current State)
The application has been updated with a new Combo System and improved architecture using Dependency Injection.

## Plan for Current Request: Implement a Super Design (Updated with Combo System)

### 1. Aesthetic & Color Palette
...
### 5. Implementation Steps (Completed)

#### Step 5.1: Update `pubspec.yaml` (Verification)
*   Ensure `google_fonts` and `provider` packages are present.

#### Step 5.2: Refactor `lib/theme.dart`
*   Create a `ThemeProvider` class extending `ChangeNotifier`.
*   Define `lightTheme` and `darkTheme` `ThemeData` objects.

#### Step 5.3: Implement Combo System in `lib/providers/game_logic.dart`
*   Track `currentCombo`, `maxCombo`, and `lastTapTime`.
*   Increase score multiplier based on combo (e.g., `score += (combo ~/ 5) + 1`).
*   Persist `maxCombo` in `SharedPreferences`.

#### Step 5.4: Refactor `GameProvider` for Dependency Injection
*   Inject `LeaderboardService` into `GameProvider` constructor for better testability.
*   Expose `currentCombo` and `maxCombo` properties.

#### Step 5.5: UI Enhancements
*   Display `Max Combo` on `HomeScreen`.
*   Display `Combo xN` indicator in `GameScreen` when a combo is active.

#### Step 5.6: Test Robustness
*   Update `test/widget_test.dart` to mock `SharedPreferences`, `AuthProvider`, and `LeaderboardService`.
*   Ensure tests pass without needing a real Firebase environment.

#### Step 5.7: Run `flutter test` and `flutter analyze`
*   Verify that all tests pass and no critical analysis issues remain.

### 6. Future Enhancements (Beyond current scope)
...

*   Custom animated backgrounds.
*   Particle effects on interactions.
*   More complex custom widget styling.