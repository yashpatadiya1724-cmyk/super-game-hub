import 'package:flutter/services.dart';

/// AudioFeedbackService provides zero-asset, system-native sound and haptic
/// feedback across Android, iOS, Desktop, and Web.
class AudioFeedbackService {
  static bool _soundEnabled = true;
  static bool _hapticsEnabled = true;

  static bool get soundEnabled => _soundEnabled;
  static bool get hapticsEnabled => _hapticsEnabled;

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  static void toggleHaptics() {
    _hapticsEnabled = !_hapticsEnabled;
  }

  /// Lightweight tap sound & light vibration for buttons / tile clicks
  static void playTap() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium feedback for scoring points / matching blocks
  static void playScore() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Strong festive vibration & sound sequence for winning
  static void playWin() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 120), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  /// Distinct alert pulse for Game Over / Misses
  static void playGameOver() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (_hapticsEnabled) {
      HapticFeedback.vibrate();
    }
  }
}
