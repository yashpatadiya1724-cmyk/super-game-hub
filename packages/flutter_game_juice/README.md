# flutter_game_juice 🧃

A lightweight, zero-dependency game feel & juice toolkit for Flutter games. Designed for indie game developers to add AAA "game feel" with minimal code.

## Features
- **Trauma-Based Screen Shake (`ScreenShakeController` & `JuiceShakeWidget`)**: Industry standard trauma math (`trauma^2 * maxTranslation / angle`) with natural linear decay.
- **Particle System (`JuiceParticle` & `JuiceParticlePainter`)**: Zero-asset 60 FPS particle bursts for hits, sparks, confetti, and explosions.
- **Floating Damage / Score Popups (`FloatingPopupText`)**: Smooth floating text for damage numbers, score increments, and combos.

## Quick Start

```dart
import 'package:flutter_game_juice/flutter_game_juice.dart';

final shakeController = ScreenShakeController();

// Wrap your game view
JuiceShakeWidget(
  controller: shakeController,
  child: MyGameScreen(),
);

// Trigger on hit / explosion
shakeController.addTrauma(0.6); // 0.0 to 1.0
```
