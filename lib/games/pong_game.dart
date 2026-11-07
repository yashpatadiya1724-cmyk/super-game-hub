import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/audio_feedback_service.dart';

class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> {
  static const double paddleH = 90;
  static const double paddleW = 14;
  static const double ballRadius = 10;
  static const int winningScore = 7;

  double ballX = 0.5;
  double ballY = 0.5;
  double ballDX = 0.014;
  double ballDY = 0.009;

  double p1Y = 0.5; // Left player (Cyan)
  double p2Y = 0.5; // Right player (Magenta)

  int p1Score = 0;
  int p2Score = 0;
  String? winner;
  bool isPlaying = false;
  Timer? gameTimer;

  final List<Offset> ballTrail = [];

  void _startGame() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = true;
      winner = null;
      ballX = 0.5;
      ballY = 0.5;
      ballDX = Random().nextBool() ? 0.014 : -0.014;
      ballDY = (Random().nextDouble() - 0.5) * 0.015;
      ballTrail.clear();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    if (!mounted || !isPlaying || winner != null) return;

    setState(() {
      ballTrail.add(Offset(ballX, ballY));
      if (ballTrail.length > 6) ballTrail.removeAt(0);

      ballX += ballDX;
      ballY += ballDY;

      // Top and Bottom wall bounce
      if (ballY <= 0.03) {
        ballDY = ballDY.abs();
        AudioFeedbackService.playClick();
      } else if (ballY >= 0.97) {
        ballDY = -ballDY.abs();
        AudioFeedbackService.playClick();
      }

      // P1 Paddle Collision (Left, X around 0.06)
      if (ballX <= 0.07 && ballX >= 0.03) {
        if ((ballY >= p1Y - 0.12 && ballY <= p1Y + 0.12)) {
          ballDX = ballDX.abs() * 1.05; // Speed up
          ballDY += (ballY - p1Y) * 0.035;
          AudioFeedbackService.vibrate(20);
        }
      }

      // P2 Paddle Collision (Right, X around 0.94)
      if (ballX >= 0.93 && ballX <= 0.97) {
        if ((ballY >= p2Y - 0.12 && ballY <= p2Y + 0.12)) {
          ballDX = -ballDX.abs() * 1.05; // Speed up
          ballDY += (ballY - p2Y) * 0.035;
          AudioFeedbackService.vibrate(20);
        }
      }

      // Score detection
      if (ballX < 0) {
        p2Score++;
        AudioFeedbackService.vibrate(50);
        _checkWinnerOrReset(1);
      } else if (ballX > 1.0) {
        p1Score++;
        AudioFeedbackService.vibrate(50);
        _checkWinnerOrReset(-1);
      }
    });
  }

  void _checkWinnerOrReset(int nextDir) {
    if (p1Score >= winningScore) {
      winner = "CYAN PLAYER WINS!";
      isPlaying = false;
      gameTimer?.cancel();
    } else if (p2Score >= winningScore) {
      winner = "MAGENTA PLAYER WINS!";
      isPlaying = false;
      gameTimer?.cancel();
    } else {
      ballX = 0.5;
      ballY = 0.5;
      ballDX = 0.014 * nextDir;
      ballDY = (Random().nextDouble() - 0.5) * 0.014;
      ballTrail.clear();
    }
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      p1Score = 0;
      p2Score = 0;
      winner = null;
      isPlaying = false;
      p1Y = 0.5;
      p2Y = 0.5;
      ballTrail.clear();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Neon Pong 🏓",
      onReset: _resetGame,
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          final gW = constraints.maxWidth;
          final gH = constraints.maxHeight;

          return Stack(
            children: [
              // Retro Cyber Grid Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF030712), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Center Net Line
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    14,
                    (_) => Container(
                      width: 4,
                      height: gH / 24,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),

              // Scores in Background
              Positioned(
                top: 24,
                left: gW * 0.22,
                child: Text(
                  "$p1Score",
                  style: GoogleFonts.outfit(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: Colors.cyanAccent.withValues(alpha: 0.35),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: gW * 0.22,
                child: Text(
                  "$p2Score",
                  style: GoogleFonts.outfit(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: Colors.pinkAccent.withValues(alpha: 0.35),
                  ),
                ),
              ),

              // Ball Trail
              ...ballTrail.map((pos) => Positioned(
                    left: pos.dx * gW - 6,
                    top: pos.dy * gH - 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amberAccent.withValues(alpha: 0.3),
                      ),
                    ),
                  )),

              // Neon Glowing Ball
              Positioned(
                left: ballX * gW - ballRadius,
                top: ballY * gH - ballRadius,
                child: Container(
                  width: ballRadius * 2,
                  height: ballRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amberAccent.withValues(alpha: 0.9),
                        blurRadius: 16,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // Player 1 Paddle (Left, Cyan)
              Positioned(
                left: 14,
                top: (p1Y * gH) - (paddleH / 2),
                child: Container(
                  width: paddleW,
                  height: paddleH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFF00E5FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Player 2 Paddle (Right, Pink/Magenta)
              Positioned(
                right: 14,
                top: (p2Y * gH) - (paddleH / 2),
                child: Container(
                  width: paddleW,
                  height: paddleH,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1493), Colors.white],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1493).withValues(alpha: 0.8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Touch Controls: Left Half for P1
              Positioned(
                left: 0,
                top: 0,
                width: gW / 2,
                height: gH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      p1Y = (details.localPosition.dy / gH).clamp(0.08, 0.92);
                    });
                  },
                ),
              ),

              // Touch Controls: Right Half for P2
              Positioned(
                right: 0,
                top: 0,
                width: gW / 2,
                height: gH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      p2Y = (details.localPosition.dy / gH).clamp(0.08, 0.92);
                    });
                  },
                ),
              ),

              // Winner Screen
              if (winner != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, size: 70, color: Colors.amber),
                          const SizedBox(height: 16),
                          Text(
                            winner!,
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                const Shadow(color: Colors.cyanAccent, blurRadius: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Score: $p1Score - $p2Score",
                            style: GoogleFonts.outfit(fontSize: 20, color: Colors.white70),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            ),
                            child: Text(
                              "REMATCH",
                              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Start Prompt
              if (!isPlaying && winner == null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          "START PONG",
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
