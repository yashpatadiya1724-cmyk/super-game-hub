import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';
import '../services/audio_feedback_service.dart';
import '../services/particle_service.dart';
import '../services/screen_juice_service.dart';

class _FruitPiece {
  double x, y, vx, vy, rotation;
  final String emoji;
  final bool isLeftHalf;
  _FruitPiece({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.emoji,
    required this.isLeftHalf,
  });
}

class _FlyingFruit {
  final int id;
  double x, y, vx, vy, rotation;
  final String emoji;
  final bool isBomb;
  final bool isGolden;
  bool isSliced = false;
  final Color juiceColor;

  _FlyingFruit({
    required this.id,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.emoji,
    this.isBomb = false,
    this.isGolden = false,
    required this.juiceColor,
  });
}

class FruitSlasherGame extends StatefulWidget {
  const FruitSlasherGame({super.key});

  @override
  State<FruitSlasherGame> createState() => _FruitSlasherGameState();
}

class _FruitSlasherGameState extends State<FruitSlasherGame> {
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  final List<String> fruitEmojis = ['🍉', '🍊', '🍎', '🍓', '🍍', '🥝', '🍇'];
  final Map<String, Color> fruitJuiceColors = {
    '🍉': Colors.redAccent,
    '🍊': Colors.orangeAccent,
    '🍎': Colors.red,
    '🍓': Colors.pinkAccent,
    '🍍': Colors.amberAccent,
    '🥝': Colors.lightGreenAccent,
    '🍇': Colors.purpleAccent,
  };

  List<_FlyingFruit> activeFruits = [];
  List<_FruitPiece> fruitPieces = [];
  List<GameParticle> particles = [];
  List<Offset> bladeTrail = [];

  int score = 0;
  int lives = 3;
  int currentLevel = 1;
  int fruitsSlicedInLevel = 0;
  bool isPlaying = false;
  bool isGameOver = false;
  bool isVictory = false;
  String? comboMessage;

  Timer? gameLoopTimer;
  Timer? spawnTimer;
  final Random rng = Random();

  int currentComboCount = 0;
  DateTime lastSliceTime = DateTime.now();

  int get targetSlicesForLevel {
    if (currentLevel == 1) return 15;
    if (currentLevel == 2) return 25;
    return 35;
  }

  void _startGame() {
    _cleanup();
    setState(() {
      activeFruits.clear();
      fruitPieces.clear();
      particles.clear();
      bladeTrail.clear();
      score = 0;
      lives = 3;
      currentLevel = 1;
      fruitsSlicedInLevel = 0;
      isPlaying = true;
      isGameOver = false;
      isVictory = false;
      comboMessage = null;
    });

    _startSpawning();
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      _updatePhysics();
    });
  }

  void _startSpawning() {
    spawnTimer?.cancel();
    int intervalMs = currentLevel == 1 ? 1100 : (currentLevel == 2 ? 850 : 650);
    spawnTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!isPlaying || isGameOver || isVictory) return;
      _spawnWave();
    });
  }

  void _spawnWave() {
    int count = currentLevel == 1 ? (rng.nextBool() ? 1 : 2) : (rng.nextInt(3) + 1);
    for (int i = 0; i < count; i++) {
      bool isBomb = currentLevel > 1 && rng.nextInt(5) == 0;
      bool isGolden = !isBomb && currentLevel >= 2 && rng.nextInt(6) == 0;
      String emoji = isBomb ? '💣' : (isGolden ? '🍍' : fruitEmojis[rng.nextInt(fruitEmojis.length)]);
      Color juiceColor = isBomb ? Colors.grey : (isGolden ? Colors.amberAccent : fruitJuiceColors[emoji] ?? Colors.red);

      double startX = 0.15 + rng.nextDouble() * 0.7;
      double startY = 1.05;
      double vy = -(0.019 + rng.nextDouble() * 0.006);
      double vx = (0.5 - startX) * 0.008 + (rng.nextDouble() - 0.5) * 0.004;

      activeFruits.add(_FlyingFruit(
        id: DateTime.now().microsecondsSinceEpoch + i,
        x: startX,
        y: startY,
        vx: vx,
        vy: vy,
        rotation: 0.0,
        emoji: emoji,
        isBomb: isBomb,
        isGolden: isGolden,
        juiceColor: juiceColor,
      ));
    }
  }

  void _updatePhysics() {
    setState(() {
      // Fade blade trail
      if (bladeTrail.isNotEmpty) {
        bladeTrail.removeAt(0);
      }

      // Update active whole fruits
      for (var f in activeFruits) {
        f.x += f.vx;
        f.y += f.vy;
        f.vy += 0.00045; // Gravity
        f.rotation += 0.04;
      }

      // Check missed fruits (deduct life in level 1 & 2 if missed, but not for bombs)
      for (var f in activeFruits) {
        if (f.y > 1.15 && !f.isSliced && !f.isBomb) {
          lives--;
          AudioFeedbackService.vibrate(30);
          if (lives <= 0) {
            _handleGameOver();
            return;
          }
        }
      }
      activeFruits.removeWhere((f) => f.y > 1.18);

      // Update sliced half pieces
      for (var p in fruitPieces) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.0006;
        p.rotation += (p.isLeftHalf ? -0.1 : 0.1);
      }
      fruitPieces.removeWhere((p) => p.y > 1.2);

      // Update particles
      particles.removeWhere((p) => !p.update());
    });
  }

  void _handleSlice(Offset touchPos, Size size) {
    if (!isPlaying || isGameOver || isVictory) return;
    bladeTrail.add(touchPos);
    if (bladeTrail.length > 8) bladeTrail.removeAt(0);

    final normalizedTouch = Offset(touchPos.dx / size.width, touchPos.dy / size.height);

    for (var f in activeFruits) {
      if (f.isSliced) continue;
      double dist = (Offset(f.x, f.y) - normalizedTouch).distance;
      if (dist < 0.08) {
        f.isSliced = true;

        if (f.isBomb) {
          // Hit Bomb!
          _shakeKey.currentState?.shake();
          AudioFeedbackService.vibrate(90);
          _spawnParticles(touchPos.dx, touchPos.dy, Colors.orange, 30);
          lives -= 2;
          if (lives <= 0) {
            _handleGameOver();
            return;
          }
        } else {
          // Sliced Fruit!
          AudioFeedbackService.playClick();
          AudioFeedbackService.vibrate(20);
          _spawnParticles(touchPos.dx, touchPos.dy, f.juiceColor, 20);

          // Split into two halves
          fruitPieces.add(_FruitPiece(
            x: f.x - 0.02,
            y: f.y,
            vx: f.vx - 0.006,
            vy: f.vy - 0.003,
            rotation: f.rotation,
            emoji: f.emoji,
            isLeftHalf: true,
          ));
          fruitPieces.add(_FruitPiece(
            x: f.x + 0.02,
            y: f.y,
            vx: f.vx + 0.006,
            vy: f.vy - 0.003,
            rotation: f.rotation,
            emoji: f.emoji,
            isLeftHalf: false,
          ));

          // Combo tracking
          final now = DateTime.now();
          if (now.difference(lastSliceTime).inMilliseconds < 350) {
            currentComboCount++;
          } else {
            currentComboCount = 1;
          }
          lastSliceTime = now;

          int basePoints = f.isGolden ? 50 : 15;
          if (currentComboCount >= 3) {
            int bonus = currentComboCount * 10;
            score += basePoints + bonus;
            _showCombo("🔥 ${currentComboCount}x COMBO! +$bonus");
          } else {
            score += basePoints;
          }

          fruitsSlicedInLevel++;
          if (fruitsSlicedInLevel >= targetSlicesForLevel) {
            _advanceLevel();
          }
        }
      }
    }
  }

  void _showCombo(String text) {
    setState(() => comboMessage = text);
    AudioFeedbackService.vibrate(40);
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => comboMessage = null);
    });
  }

  void _advanceLevel() {
    if (currentLevel < 3) {
      currentLevel++;
      fruitsSlicedInLevel = 0;
      _showCombo("LEVEL $currentLevel UNLOCKED! ⚔️");
      _startSpawning();
    } else {
      isVictory = true;
      isPlaying = false;
      _cleanup();
      StorageService.saveHighScore('fruit_slasher', score);
      AudioFeedbackService.vibrate(100);
    }
  }

  void _spawnParticles(double px, double py, Color color, int count) {
    for (int i = 0; i < count; i++) {
      double angle = rng.nextDouble() * 2 * pi;
      double speed = 2.0 + rng.nextDouble() * 5.0;
      particles.add(GameParticle(
        x: px,
        y: py,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 3.0 + rng.nextDouble() * 5.0,
        color: color,
        lifeDecay: 0.04,
      ));
    }
  }

  void _handleGameOver() {
    _cleanup();
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    StorageService.saveHighScore('fruit_slasher', score);
    AudioFeedbackService.vibrate(80);
  }

  void _cleanup() {
    gameLoopTimer?.cancel();
    spawnTimer?.cancel();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Fruit Ninja Blade 🍉",
      onReset: _startGame,
      gameContent: ShakeWidget(
        key: _shakeKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => _handleSlice(d.localPosition, Size(w, h)),
              child: Stack(
                children: [
                  // Cyber Dojo Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF311042)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),

                  // Top HUD: Level, Slices, Lives & Score
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
                            border: Border.all(color: Colors.pinkAccent),
                          ),
                          child: Text(
                            "LEVEL $currentLevel/3",
                            style: GoogleFonts.outfit(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          "SCORE: $score",
                          style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                        Row(
                          children: List.generate(
                            3,
                            (i) => Icon(
                              Icons.favorite,
                              color: i < lives ? Colors.redAccent : Colors.white24,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Whole Flying Fruits
                  ...activeFruits.where((f) => !f.isSliced).map((f) {
                    return Positioned(
                      left: f.x * w - 30,
                      top: f.y * h - 30,
                      child: Transform.rotate(
                        angle: f.rotation,
                        child: Text(
                          f.emoji,
                          style: TextStyle(
                            fontSize: f.isGolden ? 52 : 46,
                            shadows: f.isGolden
                                ? [const Shadow(color: Colors.amber, blurRadius: 20)]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Sliced Half Pieces (Flying Apart)
                  ...fruitPieces.map((p) {
                    return Positioned(
                      left: p.x * w - 24,
                      top: p.y * h - 24,
                      child: Transform.rotate(
                        angle: p.rotation,
                        child: ClipRect(
                          child: Align(
                            alignment: p.isLeftHalf ? Alignment.centerLeft : Alignment.centerRight,
                            widthFactor: 0.5,
                            child: Text(p.emoji, style: const TextStyle(fontSize: 44)),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Particle Splash Effects
                  CustomPaint(
                    size: Size(w, h),
                    painter: ParticlePainter(particles),
                  ),

                  // Katana Glowing Blade Trail
                  CustomPaint(
                    size: Size(w, h),
                    painter: _BladeTrailPainter(bladeTrail),
                  ),

                  // Floating Combo Banner
                  if (comboMessage != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amberAccent, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.amber.withValues(alpha: 0.8), blurRadius: 25),
                          ],
                        ),
                        child: Text(
                          comboMessage!,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.amberAccent,
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
                              const Text("🥷", style: TextStyle(fontSize: 70)),
                              const SizedBox(height: 12),
                              Text(
                                "FRUIT NINJA MASTER!",
                                style: GoogleFonts.outfit(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amberAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("All 3 Levels Sliced • Score: $score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
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
                              Text(
                                "OUT OF LIVES!",
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
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
                                child: Text(
                                  "TRY AGAIN",
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
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
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: _startGame,
                            icon: const Icon(Icons.flash_on, color: Colors.black),
                            label: Text(
                              "START SLICING",
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BladeTrailPainter extends CustomPainter {
  final List<Offset> points;
  _BladeTrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      double factor = (i + 1) / points.length;
      final paint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: factor * 0.9)
        ..strokeWidth = 4.0 + (factor * 6.0)
        ..strokeCap = StrokeCap.round;

      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: factor * 0.7)
        ..strokeWidth = 2.0 + (factor * 3.0)
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(points[i], points[i + 1], paint);
      canvas.drawLine(points[i], points[i + 1], glowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
