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

### 4. Component Theming
*   Leverage `ThemeData` to define:
    *   `ColorScheme` using `ColorScheme.fromSeed`.
    *   `TextTheme` using `GoogleFonts`.
    *   `AppBarTheme` for consistent app bar styling.
    *   `ElevatedButtonTheme` for consistent button styling.

### 5. Implementation Steps

#### Step 5.1: Update `pubspec.yaml` (Verification)
*   Ensure `google_fonts` and `provider` packages are present. (Already verified in previous steps).

#### Step 5.2: Refactor `lib/theme.dart`
*   Create a `ThemeProvider` class extending `ChangeNotifier` to manage `ThemeMode` (light/dark/system).
*   Define `lightTheme` and `darkTheme` `ThemeData` objects.
*   Implement `ColorScheme.fromSeed` with a chosen seed color (e.g., `Colors.deepPurple`).
*   Define `TextTheme` using `GoogleFonts` for `displayLarge`, `titleLarge`, `bodyMedium`, etc.
*   Customize `AppBarTheme` (background, foreground, title text style).
*   Customize `ElevatedButtonTheme` (colors, shape, padding, text style).

#### Step 5.3: Integrate `ThemeProvider` into `main.dart`
*   Wrap the `MyApp` widget with `ChangeNotifierProvider<ThemeProvider>`.
*   Use `Consumer<ThemeProvider>` in `MyApp`'s `build` method to apply the selected `themeMode`.

#### Step 5.4: Apply Theming to `MyHomePage` (and other relevant screens)
*   Modify existing widgets in `MyHomePage` (and other screens as needed) to use `Theme.of(context).textTheme` and other theme properties.

#### Step 5.5: Implement a Theme Toggle
*   Add `IconButton` widgets to the `AppBar` in `MyHomePage` to allow users to toggle between light/dark modes and set the system theme.

#### Step 5.6: Run `flutter pub get`
*   After modifying `lib/theme.dart` and `main.dart`, run `flutter pub get` to ensure all dependencies are correctly fetched.

#### Step 5.7: Build and Verify
*   Build and run the application to verify the new UI design and theme toggling functionality.

### 6. Future Enhancements (Beyond current scope)
*   Custom animated backgrounds.
*   Particle effects on interactions.
*   More complex custom widget styling.