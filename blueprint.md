# Blueprint: The Last Tap Game

## Overview

This document outlines the plan and progress for creating "The Last Tap," a single-button risk game for Flutter. The goal is to build a fast-paced, addictive game based on a risk-vs-reward mechanic.

## Core MVP Features

- **Main Gameplay Screen:** A central "TAP" button, score display, and a visual timer.
- **Game Loop:** Tapping increases the score but shortens the time for the next tap.
- **Game States:** Clear states for Idle, Active, Banked (win), and Busted (lose).
- **High Score:** Locally persistent high score.
- **Feedback:** Sound effects, haptic feedback, and visual cues for different game events.

## Current Plan

1.  **Project Setup:**
    *   Add necessary dependencies to `pubspec.yaml`:
        *   `provider` for state management.
        *   `shared_preferences` for local high score.
        *   `audioplayers` for sound effects.
        *   `vibration` for haptic feedback.
        *   `confetti` for win animations.
        *   `google_fonts` for custom typography.

2.  **Initial Code Structure:**
    *   Replace the default counter app with the basic game structure in `lib/main.dart`.
    *   Set up a `GameProvider` to manage the game's state (score, timer, game status).
    *   Create the main `GameScreen` widget that will contain the UI.

3.  **Implement Core UI:**
    *   Add the "Best" and "Now" score displays.
    *   Create the large central "TAP" button.
    *   Add the "STOP" button (initially hidden).
    *   Design the circular timer ring around the tap button.

4.  **Implement Game Logic:**
    *   Start the timer on the first tap.
    *   Increment the score with each tap.
    *   Decrease the timer duration with each tap.
    *   Handle the "Bust" state when the timer runs out.
    *   Handle the "Bank" state when the user presses "STOP".
    *   Implement the high score saving and loading.
