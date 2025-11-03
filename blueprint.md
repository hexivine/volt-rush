# Blueprint: Bust-a-Move

## Overview

This document outlines the architecture, design, and features of "Bust-a-Move," a fast-paced, score-chasing mobile game. The application is built with Flutter and leverages Firebase for backend services, including authentication and a real-time leaderboard.

## Style and Design

The game embraces a retro arcade aesthetic to create a nostalgic and engaging user experience.

*   **Theme:** Dark mode is central to the design, with a primary background color of `#1A1A1A`.
*   **Typography:** The `Press Start 2P` font, sourced from Google Fonts, is used throughout the app to reinforce the classic video game feel.
*   **Color Scheme:** The UI uses a simple, high-contrast color palette. Key actions are highlighted with a vibrant red, ensuring they stand out against the dark background.
*   **Layout:** All screens feature clean, centered, and intuitive layouts, prioritizing ease of use and clarity.

## Features & Implementation

### Core Gameplay Mechanics

*   **Scoring:** Players tap a button to increment their score during a time-limited round.
*   **Banking:** Players can "Bank" their score at any point, which finalizes the score for the round and submits it to the leaderboard.
*   **Busting:** A countdown timer adds pressure. If the timer expires before the player banks, they "Bust," and the score for that round is lost.
*   **High Score:** The player's personal best score is saved locally on their device.

### Application Architecture

The app is built on a modular architecture that separates UI, state management, and business logic.

*   **State Management:** The `provider` package is used for state management.
    *   `GameProvider`: Manages the overall game state (`home`, `playing`, `banked`, `bust`) and user interactions.
    *   `GameLogic`: A separate class that encapsulates the core rules, scoring, and timer mechanics, keeping the game's business logic independent from the UI.
    *   `AuthProvider`: Handles user authentication via Firebase.
    *   `LeaderboardProvider`: Manages the state and data flow for the leaderboard.
*   **Services:**
    *   `LeaderboardService`: A dedicated service to handle all interactions with the Firestore database, abstracting the data layer from the rest of the application.

### Screens

*   `OnboardingScreen`: A welcome screen shown to users on their first launch.
*   `HomeScreen`: The main menu, which displays the local high score and provides buttons to play the game, view the leaderboard, and share high scores.
*   `GameScreen`: The active gameplay interface where players interact with the game.
*   `BankedScreen`: A confirmation screen displayed after a player successfully banks their score.
*   `BustScreen`: The screen shown when a player runs out of time and "busts."
*   `LeaderboardScreen`: Displays the top 10 scores in real-time, fetched from Firestore.

### Firebase Integration

*   **Authentication:** The app uses `firebase_auth` to silently and anonymously sign in users, providing a stable user ID for tracking scores without requiring a manual login process.
*   **Real-time Leaderboard:** `cloud_firestore` is used to store and retrieve leaderboard data. The `LeaderboardScreen` listens to a live stream of the top 10 scores, ensuring the data is always up-to-date.

### Local Persistence

*   `shared_preferences` is used to persist the user's local high score and to track whether they have completed the initial onboarding.

### Social Sharing

*   The `share_plus` package is integrated into the `HomeScreen`, allowing players to share a pre-composed message with their high score through the native device sharing dialog.

## Final Status

The project is now feature-complete. It includes a full gameplay loop, user authentication, a real-time online leaderboard, and social sharing capabilities. The code has been refactored for clarity, scalability, and maintainability, with a clear separation between UI, state, and logic. This blueprint reflects the final state of the application.
