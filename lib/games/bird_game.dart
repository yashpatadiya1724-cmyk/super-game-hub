import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';
import '../../services/audio_feedback_service.dart';
import '../../services/screen_juice_service.dart';

class BirdGame extends StatefulWidget {
  const BirdGame({super.key});

  @override
  State<BirdGame> createState() => _BirdGameState();
}

class _BirdGameState extends State<BirdGame> {
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  // Bird physics
  double birdY = 0; // -1.0 (top) to 1.0 (ground)
  double velocity = 0;
  double birdAngle = 0; // radians for tilt
  static const double gravity = 0.0016;
  static const double flapStrength = -0.026;

  // Level & Game State
  int currentLevel = 1;
  int score = 0;
  bool isPlaying = false;
  bool isGameOver = false;
  bool isVictory = false;
  String? levelBanner;

  Timer? gameTimer;

  // Pipes (Pillars)
  List<_PipePair> pipes = [];
  final Random rng = Random();

  // Parallax clouds
  double cloudOffsetX = 0.0;

  int get targetScoreForLevel {
    if (currentLevel == 1) return 5;
    if (currentLevel == 2) return 12;
    return 20;
  }

  void _startGame() {
    _cleanup();
    setState(() {
      birdY = 0;
      velocity = 0;
      birdAngle = 0;
      score = 0;
      currentLevel = 1;
      isPlaying = true;
      isGameOver = false;
      isVictory = false;
      levelBanner = null;
      _initPipes();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      _updatePhysics();
    });
  }

  void _initPipes() {
    pipes = [
      _PipePair(x: 1.5, gapCenter: -0.1, gapSize: 0.55),
      _PipePair(x: 2.3, gapCenter: 0.2, gapSize: 0.55),
    ];
  }

  void _flap() {
    if (!isPlaying) {
      if (!isGameOver && !isVictory) _startGame();
      return;
    }
    velocity = flapStrength;
    birdAngle = -0.45; // Tilt up
    AudioFeedbackService.playClick();
  }

  void _updatePhysics() {
    setState(() {
      cloudOffsetX = (cloudOffsetX + 0.002) % 1.0;

      // Bird gravity
      velocity += gravity;
      birdY += velocity;

      // Rotate bird based on velocity
      if (velocity > 0.01) {
        birdAngle = (birdAngle + 0.05).clamp(-0.45, 0.9); // Dive
      }

      // Ground or ceiling collision
      if (birdY >= 0.88 || birdY <= -0.95) {
        _handleCrash();
        return;
      }

      // Pipe speed based on level
      double pipeSpeed = currentLevel == 1 ? 0.012 : (currentLevel == 2 ? 0.015 : 0.018);

      for (var p in pipes) {
        p.x -= pipeSpeed;

        // Level 2 & 3: Moving oscillating pipes!
        if (currentLevel >= 2) {
          p.gapCenter += p.oscillationDir * 0.006;
          if (p.gapCenter > 0.45 || p.gapCenter < -0.45) {
            p.oscillationDir = -p.oscillationDir;
          }
        }

        // Check if bird passed pipe for score
        if (!p.scored && p.x < 0) {
          p.scored = true;
          score++;
          AudioFeedbackService.playClick();
          AudioFeedbackService.vibrate(15);
          _checkLevelUp();
        }

        // Collision detection (Bird radius approx 0.06)
        if (p.x > -0.15 && p.x < 0.15) {
          double topPipeBottom = p.gapCenter - (p.gapSize / 2);
          double bottomPipeTop = p.gapCenter + (p.gapSize / 2);

          if (birdY < topPipeBottom || birdY > bottomPipeTop) {
            _handleCrash();
            return;
          }
        }
      }

      // Recycle pipes
      if (pipes.first.x < -1.5) {
        pipes.removeAt(0);
        double nextX = pipes.last.x + (currentLevel == 3 ? 0.75 : 0.85);
        double nextGap = currentLevel == 3 ? 0.45 : (currentLevel == 2 ? 0.50 : 0.55);
        double nextCenter = -0.4 + rng.nextDouble() * 0.8;
        pipes.add(_PipePair(x: nextX, gapCenter: nextCenter, gapSize: nextGap));
      }
    });
  }

  void _checkLevelUp() {
    if (currentLevel == 1 && score >= 5) {
      _advanceLevel(2, "LEVEL 2: MOVING PIPES! 🌆");
    } else if (currentLevel == 2 && score >= 12) {
      _advanceLevel(3, "LEVEL 3: CYBER NIGHT STORM! ⚡");
    } else if (currentLevel == 3 && score >= 20) {
      isVictory = true;
      isPlaying = false;
      _cleanup();
      StorageService.saveHighScore('bird', score);
      AudioFeedbackService.vibrate(100);
    }
  }

  void _advanceLevel(int nextLevel, String message) {
    currentLevel = nextLevel;
    levelBanner = message;
    AudioFeedbackService.vibrate(60);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => levelBanner = null);
    });
  }

  void _handleCrash() {
    _shakeKey.currentState?.shake();
    _cleanup();
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    StorageService.saveHighScore('bird', score);
    AudioFeedbackService.vibrate(85);
  }

  void _cleanup() {
    gameTimer?.cancel();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Cyber Aviator Flappy 🐦",
      onReset: _startGame,
      gameContent: ShakeWidget(
        key: _shakeKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Sky gradient per level
            List<Color> skyColors;
            if (currentLevel == 1) {
              skyColors = [const Color(0xFF38BDF8), const Color(0xFFBAE6FD), const Color(0xFFF0F9FF)];
            } else if (currentLevel == 2) {
              skyColors = [const Color(0xFFF97316), const Color(0xFF9333EA), const Color(0xFF312E81)];
            } else {
              skyColors = [const Color(0xFF0F172A), const Color(0xFF1E1B4B), const Color(0xFF020617)];
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _flap(),
              child: Stack(
                children: [
                  // Dynamic Sky
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: skyColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Clouds Parallax
                  Positioned(
                    top: 40,
                    left: -cloudOffsetX * w,
                    child: Row(
                      children: [
                        Text("☁️     ☁️         ☁️", style: TextStyle(fontSize: 40, color: Colors.white.withValues(alpha: 0.35))),
                        Text("☁️     ☁️         ☁️", style: TextStyle(fontSize: 40, color: Colors.white.withValues(alpha: 0.35))),
                      ],
                    ),
                  ),

                  // Pipes
                  ...pipes.expand((p) {
                    final px = (p.x + 1) / 2 * w;
                    final gapCenterY = (p.gapCenter + 1) / 2 * h;
                    final halfGap = (p.gapSize / 2) * h;

                    return [
                      // Top Pipe
                      Positioned(
                        left: px - 28,
                        top: 0,
                        width: 56,
                        height: max(0, gapCenterY - halfGap),
                        child: _buildPipe(isTop: true),
                      ),
                      // Bottom Pipe
                      Positioned(
                        left: px - 28,
                        top: gapCenterY + halfGap,
                        width: 56,
                        height: max(0, h - (gapCenterY + halfGap)),
                        child: _buildPipe(isTop: false),
                      ),
                    ];
                  }),

                  // Ground Grid
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: h * 0.08,
                    child: Container(
                      decoration: BoxDecoration(
                        color: currentLevel == 3 ? const Color(0xFF0F172A) : const Color(0xFF15803D),
                        border: Border(top: BorderSide(color: currentLevel == 3 ? Colors.cyanAccent : Colors.amber, width: 3)),
                      ),
                      child: Center(
                        child: Text(
                          currentLevel == 3 ? "⚡ ⚡ ⚡ CYBER GROUND ⚡ ⚡ ⚡" : "🌱 🌱 🌱 🌱 🌱 🌱 🌱 🌱",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                        ),
                      ),
                    ),
                  ),

                  // Animated Aviator Bird
                  Positioned(
                    left: w * 0.45 - 24,
                    top: (birdY + 1) / 2 * h - 24,
                    child: Transform.rotate(
                      angle: birdAngle,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Colors.white, Color(0xFFFBBF24), Color(0xFFD97706)],
                            stops: [0.2, 0.7, 1.0],
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 14),
                          ],
                        ),
                        child: const Center(
                          child: Text("🐥", style: TextStyle(fontSize: 26)),
                        ),
                      ),
                    ),
                  ),

                  // Top HUD: Level & Score
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amberAccent),
                          ),
                          child: Text(
                            "LEVEL $currentLevel/3",
                            style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Text(
                            "SCORE: $score",
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Level Up Floating Banner
                  if (levelBanner != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amberAccent, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 20),
                          ],
                        ),
                        child: Text(
                          levelBanner!,
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.amberAccent),
                        ),
                      ),
                    ),

                  // Victory Screen
                  if (isVictory)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("👑", style: TextStyle(fontSize: 70)),
                              const SizedBox(height: 12),
                              Text(
                                "AVIATOR CHAMPION!",
                                style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.amberAccent),
                              ),
                              const SizedBox(height: 8),
                              Text("Cleared All 3 Sky Levels • Score: $score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                                ),
                                child: Text("PLAY AGAIN", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Game Over Screen
                  if (isGameOver)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("💥", style: TextStyle(fontSize: 70)),
                              const SizedBox(height: 12),
                              Text("CRASHED!", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text("Level $currentLevel • Final Score: $score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                                ),
                                child: Text("TRY AGAIN", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Start Screen
                  if (!isPlaying && !isGameOver && !isVictory)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.65),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: _startGame,
                            icon: const Icon(Icons.flight_takeoff, color: Colors.black),
                            label: Text("TAP TO FLY", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPipe({required bool isTop}) {
    Color pipeBase = currentLevel == 3 ? const Color(0xFF6B21A8) : const Color(0xFF15803D);
    Color pipeLight = currentLevel == 3 ? const Color(0xFFA855F7) : const Color(0xFF22C55E);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [pipeBase, pipeLight, pipeBase],
          stops: const [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: (currentLevel == 3 ? Colors.purpleAccent : Colors.green).withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _PipePair {
  double x;
  double gapCenter;
  final double gapSize;
  double oscillationDir = 1.0;
  bool scored = false;
  _PipePair({required this.x, required this.gapCenter, required this.gapSize});
}
