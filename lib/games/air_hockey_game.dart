import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/audio_feedback_service.dart';

class AirHockeyGame extends StatefulWidget {
  const AirHockeyGame({super.key});

  @override
  State<AirHockeyGame> createState() => _AirHockeyGameState();
}

class _AirHockeyGameState extends State<AirHockeyGame> with SingleTickerProviderStateMixin {
  static const double malletRadius = 32.0;
  static const double puckRadius = 20.0;
  static const int targetScore = 7;

  Offset player1Pos = const Offset(0, 0);
  Offset player2Pos = const Offset(0, 0);
  Offset puckPos = const Offset(0, 0);
  Offset puckVelocity = const Offset(0, 0);

  int score1 = 0; // Player 1 (Bottom, Red/Magenta)
  int score2 = 0; // Player 2 (Top, Cyan/Blue)
  String? winner;
  bool isGoalScored = false;
  String goalText = '';

  Timer? gameTimer;
  Size? tableSize;
  final List<Offset> puckTrail = [];

  void _resetPuck([int scoringPlayer = 0]) {
    if (tableSize == null) return;
    puckTrail.clear();
    puckPos = Offset(tableSize!.width / 2, tableSize!.height / 2);
    // Serve towards player who conceded or random
    double dirY = scoringPlayer == 1 ? -4.0 : (scoringPlayer == 2 ? 4.0 : (Random().nextBool() ? 3.5 : -3.5));
    double dirX = (Random().nextDouble() - 0.5) * 5.0;
    puckVelocity = Offset(dirX, dirY);
  }

  void _startGame() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updatePhysics();
    });
  }

  void _updatePhysics() {
    if (tableSize == null || winner != null || isGoalScored) return;

    setState(() {
      // Trail effect
      puckTrail.add(puckPos);
      if (puckTrail.length > 8) puckTrail.removeAt(0);

      // Move puck
      puckPos += puckVelocity;

      // Speed clamp & friction
      double currentSpeed = puckVelocity.distance;
      if (currentSpeed > 16.0) {
        puckVelocity = (puckVelocity / currentSpeed) * 16.0;
      }
      puckVelocity *= 0.992; // Realistic subtle friction

      final double minX = puckRadius;
      final double maxX = tableSize!.width - puckRadius;
      final double goalLeft = tableSize!.width * 0.28;
      final double goalRight = tableSize!.width * 0.72;

      // Wall collisions (Left & Right)
      if (puckPos.dx <= minX) {
        puckVelocity = Offset(puckVelocity.dx.abs(), puckVelocity.dy);
        puckPos = Offset(minX, puckPos.dy);
        AudioFeedbackService.playClick();
      } else if (puckPos.dx >= maxX) {
        puckVelocity = Offset(-puckVelocity.dx.abs(), puckVelocity.dy);
        puckPos = Offset(maxX, puckPos.dy);
        AudioFeedbackService.playClick();
      }

      // Top Goal & Wall (Player 2 side)
      if (puckPos.dy <= puckRadius) {
        if (puckPos.dx >= goalLeft && puckPos.dx <= goalRight) {
          _handleGoal(1); // Player 1 scored!
          return;
        } else {
          puckVelocity = Offset(puckVelocity.dx, puckVelocity.dy.abs());
          puckPos = Offset(puckPos.dx, puckRadius);
          AudioFeedbackService.playClick();
        }
      }

      // Bottom Goal & Wall (Player 1 side)
      if (puckPos.dy >= tableSize!.height - puckRadius) {
        if (puckPos.dx >= goalLeft && puckPos.dx <= goalRight) {
          _handleGoal(2); // Player 2 scored!
          return;
        } else {
          puckVelocity = Offset(puckVelocity.dx, -puckVelocity.dy.abs());
          puckPos = Offset(puckPos.dx, tableSize!.height - puckRadius);
          AudioFeedbackService.playClick();
        }
      }

      // Mallet collisions (Player 1)
      double dist1 = (puckPos - player1Pos).distance;
      double minCollisionDist = malletRadius + puckRadius;
      if (dist1 < minCollisionDist) {
        Offset normal = (puckPos - player1Pos) / (dist1 == 0 ? 1 : dist1);
        double hitPower = 11.0 + Random().nextDouble() * 2.0;
        puckVelocity = normal * hitPower;
        puckPos = player1Pos + normal * (minCollisionDist + 1);
        AudioFeedbackService.vibrate(20);
      }

      // Mallet collisions (Player 2)
      double dist2 = (puckPos - player2Pos).distance;
      if (dist2 < minCollisionDist) {
        Offset normal = (puckPos - player2Pos) / (dist2 == 0 ? 1 : dist2);
        double hitPower = 11.0 + Random().nextDouble() * 2.0;
        puckVelocity = normal * hitPower;
        puckPos = player2Pos + normal * (minCollisionDist + 1);
        AudioFeedbackService.vibrate(20);
      }
    });
  }

  void _handleGoal(int scoringPlayer) {
    AudioFeedbackService.vibrate(70);
    setState(() {
      isGoalScored = true;
      if (scoringPlayer == 1) {
        score1++;
        goalText = 'RED SCORES!';
      } else {
        score2++;
        goalText = 'CYAN SCORES!';
      }

      if (score1 >= targetScore) {
        winner = 'RED PLAYER WINS!';
      } else if (score2 >= targetScore) {
        winner = 'CYAN PLAYER WINS!';
      }
    });

    if (winner == null) {
      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          isGoalScored = false;
          _resetPuck(scoringPlayer);
        });
      });
    }
  }

  void _resetGame() {
    setState(() {
      score1 = 0;
      score2 = 0;
      winner = null;
      isGoalScored = false;
      if (tableSize != null) {
        player1Pos = Offset(tableSize!.width / 2, tableSize!.height * 0.82);
        player2Pos = Offset(tableSize!.width / 2, tableSize!.height * 0.18);
        _resetPuck();
      }
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
      title: "Air Hockey Neon",
      onReset: _resetGame,
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          if (tableSize == null || tableSize!.width != constraints.maxWidth) {
            tableSize = Size(constraints.maxWidth, constraints.maxHeight);
            player1Pos = Offset(tableSize!.width / 2, tableSize!.height * 0.82);
            player2Pos = Offset(tableSize!.width / 2, tableSize!.height * 0.18);
            _resetPuck();
            _startGame();
          }

          final halfH = tableSize!.height / 2;

          return Stack(
            children: [
              // Rink Background with Cyber Glow
              CustomPaint(
                size: tableSize!,
                painter: _NeonRinkPainter(),
              ),

              // Puck Trail
              ...puckTrail.asMap().entries.map((entry) {
                final idx = entry.key;
                final pos = entry.value;
                final alpha = (idx + 1) / (puckTrail.length + 1) * 0.35;
                final radius = puckRadius * (0.4 + 0.6 * (idx / puckTrail.length));
                return Positioned(
                  left: pos.dx - radius,
                  top: pos.dy - radius,
                  child: Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: alpha),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amberAccent.withValues(alpha: alpha),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Puck
              Positioned(
                left: puckPos.dx - puckRadius,
                top: puckPos.dy - puckRadius,
                child: Container(
                  width: puckRadius * 2,
                  height: puckRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Colors.white, Color(0xFFFFD54F), Color(0xFFFF6F00)],
                      stops: [0.3, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.8), blurRadius: 16, spreadRadius: 2),
                      const BoxShadow(color: Colors.white, blurRadius: 4),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Player 2 Mallet (Top - Cyan Neon)
              Positioned(
                left: player2Pos.dx - malletRadius,
                top: player2Pos.dy - malletRadius,
                child: _buildMallet(const Color(0xFF00E5FF), const Color(0xFF0091EA), "P2"),
              ),

              // Player 1 Mallet (Bottom - Red/Magenta Neon)
              Positioned(
                left: player1Pos.dx - malletRadius,
                top: player1Pos.dy - malletRadius,
                child: _buildMallet(const Color(0xFFFF1744), const Color(0xFFC51162), "P1"),
              ),

              // Digital Scoreboards on Sides
              Positioned(
                left: 16,
                top: halfH - 42,
                child: _buildScoreBadge("CYAN", score2, const Color(0xFF00E5FF)),
              ),
              Positioned(
                right: 16,
                top: halfH - 42,
                child: _buildScoreBadge("RED", score1, const Color(0xFFFF1744)),
              ),

              // Player 2 Touch Area (Top Half)
              Positioned(
                top: 0,
                left: 0,
                width: tableSize!.width,
                height: halfH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    if (winner != null) return;
                    setState(() {
                      double dx = details.localPosition.dx.clamp(malletRadius, tableSize!.width - malletRadius);
                      double dy = details.localPosition.dy.clamp(malletRadius, halfH - malletRadius - 4);
                      player2Pos = Offset(dx, dy);
                    });
                  },
                ),
              ),

              // Player 1 Touch Area (Bottom Half)
              Positioned(
                top: halfH,
                left: 0,
                width: tableSize!.width,
                height: halfH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    if (winner != null) return;
                    setState(() {
                      double dx = details.localPosition.dx.clamp(malletRadius, tableSize!.width - malletRadius);
                      double dy = (halfH + details.localPosition.dy).clamp(halfH + malletRadius + 4, tableSize!.height - malletRadius);
                      player1Pos = Offset(dx, dy);
                    });
                  },
                ),
              ),

              // Goal Celebration Overlay
              if (isGoalScored && winner == null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "⚡ GOAL! ⚡",
                            style: GoogleFonts.outfit(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.amberAccent,
                              shadows: [
                                const Shadow(color: Colors.amber, blurRadius: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goalText,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Winner Screen Overlay
              if (winner != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                          const SizedBox(height: 16),
                          Text(
                            winner!,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                const Shadow(color: Colors.cyanAccent, blurRadius: 25),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Final Score: $score2 - $score1",
                            style: GoogleFonts.outfit(fontSize: 20, color: Colors.white70),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _resetGame,
                            icon: const Icon(Icons.replay),
                            label: const Text("PLAY AGAIN"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
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

  Widget _buildMallet(Color primaryColor, Color secondaryColor, String tag) {
    return Container(
      width: malletRadius * 2,
      height: malletRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white, primaryColor, secondaryColor],
          stops: const [0.15, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.8),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
      ),
      child: Center(
        child: Text(
          tag,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(String player, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(player, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(
            "$score",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonRinkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark cyber rink surface
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A0F1D), Color(0xFF030712), Color(0xFF0A0F1D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final cyanNeon = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final redNeon = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Rink Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
        const Radius.circular(24),
      ),
      centerPaint,
    );

    // Center dividing line
    canvas.drawLine(
      Offset(10, size.height / 2),
      Offset(size.width - 10, size.height / 2),
      centerPaint,
    );

    // Center Circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 65, centerPaint);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      8,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );

    // Top Goal Arc (Player 2)
    final topGoalRect = Rect.fromCenter(
      center: Offset(size.width / 2, 10),
      width: size.width * 0.46,
      height: 80,
    );
    canvas.drawArc(topGoalRect, 0, pi, false, cyanNeon);

    // Bottom Goal Arc (Player 1)
    final bottomGoalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 10),
      width: size.width * 0.46,
      height: 80,
    );
    canvas.drawArc(bottomGoalRect, pi, pi, false, redNeon);

    // Goal slots
    final goalFill = Paint()..style = PaintingStyle.fill;
    goalFill.color = const Color(0xFF00E5FF).withValues(alpha: 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, 6, size.width * 0.44, 8),
        const Radius.circular(4),
      ),
      goalFill,
    );

    goalFill.color = const Color(0xFFFF1744).withValues(alpha: 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, size.height - 14, size.width * 0.44, 8),
        const Radius.circular(4),
      ),
      goalFill,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
