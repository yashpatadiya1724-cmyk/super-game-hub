import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/audio_feedback_service.dart';

class TugOfWarGame extends StatefulWidget {
  const TugOfWarGame({super.key});

  @override
  State<TugOfWarGame> createState() => _TugOfWarGameState();
}

class _TugOfWarGameState extends State<TugOfWarGame> with SingleTickerProviderStateMixin {
  // -1.0 = Player 2 (Blue) victory, 1.0 = Player 1 (Red) victory
  double ropePos = 0.0;
  int timeLeft = 20;
  Timer? gameTimer;
  bool isPlaying = false;
  String? winner;

  int p1Taps = 0;
  int p2Taps = 0;

  late AnimationController _wobbleController;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _wobbleController.dispose();
    super.dispose();
  }

  void _startGame() {
    gameTimer?.cancel();
    setState(() {
      ropePos = 0.0;
      timeLeft = 20;
      isPlaying = true;
      winner = null;
      p1Taps = 0;
      p2Taps = 0;
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 1) {
          timeLeft--;
        } else {
          timer.cancel();
          isPlaying = false;
          if (ropePos > 0.15) {
            winner = "🔴 PLAYER 1 (RED) WINS!";
          } else if (ropePos < -0.15) {
            winner = "🔵 PLAYER 2 (BLUE) WINS!";
          } else {
            winner = "🤝 IT'S A DEAD TIE!";
          }
          AudioFeedbackService.vibrate(60);
        }
      });
    });
  }

  void _pull(int player) {
    if (!isPlaying || winner != null) return;
    AudioFeedbackService.playClick();

    setState(() {
      if (player == 1) {
        p1Taps++;
        ropePos += 0.035;
        if (ropePos >= 0.85) {
          ropePos = 1.0;
          winner = "🔴 PLAYER 1 PULLED OPPONENT INTO THE PIT!";
          isPlaying = false;
          gameTimer?.cancel();
          AudioFeedbackService.vibrate(90);
        }
      } else {
        p2Taps++;
        ropePos -= 0.035;
        if (ropePos <= -0.85) {
          ropePos = -1.0;
          winner = "🔵 PLAYER 2 PULLED OPPONENT INTO THE PIT!";
          isPlaying = false;
          gameTimer?.cancel();
          AudioFeedbackService.vibrate(90);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Tug of War Arena 🪢",
      onReset: _startGame,
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          final totalW = constraints.maxWidth;
          final centerX = totalW / 2;
          final knotX = (centerX + (ropePos * (totalW * 0.38))).clamp(40.0, totalW - 40.0);

          return Stack(
            children: [
              // Arena Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Game UI & Stadium
              Column(
                children: [
                  const SizedBox(height: 16),
                  // Timer and Status
                  if (isPlaying)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amberAccent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.amberAccent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "${timeLeft}s",
                            style: GoogleFonts.outfit(
                              color: timeLeft <= 5 ? Colors.redAccent : Colors.amberAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Mud / Lava Pit Center Visualizer
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The Danger Pit in center
                        Positioned(
                          left: centerX - 45,
                          top: 40,
                          bottom: 40,
                          width: 90,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB45309), Color(0xFF78350F)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "MUD\nPIT",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.white24,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // The Heavy Rope
                        Positioned(
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF92400E), width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
                              ],
                            ),
                          ),
                        ),

                        // Red Ribbon / Knot on the Rope
                        Positioned(
                          left: knotX - 18,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      blurRadius: 16,
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.flag, size: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        // Player 2 Avatar (Left, Blue)
                        Positioned(
                          left: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "P2 (BLUE)",
                                style: GoogleFonts.outfit(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text("🧗‍♂️", style: TextStyle(fontSize: 48)),
                              Text(
                                "$p2Taps Taps",
                                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Player 1 Avatar (Right, Red)
                        Positioned(
                          right: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "P1 (RED)",
                                style: GoogleFonts.outfit(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text("🧗", style: TextStyle(fontSize: 48)),
                              Text(
                                "$p1Taps Taps",
                                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dual Tap Buttons (Side by Side)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Row(
                      children: [
                        // P2 Pull Button (Blue)
                        Expanded(
                          child: GestureDetector(
                            onTapDown: (_) => _pull(2),
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.cyanAccent, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("💪", style: TextStyle(fontSize: 38)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "PULL! (P2)",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // P1 Pull Button (Red)
                        Expanded(
                          child: GestureDetector(
                            onTapDown: (_) => _pull(1),
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.redAccent, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("💪", style: TextStyle(fontSize: 38)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "PULL! (P1)",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Winner Announcement
              if (winner != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🏆", style: TextStyle(fontSize: 70)),
                            const SizedBox(height: 16),
                            Text(
                              winner!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.amberAccent,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              child: Text(
                                "PLAY AGAIN",
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Start overlay if not started
              if (!isPlaying && winner == null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: Text(
                          "START MATCH",
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
