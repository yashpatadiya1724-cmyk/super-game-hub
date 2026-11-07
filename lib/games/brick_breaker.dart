import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';
import '../../services/audio_feedback_service.dart';

class BrickBreakerGame extends StatefulWidget {
  const BrickBreakerGame({super.key});

  @override
  State<BrickBreakerGame> createState() => _BrickBreakerGameState();
}

class _BrickBreakerGameState extends State<BrickBreakerGame> {
  // Ball coordinates & velocity
  double ballX = 0;
  double ballY = 0.5;
  double ballXDir = 0.012;
  double ballYDir = -0.012;

  // Paddle coordinates
  double paddleX = 0;
  double paddleWidth = 0.42;

  // Game state
  bool hasGameStarted = false;
  bool isGameOver = false;
  bool isLevelClear = false;
  bool isVictory = false;

  int score = 0;
  int currentLevel = 1;
  int lives = 3;

  Timer? gameTimer;

  // Bricks representation
  late List<_Brick> bricks;

  @override
  void initState() {
    super.initState();
    _initLevel(1);
  }

  void _initLevel(int level) {
    currentLevel = level;
    ballX = 0;
    ballY = 0.5;
    double speedMultiplier = level == 1 ? 1.0 : (level == 2 ? 1.25 : 1.5);
    ballXDir = 0.011 * speedMultiplier;
    ballYDir = -0.011 * speedMultiplier;

    int rows = level == 1 ? 3 : (level == 2 ? 4 : 5);
    int cols = 5;
    bricks = [];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        double bx = -0.8 + (c * 0.4);
        double by = -0.75 + (r * 0.12);
        int maxHp = (level > 1 && r == 0) ? 2 : 1; // Top row has reinforced bricks in later levels
        Color color;
        if (maxHp == 2) {
          color = const Color(0xFF94A3B8); // Silver armored
        } else if (r == 0) {
          color = const Color(0xFFEF4444); // Red
        } else if (r == 1) {
          color = const Color(0xFFF59E0B); // Amber
        } else if (r == 2) {
          color = const Color(0xFF10B981); // Emerald
        } else {
          color = const Color(0xFF06B6D4); // Cyan
        }

        bricks.add(_Brick(
          x: bx,
          y: by,
          hp: maxHp,
          maxHp: maxHp,
          color: color,
        ));
      }
    }
  }

  void _startGame() {
    gameTimer?.cancel();
    setState(() {
      hasGameStarted = true;
      isGameOver = false;
      isLevelClear = false;
      isVictory = false;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 14), (timer) {
      if (!mounted) return;
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      ballX += ballXDir;
      ballY += ballYDir;

      // Left and Right Wall collisions
      if (ballX >= 0.95) {
        ballXDir = -ballXDir.abs();
        AudioFeedbackService.playClick();
      } else if (ballX <= -0.95) {
        ballXDir = ballXDir.abs();
        AudioFeedbackService.playClick();
      }

      // Ceiling collision
      if (ballY <= -0.95) {
        ballYDir = ballYDir.abs();
        AudioFeedbackService.playClick();
      }

      // Paddle collision
      if (ballY >= 0.82 && ballY <= 0.88) {
        if (ballX >= paddleX - paddleWidth / 2 && ballX <= paddleX + paddleWidth / 2) {
          ballYDir = -ballYDir.abs();
          // Angle ball depending on where it hits the paddle
          double hitOffset = (ballX - paddleX) / (paddleWidth / 2);
          ballXDir += hitOffset * 0.005;
          AudioFeedbackService.vibrate(20);
        }
      }

      // Bottom pit (Life loss)
      if (ballY >= 1.05) {
        lives--;
        AudioFeedbackService.vibrate(60);
        if (lives <= 0) {
          _handleGameOver();
        } else {
          // Reset ball to paddle
          ballX = paddleX;
          ballY = 0.5;
          ballYDir = -ballYDir.abs();
        }
      }

      // Check Brick Collisions
      for (var b in bricks) {
        if (b.hp > 0) {
          if (ballX >= b.x - 0.18 && ballX <= b.x + 0.18 && ballY >= b.y - 0.05 && ballY <= b.y + 0.05) {
            b.hp--;
            ballYDir = -ballYDir;
            score += 20;
            AudioFeedbackService.playClick();
            if (b.hp <= 0) {
              score += 30;
              AudioFeedbackService.vibrate(25);
            }
            break;
          }
        }
      }

      // Check if Level Cleared
      if (bricks.every((b) => b.hp <= 0)) {
        gameTimer?.cancel();
        if (currentLevel < 3) {
          isLevelClear = true;
          AudioFeedbackService.vibrate(70);
        } else {
          isVictory = true;
          StorageService.saveHighScore('brick_breaker', score);
          AudioFeedbackService.vibrate(100);
        }
      }
    });
  }

  void _nextLevel() {
    setState(() {
      _initLevel(currentLevel + 1);
      isLevelClear = false;
    });
    _startGame();
  }

  void _handleGameOver() {
    gameTimer?.cancel();
    setState(() {
      hasGameStarted = false;
      isGameOver = true;
    });
    StorageService.saveHighScore('brick_breaker', score);
  }

  void _resetGame() {
    gameTimer?.cancel();
    setState(() {
      score = 0;
      lives = 3;
      hasGameStarted = false;
      isGameOver = false;
      isLevelClear = false;
      isVictory = false;
      _initLevel(1);
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
      title: "Brick Breaker Galaxy 🧱",
      onReset: _resetGame,
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) {
              setState(() {
                paddleX = ((details.localPosition.dx / w) * 2 - 1).clamp(-0.8, 0.8);
              });
            },
            child: Stack(
              children: [
                // Cyber Dark Background
                Container(
                  color: const Color(0xFF0F172A),
                ),

                // Top HUD: Level, Score & Lives
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.purpleAccent),
                        ),
                        child: Text(
                          "LEVEL $currentLevel/3",
                          style: GoogleFonts.outfit(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "SCORE: $score",
                        style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      Row(
                        children: List.generate(
                          3,
                          (i) => Icon(
                            Icons.favorite,
                            color: i < lives ? Colors.redAccent : Colors.white24,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bricks Grid
                ...bricks.where((b) => b.hp > 0).map((b) {
                  final bx = (b.x + 1) / 2 * w;
                  final by = (b.y + 1) / 2 * h;
                  return Positioned(
                    left: bx - (w * 0.085),
                    top: by - 12,
                    child: Container(
                      width: w * 0.17,
                      height: 24,
                      decoration: BoxDecoration(
                        color: b.hp < b.maxHp ? b.color.withValues(alpha: 0.5) : b.color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: b.color.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: b.maxHp > 1
                          ? Center(
                              child: Text(
                                "${b.hp}",
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                    ),
                  );
                }),

                // Neon Ball
                Positioned(
                  left: (ballX + 1) / 2 * w - 9,
                  top: (ballY + 1) / 2 * h - 9,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.9),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Glowing Laser Paddle
                Positioned(
                  left: (paddleX + 1) / 2 * w - (w * paddleWidth / 4),
                  top: 0.85 * h,
                  child: Container(
                    width: w * paddleWidth / 2,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFFA855F7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withValues(alpha: 0.8),
                          blurRadius: 16,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),

                // Drag instruction
                if (hasGameStarted && !isGameOver && !isLevelClear && !isVictory)
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "DRAG SCREEN HORIZONTALLY TO MOVE PADDLE",
                        style: GoogleFonts.outfit(
                          color: Colors.white30,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Level Cleared Modal
                if (isLevelClear)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🎉", style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 12),
                            Text(
                              "LEVEL $currentLevel CLEARED!",
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.amberAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Bricks destroyed! Ready for the next speed tier?", style: GoogleFonts.outfit(color: Colors.white70)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _nextLevel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              child: Text(
                                "NEXT LEVEL",
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Victory Modal (Completed Level 3)
                if (isVictory)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🏆", style: TextStyle(fontSize: 70)),
                            const SizedBox(height: 12),
                            Text(
                              "BRICK MASTER!",
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.amberAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("All 3 Levels Completed • Score: $score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              child: Text(
                                "PLAY AGAIN",
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Game Over Modal
                if (isGameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cancel, size: 70, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text(
                              "GAME OVER",
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Reached Level $currentLevel • Score: $score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              child: Text(
                                "RETRY",
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Start button overlay
                if (!hasGameStarted && !isGameOver && !isLevelClear && !isVictory)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: _startGame,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            "START GAME",
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Brick {
  final double x;
  final double y;
  int hp;
  final int maxHp;
  final Color color;
  _Brick({required this.x, required this.y, required this.hp, required this.maxHp, required this.color});
}
