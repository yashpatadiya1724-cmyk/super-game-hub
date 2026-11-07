import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> with SingleTickerProviderStateMixin {
  static const int rowCount = 20;
  static const int colCount = 20;
  static const int speed = 150; // Faster speed for v3

  List<int> snake = [45, 65, 85];
  int food = 100;
  var direction = 'down';
  bool isPlaying = false;
  int score = 0;
  Timer? timer;
  
  late AnimationController _foodController;
  late Animation<double> _foodAnimation;

  @override
  void initState() {
    super.initState();
    _foodController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _foodAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _foodController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _foodController.dispose();
    super.dispose();
  }

  void _startGame() {
    isPlaying = true;
    score = 0;
    snake = [45, 65, 85];
    direction = 'down';
    _generateFood();
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: speed), (timer) {
      _updateGame();
    });
  }

  void _generateFood() {
    food = Random().nextInt(rowCount * colCount);
  }

  void _updateGame() {
    setState(() {
      switch (direction) {
        case 'down':
          if (snake.last >= rowCount * (colCount - 1)) {
            snake.add(snake.last + colCount - rowCount * colCount);
          } else {
            snake.add(snake.last + colCount);
          }
          break;
        case 'up':
          if (snake.last < colCount) {
            snake.add(snake.last - colCount + rowCount * colCount);
          } else {
            snake.add(snake.last - colCount);
          }
          break;
        case 'left':
          if (snake.last % colCount == 0) {
            snake.add(snake.last - 1 + colCount);
          } else {
            snake.add(snake.last - 1);
          }
          break;
        case 'right':
          if ((snake.last + 1) % colCount == 0) {
            snake.add(snake.last + 1 - colCount);
          } else {
            snake.add(snake.last + 1);
          }
          break;
      }

      if (snake.last == food) {
        score++;
        _generateFood();
      } else {
        snake.removeAt(0);
      }

      if (_checkGameOver()) {
        timer?.cancel();
        isPlaying = false;
        StorageService.saveHighScore('snake', score);
        _showGameOverDialog();
      }
    });
  }

  bool _checkGameOver() {
    for (int i = 0; i < snake.length - 1; i++) {
      if (snake[i] == snake.last) return true;
    }
    return false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Game Over", style: GoogleFonts.outfit(color: Colors.white)),
        content: Text("Your score: $score", style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Restart"),
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Snake",
      onReset: _startGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Score: $score", style: GoogleFonts.outfit(fontSize: 24, color: Colors.white)),
                Text("Best: ${StorageService.getHighScore('snake')}", style: GoogleFonts.outfit(fontSize: 24, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) direction = 'down';
                if (direction != 'down' && details.delta.dy < 0) direction = 'up';
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) direction = 'right';
                if (direction != 'right' && details.delta.dx < 0) direction = 'left';
              },
              child: AspectRatio(
                aspectRatio: rowCount / colCount,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Grid background lines for Cyber Look
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GridPainter(rowCount, colCount),
                        ),
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowCount,
                        ),
                        itemCount: rowCount * colCount,
                        itemBuilder: (context, index) {
                          if (snake.contains(index)) {
                            bool isHead = index == snake.last;
                            return Center(
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isHead 
                                      ? [Colors.cyanAccent, Colors.blueAccent]
                                      : [Colors.blueAccent.withValues(alpha: 0.8), Colors.blueAccent.withValues(alpha: 0.4)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: isHead ? [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ] : [],
                                ),
                              ),
                            );
                          }
                          if (index == food) {
                            return ScaleTransition(
                              scale: _foodAnimation,
                              child: Center(
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text("Start Game", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int rows;
  final int cols;
  GridPainter(this.rows, this.cols);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    double cellWidth = size.width / cols;
    double cellHeight = size.height / rows;

    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(Offset(i * cellWidth, 0), Offset(i * cellWidth, size.height), paint);
    }
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(Offset(0, i * cellHeight), Offset(size.width, i * cellHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
