import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class PongGame extends StatefulWidget {
  const PongGame({super.key});
  @override
  State<PongGame> createState() => _PongState();
}

class _PongState extends State<PongGame> {
  static const double paddleH = 80, paddleW = 14, ballSize = 16;
  double ballX = 0.5, ballY = 0.5;
  double ballDX = 0.012, ballDY = 0.010;
  double p1Y = 0.5, p2Y = 0.5;
  int p1Score = 0, p2Score = 0;
  Timer? timer;
  bool isPlaying = false;

  void _start() {
    setState(() { isPlaying = true; ballX = 0.5; ballY = 0.5; ballDX = 0.012; ballDY = 0.008; });
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      ballX += ballDX;
      ballY += ballDY;

      // Top/bottom wall bounce
      if (ballY <= 0.02 || ballY >= 0.98) ballDY = -ballDY;

      // P1 paddle (left)
      if (ballX <= 0.06 && (ballY >= p1Y - 0.1 && ballY <= p1Y + 0.1)) {
        ballDX = ballDX.abs();
        ballDY += (ballY - p1Y) * 0.04;
      }

      // P2 paddle (right)
      if (ballX >= 0.94 && (ballY >= p2Y - 0.1 && ballY <= p2Y + 0.1)) {
        ballDX = -ballDX.abs();
        ballDY += (ballY - p2Y) * 0.04;
      }

      // Score
      if (ballX < 0) { p2Score++; _resetBall(1); }
      if (ballX > 1) { p1Score++; _resetBall(-1); }

      if (p1Score >= 7 || p2Score >= 7) { timer?.cancel(); isPlaying = false; }
    });
  }

  void _resetBall(int dir) {
    ballX = 0.5; ballY = 0.5;
    ballDX = 0.012 * dir;
    ballDY = (Random().nextDouble() - 0.5) * 0.015;
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gW = size.width - 32;
    final gH = size.height * 0.5;

    return GameWrapper(
      title: 'Pong',
      onReset: () { timer?.cancel(); setState(() { isPlaying = false; p1Score = 0; p2Score = 0; ballX = 0.5; ballY = 0.5; }); },
      gameContent: Column(children: [
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('P1: $p1Score', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('P2: $p2Score', style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 28, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        // Game area
        GestureDetector(
          onVerticalDragUpdate: (d) {
            final rel = d.localPosition.dy / gH;
            setState(() {
              if (d.localPosition.dx < gW / 2) {
                p1Y = rel.clamp(0.1, 0.9);
              } else {
                p2Y = rel.clamp(0.1, 0.9);
              }
            });
          },
          child: Container(
            width: gW, height: gH,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white30, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(children: [
              // Center line
              Center(child: Container(width: 2, height: gH, color: Colors.white12)),
              // Ball
              Positioned(
                left: ballX * gW - ballSize / 2,
                top: ballY * gH - ballSize / 2,
                child: Container(width: ballSize, height: ballSize,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white, blurRadius: 8)])),
              ),
              // P1 paddle
              Positioned(
                left: 8, top: p1Y * gH - paddleH / 2,
                child: Container(width: paddleW, height: paddleH,
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8))),
              ),
              // P2 paddle
              Positioned(
                right: 8, top: p2Y * gH - paddleH / 2,
                child: Container(width: paddleW, height: paddleH,
                  decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8))),
              ),
              if (!isPlaying)
                Center(child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    p1Score >= 7 ? '🔴 P1 WINS!' : p2Score >= 7 ? '🔵 P2 WINS!' : 'Drag to move paddles!',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Drag left half = P1 paddle | Right half = P2 paddle', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        if (!isPlaying)
          ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
            child: Text(p1Score >= 7 || p2Score >= 7 ? 'PLAY AGAIN!' : 'START PONG!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
          ),
      ]),
    );
  }
}
