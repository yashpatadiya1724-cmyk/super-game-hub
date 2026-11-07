import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class SpaceShooterGame extends StatefulWidget {
  const SpaceShooterGame({super.key});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame> {
  // Player
  double playerX = 0;
  double playerY = 0.8;

  // Bullets
  List<Point<double>> bullets = [];

  // Enemies
  List<Point<double>> enemies = [];

  // Game state
  bool hasStarted = false;
  int score = 0;

  void startGame() {
    hasStarted = true;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();

      if (_checkGameOver()) {
        timer.cancel();
        _showGameOverDialog();
      }
    });

    // Enemy spawn
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!hasStarted) {
        timer.cancel();
        return;
      }
      setState(() {
        enemies.add(Point(-1 + Random().nextDouble() * 2, -1.1));
      });
    });
  }

  void _updateGame() {
    setState(() {
      // Update bullets
      bullets = bullets
          .map((b) => Point(b.x, b.y - 0.05))
          .where((b) => b.y > -1.1)
          .toList();

      // Update enemies
      enemies = enemies
          .map((e) => Point(e.x, e.y + 0.01))
          .where((e) => e.y < 1.1)
          .toList();

      // Bullet-Enemy collision
      for (int i = bullets.length - 1; i >= 0; i--) {
        for (int j = enemies.length - 1; j >= 0; j--) {
          if ((bullets[i].x - enemies[j].x).abs() < 0.2 &&
              (bullets[i].y - enemies[j].y).abs() < 0.1) {
            bullets.removeAt(i);
            enemies.removeAt(j);
            score += 50;
            break;
          }
        }
      }
    });
  }

  bool _checkGameOver() {
    for (var e in enemies) {
      if ((e.x - playerX).abs() < 0.2 && (e.y - playerY).abs() < 0.1) {
        return true;
      }
    }
    return false;
  }

  void shoot() {
    if (!hasStarted) return;
    setState(() {
      bullets.add(Point(playerX, playerY));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Space Shooter",
      onReset: () {
        setState(() {
          playerX = 0;
          bullets = [];
          enemies = [];
          score = 0;
          hasStarted = false;
        });
      },
      gameContent: GestureDetector(
        onTap: hasStarted ? shoot : startGame,
        onHorizontalDragUpdate: (details) {
          setState(() {
            playerX += details.delta.dx / (MediaQuery.of(context).size.width / 2);
            if (playerX < -1) playerX = -1;
            if (playerX > 1) playerX = 1;
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Starfield (Simple)
              for (int i = 0; i < 20; i++)
                Positioned(
                  left: Random().nextDouble() * 400,
                  top: Random().nextDouble() * 800,
                  child: Container(width: 2, height: 2, color: Colors.white24),
                ),

              // Player
              Container(
                alignment: Alignment(playerX, playerY),
                child: const Icon(Icons.airplanemode_active, color: Colors.blueAccent, size: 50),
              ),

              // Bullets
              for (var b in bullets)
                Container(
                  alignment: Alignment(b.x, b.y),
                  child: Container(width: 5, height: 15, color: Colors.yellowAccent),
                ),

              // Enemies
              for (var e in enemies)
                Container(
                  alignment: Alignment(e.x, e.y),
                  child: const Icon(Icons.rocket, color: Colors.redAccent, size: 40),
                ),

              Positioned(
                top: 20,
                left: 20,
                child: Text("Score: $score", style: const TextStyle(color: Colors.white54, fontSize: 18)),
              ),

              if (!hasStarted)
                const Center(
                  child: Text("TAP TO START", style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 5)),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    hasStarted = false;
    StorageService.saveHighScore('space_shooter', score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text("GAME OVER", style: TextStyle(color: Colors.white)),
        content: Text("Final Score: $score", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                playerX = 0;
                bullets = [];
                enemies = [];
                score = 0;
              });
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
