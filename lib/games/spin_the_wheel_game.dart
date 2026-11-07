import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class SpinTheWheelGame extends StatefulWidget {
  const SpinTheWheelGame({super.key});
  @override
  State<SpinTheWheelGame> createState() => _SpinState();
}

class _SpinState extends State<SpinTheWheelGame> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool spinning = false;
  String result = '';
  int p1Wins = 0, p2Wins = 0;

  final List<String> segments = ['P1 WINS', 'P2 WINS', 'DRAW', 'P1 WINS', 'P2 WINS', 'P1 WINS', 'DRAW', 'P2 WINS'];
  final List<Color> colors = [Colors.red, Colors.blue, Colors.amber, Colors.red, Colors.blue, Colors.red, Colors.amber, Colors.blue];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  }

  void _spin() {
    if (spinning) return;
    setState(() { spinning = true; result = ''; });
    final rng = Random();
    final totalRot = (pi * 4) + rng.nextDouble() * pi * 4;
    _anim = Tween<double>(begin: 0, end: totalRot).animate(CurvedAnimation(parent: _ctrl, curve: Curves.decelerate));
    _ctrl.reset();
    _ctrl.forward().whenComplete(() {
      final finalAngle = totalRot % (2 * pi);
      final idx = (segments.length - (finalAngle / (2 * pi / segments.length)).floor()) % segments.length;
      setState(() {
        spinning = false;
        result = segments[idx];
        if (result.contains('P1')) p1Wins++;
        else if (result.contains('P2')) p2Wins++;
      });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Spin The Wheel',
      onReset: () => setState(() { p1Wins = 0; p2Wins = 0; result = ''; _ctrl.reset(); spinning = false; }),
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _scoreBox('P1', p1Wins, Colors.redAccent),
            _scoreBox('P2', p2Wins, Colors.blueAccent),
          ]),
          const SizedBox(height: 30),
          // Arrow pointer
          const Icon(Icons.arrow_downward, color: Colors.white, size: 30),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, child) {
              return Transform.rotate(
                angle: _ctrl.isAnimating ? _anim.value : 0,
                child: CustomPaint(size: const Size(260, 260), painter: _WheelPainter(segments, colors)),
              );
            },
          ),
          const SizedBox(height: 20),
          if (result.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white30)),
              child: Text(result, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: spinning ? null : _spin,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
            child: Text(spinning ? 'Spinning...' : 'SPIN!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int score, Color color) => Column(children: [
    Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    Text('$score wins', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
  ]);
}

class _WheelPainter extends CustomPainter {
  final List<String> segments;
  final List<Color> colors;
  _WheelPainter(this.segments, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;
    final sweep = 2 * pi / segments.length;
    for (int i = 0; i < segments.length; i++) {
      final paint = Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), i * sweep, sweep, true, paint);
      final borderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), i * sweep, sweep, true, borderPaint);
      // Draw text
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * sweep + sweep / 2);
      final tp = TextPainter(
        text: TextSpan(text: segments[i], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(r * 0.5 - tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    // Center circle
    canvas.drawCircle(Offset(cx, cy), 20, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
