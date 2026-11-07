import 'dart:async';
import 'package:flutter/material.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class BrickBreakerGame extends StatefulWidget {
  const BrickBreakerGame({super.key});

  @override
  State<BrickBreakerGame> createState() => _BrickBreakerGameState();
}

class _BrickBreakerGameState extends State<BrickBreakerGame> {
  // Ball coordinates
  double ballX = 0;
  double ballY = 0;
  double ballXDir = 0.01;
  double ballYDir = 0.01;

  // Paddle coordinates
  double paddleX = 0;
  double paddleWidth = 0.4;

  // Game state
  bool hasGameStarted = false;
  int score = 0;

  // Bricks
  static const int bricksPerRow = 5;
  static const int brickRows = 3;
  List<List<bool>> bricks = List.generate(brickRows, (_) => List.filled(bricksPerRow, true));

  void startGame() {
    hasGameStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _updateBall();

      if (_checkGameOver()) {
        timer.cancel();
        _showGameOverDialog();
      }

      _checkBrickCollision();
    });
  }

  void _updateBall() {
    setState(() {
      ballX += ballXDir;
      ballY += ballYDir;
    });

    // Wall collisions
    if (ballX >= 1 || ballX <= -1) ballXDir = -ballXDir;
    if (ballY <= -1) ballYDir = -ballYDir;

    // Paddle collision
    if (ballY >= 0.9 && ballX >= paddleX - paddleWidth / 2 && ballX <= paddleX + paddleWidth / 2) {
      ballYDir = -ballYDir;
    }
  }

  void _checkBrickCollision() {
    for (int i = 0; i < brickRows; i++) {
      for (int j = 0; j < bricksPerRow; j++) {
        if (bricks[i][j]) {
          double brickX = -1 + (j * 0.4) + 0.2;
          double brickY = -0.8 + (i * 0.1);
          if (ballX >= brickX - 0.2 && ballX <= brickX + 0.2 && ballY >= brickY - 0.05 && ballY <= brickY + 0.05) {
            setState(() {
              bricks[i][j] = false;
              ballYDir = -ballYDir;
              score += 10;
            });
            if (_checkWin()) {
              // Handle win
            }
          }
        }
      }
    }
  }

  bool _checkWin() {
    for (var row in bricks) {
      if (row.contains(true)) return false;
    }
    return true;
  }

  bool _checkGameOver() {
    if (ballY >= 1) return true;
    return false;
  }

  void _showGameOverDialog() {
    hasGameStarted = false;
    StorageService.saveHighScore('brick_breaker', score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple,
        title: const Text("GAME OVER", style: TextStyle(color: Colors.white)),
        content: Text("Score: $score", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("RETRY", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      ballX = 0;
      ballY = 0;
      paddleX = 0;
      bricks = List.generate(brickRows, (_) => List.filled(bricksPerRow, true));
      hasGameStarted = false;
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Brick Breaker",
      onReset: _resetGame,
      gameContent: GestureDetector(
        onTap: hasGameStarted ? null : startGame,
        onHorizontalDragUpdate: (details) {
          setState(() {
            paddleX += details.delta.dx / (MediaQuery.of(context).size.width / 2);
            if (paddleX < -1 + paddleWidth / 2) paddleX = -1 + paddleWidth / 2;
            if (paddleX > 1 - paddleWidth / 2) paddleX = 1 - paddleWidth / 2;
          });
        },
        child: Container(
          color: Colors.grey[900],
          child: Stack(
            children: [
              // Ball
              Container(
                alignment: Alignment(ballX, ballY),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),

              // Paddle
              Container(
                alignment: Alignment(paddleX, 0.95),
                child: Container(
                  width: MediaQuery.of(context).size.width * paddleWidth / 2,
                  height: 15,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                ),
              ),

              // Bricks
              for (int i = 0; i < brickRows; i++)
                for (int j = 0; j < bricksPerRow; j++)
                  if (bricks[i][j])
                    Container(
                      alignment: Alignment(-1 + (j * 0.4) + 0.2, -0.8 + (i * 0.1)),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.18,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.purple[300 + (i * 100)],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

              if (!hasGameStarted)
                const Center(
                  child: Text("T A P  T O  P L A Y", style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 5)),
                ),
              
              Positioned(
                top: 20,
                left: 20,
                child: Text("Score: $score", style: const TextStyle(color: Colors.white54, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
