import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';
import '../../services/audio_feedback_service.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> with SingleTickerProviderStateMixin {
  static const int rowCount = 20;
  static const int colCount = 20;

  List<int> snake = [45, 65, 85];
  int food = 100;
  bool isGoldenFood = false;
  var direction = 'down';
  bool isPlaying = false;
  bool isGameOver = false;
  bool isVictory = false;

  int score = 0;
  int currentLevel = 1;
  int levelApplesEaten = 0;
  String? levelUpMessage;

  final Set<int> obstacles = {};
  Timer? timer;

  late AnimationController _foodController;
  late Animation<double> _foodAnimation;

  @override
  void initState() {
    super.initState();
    _foodController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _foodAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _foodController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _foodController.dispose();
    super.dispose();
  }

  int get targetApplesForLevel {
    if (currentLevel == 1) return 6;
    if (currentLevel == 2) return 8;
    return 10;
  }

  int get speedForLevel {
    if (currentLevel == 1) return 150;
    if (currentLevel == 2) return 120;
    return 95;
  }

  void _setupObstacles(int level) {
    obstacles.clear();
    if (level == 3) {
      // 4 interior pillar obstacles
      obstacles.addAll([
        (5 * colCount) + 5,
        (5 * colCount) + 6,
        (6 * colCount) + 5,
        (6 * colCount) + 6,
        (5 * colCount) + 13,
        (5 * colCount) + 14,
        (6 * colCount) + 13,
        (6 * colCount) + 14,
        (13 * colCount) + 5,
        (13 * colCount) + 6,
        (14 * colCount) + 5,
        (14 * colCount) + 6,
        (13 * colCount) + 13,
        (13 * colCount) + 14,
        (14 * colCount) + 13,
        (14 * colCount) + 14,
      ]);
    }
  }

  void _startGame() {
    timer?.cancel();
    setState(() {
      isPlaying = true;
      isGameOver = false;
      isVictory = false;
      score = 0;
      currentLevel = 1;
      levelApplesEaten = 0;
      snake = [45, 65, 85];
      direction = 'down';
      levelUpMessage = null;
      _setupObstacles(1);
      _generateFood();
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: speedForLevel), (_) {
      if (!mounted) return;
      _updateGame();
    });
  }

  void _generateFood() {
    final rnd = Random();
    int newFood;
    do {
      newFood = rnd.nextInt(rowCount * colCount);
    } while (snake.contains(newFood) || obstacles.contains(newFood));

    food = newFood;
    isGoldenFood = currentLevel >= 2 && rnd.nextInt(4) == 0;
  }

  void _updateGame() {
    setState(() {
      int head = snake.last;
      int newHead;

      int row = head ~/ colCount;
      int col = head % colCount;

      switch (direction) {
        case 'down':
          if (row == rowCount - 1) {
            if (currentLevel >= 2) {
              _handleGameOver();
              return;
            }
            newHead = col;
          } else {
            newHead = head + colCount;
          }
          break;
        case 'up':
          if (row == 0) {
            if (currentLevel >= 2) {
              _handleGameOver();
              return;
            }
            newHead = (rowCount - 1) * colCount + col;
          } else {
            newHead = head - colCount;
          }
          break;
        case 'left':
          if (col == 0) {
            if (currentLevel >= 2) {
              _handleGameOver();
              return;
            }
            newHead = head + colCount - 1;
          } else {
            newHead = head - 1;
          }
          break;
        case 'right':
          if (col == colCount - 1) {
            if (currentLevel >= 2) {
              _handleGameOver();
              return;
            }
            newHead = head - colCount + 1;
          } else {
            newHead = head + 1;
          }
          break;
        default:
          newHead = head;
      }

      // Self-collision or Obstacle collision
      if (snake.contains(newHead) || obstacles.contains(newHead)) {
        _handleGameOver();
        return;
      }

      snake.add(newHead);

      // Eat Food
      if (newHead == food) {
        int points = isGoldenFood ? 30 : 10;
        score += points;
        levelApplesEaten++;
        AudioFeedbackService.playClick();
        AudioFeedbackService.vibrate(20);

        if (levelApplesEaten >= targetApplesForLevel) {
          _advanceLevel();
        } else {
          _generateFood();
        }
      } else {
        snake.removeAt(0);
      }
    });
  }

  void _advanceLevel() {
    if (currentLevel < 3) {
      currentLevel++;
      levelApplesEaten = 0;
      levelUpMessage = "LEVEL $currentLevel UNLOCKED!";
      _setupObstacles(currentLevel);
      _generateFood();
      _startTimer();
      AudioFeedbackService.vibrate(70);

      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => levelUpMessage = null);
      });
    } else {
      isVictory = true;
      isPlaying = false;
      timer?.cancel();
      StorageService.saveHighScore('snake', score);
      AudioFeedbackService.vibrate(100);
    }
  }

  void _handleGameOver() {
    timer?.cancel();
    isPlaying = false;
    isGameOver = true;
    StorageService.saveHighScore('snake', score);
    AudioFeedbackService.vibrate(80);
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Snake Championship 🐍",
      onReset: _startGame,
      gameContent: Column(
        children: [
          // Top HUD: Level, Progress & Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Text(
                    "LEVEL $currentLevel",
                    style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "Apples: $levelApplesEaten/$targetApplesForLevel 🍏",
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "SCORE: $score",
                  style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),

          // Main Game Board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    if (direction != 'up' && details.delta.dy > 0) direction = 'down';
                    if (direction != 'down' && details.delta.dy < 0) direction = 'up';
                  },
                  onHorizontalDragUpdate: (details) {
                    if (direction != 'left' && details.delta.dx > 0) direction = 'right';
                    if (direction != 'right' && details.delta.dx < 0) direction = 'left';
                  },
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: currentLevel >= 2 ? Colors.redAccent.withValues(alpha: 0.8) : Colors.greenAccent.withValues(alpha: 0.5),
                        width: currentLevel >= 2 ? 3 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (currentLevel >= 2 ? Colors.red : Colors.green).withValues(alpha: 0.2),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: colCount,
                          ),
                          itemCount: rowCount * colCount,
                          itemBuilder: (context, index) {
                            if (snake.contains(index)) {
                              bool isHead = index == snake.last;
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: isHead ? Colors.greenAccent : Colors.green.shade600,
                                  shape: isHead ? BoxShape.circle : BoxShape.rectangle,
                                  borderRadius: isHead ? null : BorderRadius.circular(4),
                                  boxShadow: isHead
                                      ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.8), blurRadius: 8)]
                                      : null,
                                ),
                                child: isHead
                                    ? const Center(
                                        child: Text("👀", style: TextStyle(fontSize: 10)),
                                      )
                                    : null,
                              );
                            } else if (index == food) {
                              return ScaleTransition(
                                scale: _foodAnimation,
                                child: Center(
                                  child: Text(
                                    isGoldenFood ? "⭐" : "🍎",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            } else if (obstacles.contains(index)) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade900,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Colors.purpleAccent, width: 1),
                                ),
                                child: const Center(
                                  child: Text("🧱", style: TextStyle(fontSize: 8)),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),

                        // Level Up Floating Message
                        if (levelUpMessage != null)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amberAccent, width: 2),
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

                        // Start / Victory / Game Over Overlay
                        if (!isPlaying && !isGameOver && !isVictory)
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow),
                              label: Text(
                                "START GAME",
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              ),
                            ),
                          ),

                        if (isVictory)
                          Container(
                            color: Colors.black87,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("👑", style: TextStyle(fontSize: 60)),
                                  const SizedBox(height: 8),
                                  Text(
                                    "SNAKE MASTER!",
                                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.amberAccent),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("All Levels Complete • Score: $score", style: GoogleFonts.outfit(color: Colors.white70)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _startGame,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                                    child: const Text("PLAY AGAIN"),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (isGameOver)
                          Container(
                            color: Colors.black87,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cancel, size: 60, color: Colors.redAccent),
                                  const SizedBox(height: 8),
                                  Text(
                                    "GAME OVER",
                                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Reached Level $currentLevel • Score: $score", style: GoogleFonts.outfit(color: Colors.white70)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _startGame,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                    child: const Text("RETRY"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Virtual D-Pad for easy mobile steering
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDpadBtn(Icons.arrow_upward, () {
                  if (direction != 'down') direction = 'up';
                }),
                const SizedBox(width: 8),
                _buildDpadBtn(Icons.arrow_back, () {
                  if (direction != 'right') direction = 'left';
                }),
                const SizedBox(width: 8),
                _buildDpadBtn(Icons.arrow_downward, () {
                  if (direction != 'up') direction = 'down';
                }),
                const SizedBox(width: 8),
                _buildDpadBtn(Icons.arrow_forward, () {
                  if (direction != 'left') direction = 'right';
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpadBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioFeedbackService.playClick();
        onTap();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
