# 🎮 Super Game Hub — 40+ Flutter Arcade & Board Games

[![Flutter](https://img.shields.io/badge/Flutter-3.43%20Beta-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50)](#)
[![Linter](https://img.shields.io/badge/flutter%20analyze-100%25%20clean-brightgreen)](#)

> **Super Game Hub** is a modular, high-performance Flutter gaming ecosystem featuring **40+ built-in classic, arcade, board, and two-player party games** with real-time audio/haptic feedback, persistent offline leaderboards, and AdMob integration.

---

## 🕹️ Featured Game Collection

### ♟️ Strategy & Board Games
- **Chess & Checkers:** Interactive piece movements, valid capture calculations, and king-crowning mechanics.
- **Classic Ludo:** 4-player board engine with dice rolls and safe zones.
- **Connect Four & Othello:** Board flipping algorithms and win-state detection.
- **Battleship & Minesweeper:** Fog-of-war grid simulation with flag markers and mine triggers.
- **Tic-Tac-Toe (2D & 3D):** Classic grid and volumetric 3x3x3 cubic strategy.

### 🕹️ Arcade & Action
- **Air Hockey & Pong:** Real-time physics paddle collision and ball trajectory calculations.
- **Space Shooter:** Enemy wave spawns, lasers, explosions, and shield bonuses.
- **Fruit Slasher:** Multi-touch gesture slicing with blade trail particles.
- **Brick Breaker & Pinball:** Bumper rebounds, paddle controls, and score multipliers.
- **Snake & Runner:** Grid-based speed progression and obstacle avoidance.

### 🧩 Puzzles & Brain Games
- **2048 & Block Puzzle:** Tile merging animations, grid validation, and game-over detection.
- **Sudoku:** Grid generator with difficulty hints and error checkers.
- **Match-3 & Memory Match:** Color swap cascading matches and memory card flipping.
- **Jigsaw Puzzle & Maze Solver:** Algorithmic path-finding and tile reconstruction.
- **Word Search & Scramble:** Vocabulary letter-matrix searching and anagram solvers.

### 👥 2-Player Same-Device Party Games
- **Finger Battle & Thumb Fighter:** Rapid multi-touch tapping speed races.
- **Tug of War:** Dynamic center-of-gravity rope pulling.
- **Spin the Wheel & Truth or Dare:** Party mode randomize wheels.

---

## ⚡ Core Architecture & Systems

- **Audio & Haptic Feedback Engine (`AudioFeedbackService`):**
  - Zero-asset, system-native click sound and tactile vibration response (`HapticFeedback.lightImpact`, `mediumImpact`, `heavyImpact`).
  - Global in-game mute/unmute toggle.
- **Persistent Leaderboard & Stats (`StorageService`):**
  - Top 10 high-score persistence with player rank and timestamps using SharedPreferences.
  - Analytics tracking: total session count, play time, and match counters.
- **Monetization & Store System:**
  - Virtual coins wallet and in-app cosmetic purchases.
  - Google Mobile Ads (`google_mobile_ads`) support for banners and interstitials.
- **Unified Game Wrapper (`GameWrapper`):**
  - Consistent pause menu, reset controller, and leaderboard modal across every game.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24+ recommended)
- Android Studio / Xcode / VS Code
- Chrome or Edge (for web preview)

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/yashpatadiya1724-cmyk/super-game-hub.git
cd super-game-hub

# Fetch dependencies
flutter pub get

# Verify code health (100% clean, 0 linter issues)
flutter analyze

# Run on your preferred target (Web, Chrome, Android emulator, or connected phone)
flutter run -d chrome
```

---

## 📁 Project Structure

```
lib/
├── games/               # 40+ self-contained game implementations
│   ├── chess_game.dart
│   ├── snake_game.dart
│   ├── game_2048.dart
│   ├── space_shooter.dart
│   └── ...
├── models/              # Game categories and metadata models
├── registry/            # Central dynamic game registry
├── screens/             # Home, store, analytics, and game wrapper screens
├── services/            # StorageService & AudioFeedbackService
├── theme/               # Neo-brutalist / vibrant arcade dark theme
└── widgets/             # Reusable custom game badges and UI components
```

---

## 📄 License

This project is open-source under the MIT License.
