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
