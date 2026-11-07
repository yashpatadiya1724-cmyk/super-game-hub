import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';
import '../services/audio_feedback_service.dart';
import '../services/screen_juice_service.dart';

class EndlessRunnerGame extends StatefulWidget {
  const EndlessRunnerGame({super.key});

  @override
  State<EndlessRunnerGame> createState() => _EndlessRunnerGameState();
}

class _EndlessRunnerGameState extends State<EndlessRunnerGame> {
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  static const double groundY = 0.72;
  double playerY = groundY;
  double velY = 0;
  int jumpCount = 0; // Allows Double Jump!

  // Obstacles & Collectibles
  List<_Obstacle> obstacles = [];
  List<_Gem> gems = [];

  int score = 0;
  int gemCount = 0;
  int currentLevel = 1;
  bool isPlaying = false;
  bool isGameOver = false;
  String? levelMessage;

  Timer? gameTimer;
  final Random rng = Random();

  double speed = 0.012;

  void _startGame() {
    _cleanup();
    setState(() {
      playerY = groundY;
      velY = 0;
      jumpCount = 0;
      score = 0;
      gemCount = 0;
      currentLevel = 1;
      speed = 0.013;
      isPlaying = true;
      isGameOver = false;
      levelMessage = null;
      obstacles = [
        _Obstacle(x: 1.5, height: 0.14),
        _Obstacle(x: 2.3, height: 0.18),
      ];
      gems = [
        _Gem(x: 1.2, y: groundY - 0.12),
        _Gem(x: 1.9, y: groundY - 0.22),
      ];
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      _updatePhysics();
    });
  }

  void _jump() {
    if (!isPlaying) {
      if (!isGameOver) _startGame();
      return;
    }

    if (jumpCount < 2) {
      setState(() {
        velY = -0.024;
        jumpCount++;
      });
      AudioFeedbackService.playClick();
      AudioFeedbackService.vibrate(15);
    }
  }

  void _updatePhysics() {
    setState(() {
      // Gravity
      velY += 0.0016;
      playerY += velY;

      if (playerY >= groundY) {
        playerY = groundY;
        velY = 0;
        jumpCount = 0; // Reset jump on ground
      }

      // Move obstacles
      for (var obs in obstacles) {
        obs.x -= speed;

        // Collision Check (Player is around X=0.15)
        if (obs.x < 0.22 && obs.x > 0.08) {
          if (playerY > groundY - obs.height + 0.03) {
            _handleCrash();
            return;
          }
        }
      }

      // Move and collect gems
      for (var gem in gems) {
        gem.x -= speed;

        if (!gem.collected && (gem.x - 0.15).abs() < 0.08 && (playerY - gem.y).abs() < 0.12) {
          gem.collected = true;
          gemCount++;
          score += 25;
          AudioFeedbackService.playClick();
          AudioFeedbackService.vibrate(20);
          _checkLevelUp();
        }
      }

      // Recycle obstacles
      if (obstacles.first.x < -0.3) {
        obstacles.removeAt(0);
        score += 10;
        double nextX = obstacles.last.x + 0.8 + rng.nextDouble() * 0.4;
        double nextH = 0.12 + rng.nextDouble() * 0.12;
        obstacles.add(_Obstacle(x: nextX, height: nextH));
      }

      // Recycle gems
      gems.removeWhere((g) => g.x < -0.3);
      if (gems.length < 3) {
        double nextGemX = (obstacles.isNotEmpty ? obstacles.last.x : 1.5) + 0.4 + rng.nextDouble() * 0.5;
        double nextGemY = groundY - (0.08 + rng.nextDouble() * 0.20);
        gems.add(_Gem(x: nextGemX, y: nextGemY));
      }
    });
  }

  void _checkLevelUp() {
    if (currentLevel == 1 && gemCount >= 10) {
      _advanceLevel(2, "LEVEL 2: NEON SKYLINE! 🚀", 0.016);
    } else if (currentLevel == 2 && gemCount >= 25) {
      _advanceLevel(3, "LEVEL 3: HYPER OVERDRIVE! ⚡", 0.020);
    }
  }

  void _advanceLevel(int nextLevel, String message, double newSpeed) {
    currentLevel = nextLevel;
    speed = newSpeed;
    levelMessage = message;
    AudioFeedbackService.vibrate(70);
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => levelMessage = null);
    });
  }

  void _handleCrash() {
    _shakeKey.currentState?.shake();
    _cleanup();
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    StorageService.saveHighScore('endless_runner', score);
    AudioFeedbackService.vibrate(90);
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
      title: "Cyber Runner 2077 🏃‍♂️",
      onReset: _startGame,
      gameContent: ShakeWidget(
        key: _shakeKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _jump(),
              child: Stack(
                children: [
                  // Synthwave Neon Sky
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF3B0764), Color(0xFF831843)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Giant Glowing Synthwave Sun
                  Positioned(
                    top: 50,
                    right: w * 0.25,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDE047), Color(0xFFF43F5E)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.6), blurRadius: 30),
                        ],
                      ),
                    ),
                  ),

                  // Neon Ground Grid
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: h * (1.0 - groundY),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF030712),
                        border: const Border(top: BorderSide(color: Color(0xFF00E5FF), width: 3)),
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 18),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "━ ━ ━ ━ ━ ━ ━ ━ ━ ━ ━ ━ ━ ━ ━ ━",
                          style: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.3), fontSize: 20),
                        ),
                      ),
                    ),
                  ),

                  // Floating Collectible Gems
                  ...gems.where((g) => !g.collected).map((g) {
                    return Positioned(
                      left: g.x * w - 16,
                      top: g.y * h - 16,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amberAccent.withValues(alpha: 0.3),
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 10),
                          ],
                        ),
                        child: const Center(child: Text("💎", style: TextStyle(fontSize: 18))),
                      ),
                    );
                  }),

                  // Spikes / Laser Obstacles
                  ...obstacles.map((obs) {
                    final obsH = obs.height * h;
                    return Positioned(
                      left: obs.x * w - 18,
                      bottom: h * (1.0 - groundY),
                      width: 36,
                      height: obsH,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          border: Border.all(color: Colors.redAccent, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withValues(alpha: 0.7), blurRadius: 12),
                          ],
                        ),
                        child: const Center(
                          child: Text("⚡", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    );
                  }),

                  // Cyber Runner Player with Jetpack Flame
                  Positioned(
                    left: 0.15 * w - 24,
                    top: playerY * h - 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0284C7),
                            border: Border.all(color: Colors.cyanAccent, width: 2.5),
                            boxShadow: [
                              BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.8), blurRadius: 16),
                            ],
                          ),
                          child: const Center(
                            child: Text("🏃", style: TextStyle(fontSize: 26)),
                          ),
                        ),
                        if (jumpCount > 0)
                          Container(
                            width: 8,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: Colors.orange, blurRadius: 6)],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Top HUD: Level, Gems & Score
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
                            border: Border.all(color: Colors.cyanAccent),
                          ),
                          child: Text(
                            "LEVEL $currentLevel",
                            style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          "💎 $gemCount Gems",
                          style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Text(
                            "SCORE: $score",
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Double Jump Hint
                  if (isPlaying && !isGameOver)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "TAP TO JUMP • DOUBLE TAP FOR AIR JUMP 🚀",
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Level Up Floating Banner
                  if (levelMessage != null)
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
                          levelMessage!,
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.amberAccent),
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
                              const Text("💀", style: TextStyle(fontSize: 70)),
                              const SizedBox(height: 12),
                              Text("CYBER CRASH!", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                              const SizedBox(height: 8),
                              Text("Level $currentLevel • Gems: $gemCount • Score: $score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                                ),
                                child: Text("RUN AGAIN", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Start Screen
                  if (!isPlaying && !isGameOver)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: _startGame,
                            icon: const Icon(Icons.directions_run, color: Colors.black),
                            label: Text("START RUNNING", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
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
}

class _Obstacle {
  double x;
  final double height;
  _Obstacle({required this.x, required this.height});
}

class _Gem {
  double x;
  final double y;
  bool collected = false;
  _Gem({required this.x, required this.y});
}
