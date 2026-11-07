import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';
import '../../services/audio_feedback_service.dart';

class SpaceShooterGame extends StatefulWidget {
  const SpaceShooterGame({super.key});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame> with TickerProviderStateMixin {
  // Player
  double playerX = 0; // -1.0 to 1.0
  double playerY = 0.82;

  // Bullets
  List<Point<double>> bullets = [];

  // Enemies / Asteroids
  List<_SpaceEnemy> enemies = [];

  // Boss
  bool isBossActive = false;
  double bossX = 0.0;
  double bossHp = 100.0;
  double bossMaxHp = 100.0;
  double bossDir = 0.015;
  List<Point<double>> bossBullets = [];

  // Level & Progression
  int currentLevel = 1;
  int score = 0;
  bool hasStarted = false;
  bool isGameOver = false;
  bool isVictory = false;
  String? levelUpMessage;

  Timer? gameLoopTimer;
  Timer? enemySpawnTimer;
  Timer? bossAttackTimer;

  // Starfield
  final List<Point<double>> stars = List.generate(
    40,
    (_) => Point(Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1),
  );

  void _startGame() {
    _cleanupTimers();
    setState(() {
      hasStarted = true;
      isGameOver = false;
      isVictory = false;
      currentLevel = 1;
      score = 0;
      playerX = 0;
      bullets.clear();
      enemies.clear();
      bossBullets.clear();
      isBossActive = false;
      bossHp = 100.0;
      levelUpMessage = null;
    });

    // Main 60FPS Game Loop
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      _updateGame();
    });

    // Enemy Spawner
    _startSpawner();
  }

  void _startSpawner() {
    enemySpawnTimer?.cancel();
    int intervalMs = currentLevel == 1 ? 1400 : (currentLevel == 2 ? 1000 : 1600);
    enemySpawnTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!hasStarted || isGameOver || isVictory) return;
      if (currentLevel == 3 && isBossActive) return;

      setState(() {
        final rnd = Random();
        double startX = -0.85 + rnd.nextDouble() * 1.7;
        String type = currentLevel == 1 ? 'asteroid' : 'alien';
        double speed = currentLevel == 1 ? 0.012 : 0.018;
        enemies.add(_SpaceEnemy(
          pos: Point(startX, -1.1),
          type: type,
          hp: currentLevel == 1 ? 1 : 2,
          speed: speed,
        ));
      });
    });
  }

  void _updateGame() {
    setState(() {
      // Move Stars (Parallax)
      for (int i = 0; i < stars.length; i++) {
        double newY = stars[i].y + 0.015;
        if (newY > 1.0) newY = -1.0;
        stars[i] = Point(stars[i].x, newY);
      }

      // Move Player Bullets
      bullets = bullets
          .map((b) => Point(b.x, b.y - 0.045))
          .where((b) => b.y > -1.1)
          .toList();

      // Move Enemies
      for (var e in enemies) {
        e.pos = Point(e.pos.x, e.pos.y + e.speed);
      }
      enemies.removeWhere((e) => e.pos.y > 1.1);

      // Check Bullet collisions with regular enemies
      for (int i = bullets.length - 1; i >= 0; i--) {
        for (int j = enemies.length - 1; j >= 0; j--) {
          if ((bullets[i].x - enemies[j].pos.x).abs() < 0.16 &&
              (bullets[i].y - enemies[j].pos.y).abs() < 0.1) {
            bullets.removeAt(i);
            enemies[j].hp--;
            AudioFeedbackService.playClick();
            if (enemies[j].hp <= 0) {
              score += enemies[j].type == 'asteroid' ? 25 : 50;
              enemies.removeAt(j);
              AudioFeedbackService.vibrate(20);
              _checkLevelProgression();
            }
            break;
          }
        }
      }

      // Boss Mechanics (Level 3)
      if (currentLevel == 3 && isBossActive) {
        bossX += bossDir;
        if (bossX >= 0.7 || bossX <= -0.7) {
          bossDir = -bossDir;
        }

        // Move Boss Bullets
        bossBullets = bossBullets
            .map((b) => Point(b.x, b.y + 0.025))
            .where((b) => b.y < 1.1)
            .toList();

        // Check player bullets hitting boss
        for (int i = bullets.length - 1; i >= 0; i--) {
          if ((bullets[i].x - bossX).abs() < 0.32 && bullets[i].y <= -0.5) {
            bullets.removeAt(i);
            bossHp -= 4.0;
            AudioFeedbackService.vibrate(20);
            if (bossHp <= 0) {
              bossHp = 0;
              isBossActive = false;
              isVictory = true;
              score += 500;
              _cleanupTimers();
              StorageService.saveHighScore('space_shooter', score);
              AudioFeedbackService.vibrate(100);
            }
            break;
          }
        }

        // Boss bullets hitting player
        for (var b in bossBullets) {
          if ((b.x - playerX).abs() < 0.16 && (b.y - playerY).abs() < 0.08) {
            _handleGameOver();
            return;
          }
        }
      }

      // Check Enemy collision with player
      for (var e in enemies) {
        if ((e.pos.x - playerX).abs() < 0.16 && (e.pos.y - playerY).abs() < 0.08) {
          _handleGameOver();
          return;
        }
      }
    });
  }

  void _checkLevelProgression() {
    if (currentLevel == 1 && score >= 200) {
      _advanceToLevel(2, "LEVEL 2: ALIEN SQUADRON!");
    } else if (currentLevel == 2 && score >= 500) {
      _advanceToLevel(3, "LEVEL 3: MOTHERSHIP BOSS!");
    }
  }

  void _advanceToLevel(int nextLevel, String message) {
    setState(() {
      currentLevel = nextLevel;
      levelUpMessage = message;
      enemies.clear();
      if (nextLevel == 3) {
        isBossActive = true;
        _startBossBehavior();
      }
    });
    AudioFeedbackService.vibrate(70);
    _startSpawner();

    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => levelUpMessage = null);
    });
  }

  void _startBossBehavior() {
    bossAttackTimer?.cancel();
    bossAttackTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!isBossActive || isGameOver || isVictory) return;
      setState(() {
        bossBullets.add(Point(bossX - 0.1, -0.5));
        bossBullets.add(Point(bossX + 0.1, -0.5));
      });
      AudioFeedbackService.playClick();
    });
  }

  void _handleGameOver() {
    _cleanupTimers();
    setState(() {
      isGameOver = true;
    });
    StorageService.saveHighScore('space_shooter', score);
    AudioFeedbackService.vibrate(80);
  }

  void _cleanupTimers() {
    gameLoopTimer?.cancel();
    enemySpawnTimer?.cancel();
    bossAttackTimer?.cancel();
  }

  void _shoot() {
    if (!hasStarted || isGameOver || isVictory) return;
    setState(() {
      bullets.add(Point(playerX - 0.06, playerY));
      bullets.add(Point(playerX + 0.06, playerY));
    });
    AudioFeedbackService.playClick();
  }

  @override
  void dispose() {
    _cleanupTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Space Defender Galaxy 🚀",
      onReset: _startGame,
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) {
              if (!hasStarted || isGameOver || isVictory) return;
              setState(() {
                playerX = ((details.localPosition.dx / w) * 2 - 1).clamp(-0.85, 0.85);
              });
            },
            onTapDown: (_) => _shoot(),
            child: Stack(
              children: [
                // Deep Space Background
                Container(
                  color: const Color(0xFF030712),
                ),

                // Twinkling Parallax Starfield
                ...stars.map((s) => Positioned(
                      left: (s.x + 1) / 2 * w,
                      top: (s.y + 1) / 2 * h,
                      child: Container(
                        width: 2.5,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )),

                // Player Bullets (Neon Blue Laser Bolts)
                ...bullets.map((b) => Positioned(
                      left: (b.x + 1) / 2 * w - 3,
                      top: (b.y + 1) / 2 * h - 10,
                      child: Container(
                        width: 6,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    )),

                // Boss Bullets (Red Laser Bolts)
                ...bossBullets.map((b) => Positioned(
                      left: (b.x + 1) / 2 * w - 4,
                      top: (b.y + 1) / 2 * h,
                      child: Container(
                        width: 8,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    )),

                // Enemies / Asteroids
                ...enemies.map((e) {
                  final ex = (e.pos.x + 1) / 2 * w;
                  final ey = (e.pos.y + 1) / 2 * h;
                  return Positioned(
                    left: ex - 22,
                    top: ey - 22,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.type == 'asteroid' ? const Color(0xFF78350F) : const Color(0xFF9333EA),
                        border: Border.all(
                          color: e.type == 'asteroid' ? Colors.amber : Colors.purpleAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (e.type == 'asteroid' ? Colors.orange : Colors.purple).withValues(alpha: 0.6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          e.type == 'asteroid' ? '🪨' : '👾',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }),

                // Level 3 Boss Mothership
                if (isBossActive)
                  Positioned(
                    left: (bossX + 1) / 2 * w - 60,
                    top: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Boss Health Bar
                        Container(
                          width: 120,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (bossHp / bossMaxHp).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFF4C0519)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.amberAccent, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.red.withValues(alpha: 0.8), blurRadius: 20),
                            ],
                          ),
                          child: const Center(
                            child: Text('🛸 MOTHERSHIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Player Ship
                Positioned(
                  left: (playerX + 1) / 2 * w - 28,
                  top: (playerY + 1) / 2 * h - 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyanAccent, width: 2.5),
                          boxShadow: [
                            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.8), blurRadius: 18),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.rocket_launch, color: Colors.white, size: 34),
                        ),
                      ),
                      // Thruster Fire
                      Container(
                        width: 10,
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amberAccent, Colors.redAccent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(color: Colors.orange.withValues(alpha: 0.8), blurRadius: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top HUD: Level Badge & Score
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
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.cyanAccent),
                        ),
                        child: Text(
                          "LEVEL $currentLevel",
                          style: GoogleFonts.outfit(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amberAccent),
                        ),
                        child: Text(
                          "SCORE: $score",
                          style: GoogleFonts.outfit(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Level-Up Floating Banner
                if (levelUpMessage != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amberAccent, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 30),
                        ],
                      ),
                      child: Text(
                        levelUpMessage!,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ),

                // Tap to shoot hint on bottom
                if (hasStarted && !isGameOver && !isVictory)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "DRAG TO MOVE • TAP TO SHOOT",
                        style: GoogleFonts.outfit(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
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
                            const Text("🌟", style: TextStyle(fontSize: 70)),
                            const SizedBox(height: 12),
                            Text(
                              "GALAXY SAVED!",
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.amberAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Mothership Destroyed • Score: $score",
                              style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
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

                // Game Over Screen
                if (isGameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.dangerous, size: 70, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text(
                              "SHIP DESTROYED",
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Level $currentLevel • Final Score: $score",
                              style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                              ),
                              child: Text(
                                "TRY AGAIN",
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Initial Start Screen
                if (!hasStarted)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.75),
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: _startGame,
                          icon: const Icon(Icons.rocket_launch),
                          label: Text(
                            "START MISSION",
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                          ),
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
    );
  }
}

class _SpaceEnemy {
  Point<double> pos;
  final String type; // 'asteroid' or 'alien'
  int hp;
  final double speed;
  _SpaceEnemy({required this.pos, required this.type, required this.hp, required this.speed});
}
