import 'dart:math';
import 'package:flutter/material.dart';

class GameParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;
  final Color color;
  final double lifeDecay;

  GameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.alpha = 1.0,
    this.lifeDecay = 0.03,
  });

  bool update() {
    x += vx;
    y += vy;
    vy += 0.15; // Gravity
    alpha -= lifeDecay;
    size = max(0, size - 0.1);
    return alpha > 0 && size > 0;
  }

  /// Creates a radial explosion burst of particles centered at (x, y)
  static List<GameParticle> createBurst({
    required double x,
    required double y,
    required Color color,
    int count = 10,
    double maxSpeed = 5.0,
    Random? random,
  }) {
    final rng = random ?? Random();
    final list = <GameParticle>[];
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + (rng.nextDouble() * 0.2);
      final speed = 1.0 + (rng.nextDouble() * (maxSpeed - 1.0));
      list.add(GameParticle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 1.5,
        size: 4.0 + (rng.nextDouble() * 4.0),
        color: color,
        alpha: 1.0,
        lifeDecay: 0.025 + (rng.nextDouble() * 0.02),
      ));
    }
    return list;
  }
}

class ParticlePainter extends CustomPainter {
  final List<GameParticle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
