import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Trauma-based Screen Shake Controller.
/// Uses the industry-standard game feel formula:
/// Shake = trauma^2 * maxTranslation / maxRotation
class ScreenShakeController extends ChangeNotifier {
  double _trauma = 0.0;
  final double decaySpeed;
  final double maxOffset;
  final double maxAngle;
  final Random _rnd = Random();

  ScreenShakeController({
    this.decaySpeed = 1.6,
    this.maxOffset = 16.0,
    this.maxAngle = 0.05,
  });

  double get trauma => _trauma;

  /// Add trauma (0.0 to 1.0) to trigger or intensify screen shake
  void addTrauma(double amount) {
    _trauma = (_trauma + amount).clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Update loop called per frame (e.g. 60 FPS dt approx 0.016s)
  void update(double dt) {
    if (_trauma > 0) {
      _trauma = max(0.0, _trauma - (decaySpeed * dt));
      notifyListeners();
    }
  }

  /// Get current translation offset
  Offset getOffset() {
    if (_trauma <= 0) return Offset.zero;
    final shake = _trauma * _trauma;
    final dx = (_rnd.nextDouble() * 2 - 1) * maxOffset * shake;
    final dy = (_rnd.nextDouble() * 2 - 1) * maxOffset * shake;
    return Offset(dx, dy);
  }

  /// Get current angular rotation tilt
  double getRotation() {
    if (_trauma <= 0) return 0.0;
    final shake = _trauma * _trauma;
    return (_rnd.nextDouble() * 2 - 1) * maxAngle * shake;
  }
}

/// Widget that wraps any game viewport and shakes according to ScreenShakeController
class JuiceShakeWidget extends StatefulWidget {
  final Widget child;
  final ScreenShakeController controller;

  const JuiceShakeWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<JuiceShakeWidget> createState() => _JuiceShakeWidgetState();
}

class _JuiceShakeWidgetState extends State<JuiceShakeWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      widget.controller.update(0.016);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final offset = widget.controller.getOffset();
        final angle = widget.controller.getRotation();

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: angle,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Particle model for lightweight 60 FPS canvas particle bursts
class JuiceParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;
  final Color color;
  final double gravity;
  final double decay;

  JuiceParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.gravity = 0.12,
    this.decay = 0.03,
    this.alpha = 1.0,
  });

  bool step() {
    x += vx;
    y += vy;
    vy += gravity;
    alpha -= decay;
    size = max(0.0, size - 0.08);
    return alpha > 0 && size > 0;
  }
}

/// CustomPainter for rendering high-speed juice particle systems
class JuiceParticlePainter extends CustomPainter {
  final List<JuiceParticle> particles;
  JuiceParticlePainter(this.particles);

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

/// Floating Popup Text (Damage numbers, score popups, combo alerts)
class FloatingPopupText {
  final int id;
  final String text;
  final Color color;
  double x;
  double y;
  double alpha;
  double scale;

  FloatingPopupText({
    required this.id,
    required this.text,
    required this.color,
    required this.x,
    required this.y,
    this.alpha = 1.0,
    this.scale = 1.0,
  });

  bool step() {
    y -= 1.4; // Float upwards
    alpha -= 0.025;
    scale = max(0.5, scale - 0.008);
    return alpha > 0;
  }
}
