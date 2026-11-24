import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_game_hub/services/audio_feedback_service.dart';
import 'package:super_game_hub/services/particle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ParticleService & GameParticle Unit Tests', () {
    test('GameParticle initializes with correct attributes', () {
      final particle = GameParticle(
        x: 100.0,
        y: 200.0,
        vx: 3.0,
        vy: -4.0,
        size: 8.0,
        color: Colors.amber,
        alpha: 1.0,
        lifeDecay: 0.05,
      );

      expect(particle.x, 100.0);
      expect(particle.y, 200.0);
      expect(particle.vx, 3.0);
      expect(particle.vy, -4.0);
      expect(particle.size, 8.0);
      expect(particle.color, Colors.amber);
      expect(particle.alpha, 1.0);
      expect(particle.lifeDecay, 0.05);
    });

    test('GameParticle update advances position and applies gravity', () {
      final particle = GameParticle(
        x: 50.0,
        y: 50.0,
        vx: 2.0,
        vy: 1.0,
        size: 5.0,
        color: Colors.cyan,
      );

      final isAlive = particle.update();
      expect(isAlive, isTrue);
      expect(particle.x, 52.0);
      expect(particle.y, 51.0);
      // vy += 0.15 gravity
      expect(particle.vy, closeTo(1.15, 0.001));
      // alpha -= 0.03
      expect(particle.alpha, closeTo(0.97, 0.001));
      // size -= 0.1
      expect(particle.size, closeTo(4.9, 0.001));
    });

    test('GameParticle update eventually expires when alpha or size depleted', () {
      final particle = GameParticle(
        x: 0.0,
        y: 0.0,
        vx: 0.0,
        vy: 0.0,
        size: 0.25,
        color: Colors.red,
        alpha: 0.08,
        lifeDecay: 0.05,
      );

      // Frame 1
      bool alive = particle.update();
      expect(alive, isTrue);

      // Frame 2: alpha becomes <= 0 or size <= 0
      alive = particle.update();
      expect(alive, isFalse);
    });
  });

  group('AudioFeedbackService Configuration Tests', () {
    test('toggleSound toggles sound state on and off', () {
      final initial = AudioFeedbackService.soundEnabled;
      AudioFeedbackService.toggleSound();
      expect(AudioFeedbackService.soundEnabled, !initial);

      // Restore
      AudioFeedbackService.toggleSound();
      expect(AudioFeedbackService.soundEnabled, initial);
    });

    test('toggleHaptics toggles haptic feedback state on and off', () {
      final initial = AudioFeedbackService.hapticsEnabled;
      AudioFeedbackService.toggleHaptics();
      expect(AudioFeedbackService.hapticsEnabled, !initial);

      // Restore
      AudioFeedbackService.toggleHaptics();
      expect(AudioFeedbackService.hapticsEnabled, initial);
    });
  });
}
