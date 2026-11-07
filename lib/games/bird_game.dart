import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class BirdGame extends StatefulWidget {
  const BirdGame({super.key});

  @override
  State<BirdGame> createState() => _BirdGameState();
}

class _BirdGameState extends State<BirdGame> {
  static double birdY = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -4.9;
  double velocity = 3.5;
  double birdWidth = 0.1;
  double birdHeight = 0.1;

  bool gameHasStarted = false;

  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.5;
  List<List<double>> barrierHeight = [
    [0.6, 0.4],
    [0.4, 0.6],
  ];

  int score = 0;

  void startGame() {
    gameHasStarted = true;
    score = 0;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      height = gravity * time * time + velocity * time;
      setState(() {
        birdY = initialPos - height;
      });

      if (_checkGameOver()) {
        timer.cancel();
        _showGameOverDialog();
      }

      _moveBarriers();
      time += 0.01;
    });
  }

  void _moveBarriers() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.005;
      });

      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
        barrierHeight[i] = [Random().nextDouble() * 0.8 + 0.1, 0];
        barrierHeight[i][1] = 1.1 - barrierHeight[i][0];
      }
    }
  }

  void flap() {
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  bool _checkGameOver() {
    if (birdY < -1 || birdY > 1) return true;

    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] || birdY >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void _showGameOverDialog() {
    gameHasStarted = false;
    StorageService.saveHighScore('bird', score);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: const Text("GAME OVER", style: TextStyle(color: Colors.white)),
          content: Text("Score: $score", style: const TextStyle(color: Colors.white)),
          actions: [
            GestureDetector(
              onTap: () {
                _resetGame();
                Navigator.pop(context);
              },
              child: const Text("PLAY AGAIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      birdY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = birdY;
      barrierX = [2, 2 + 1.5];
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Flappy Bird",
      onReset: _resetGame,
      gameContent: GestureDetector(
        onTap: gameHasStarted ? flap : startGame,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.lightBlue,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment(0, birdY),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                        child: const Center(child: Icon(Icons.face, size: 40)),
                      ),
                    ),
                    _barrier(barrierX[0], barrierHeight[0][0], true),
                    _barrier(barrierX[0], barrierHeight[0][1], false),
                    _barrier(barrierX[1], barrierHeight[1][0], true),
                    _barrier(barrierX[1], barrierHeight[1][1], false),
                    Container(
                      alignment: const Alignment(0, -0.5),
                      child: Text(
                        gameHasStarted ? "" : "T A P  T O  P L A Y",
                        style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green,
                child: Center(
                  child: Text(
                    "S C O R E : $score",
                    style: const TextStyle(color: Colors.white, fontSize: 35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barrier(double x, double h, bool isBottom) {
    return Container(
      alignment: Alignment(x, isBottom ? -1.1 : 1.1),
      child: Container(
        width: MediaQuery.of(context).size.width * barrierWidth / 2,
        height: MediaQuery.of(context).size.height * 3 / 4 * h / 2,
        decoration: BoxDecoration(
          color: Colors.green[800],
          border: Border.all(width: 5, color: Colors.green[900]!),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
