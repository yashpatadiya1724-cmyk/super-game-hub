import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class TowerDefenderGame extends StatefulWidget {
  const TowerDefenderGame({super.key});

  @override
  State<TowerDefenderGame> createState() => _TowerDefenderGameState();
}

class Enemy {
  Offset position;
  double speed;
  int health;
  Enemy(this.position, this.speed, this.health);
}

class _TowerDefenderGameState extends State<TowerDefenderGame> {
  int score = 0;
  int towerHealth = 100;
  List<Enemy> enemies = [];
  Timer? gameTimer;
  Size? boardSize;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    score = 0;
    towerHealth = 100;
    enemies = [];
    _startGame();
    setState(() {});
  }

  void _startGame() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateGame();
    });
  }

  void _updateGame() {
    if (boardSize == null) return;
    if (towerHealth <= 0) {
      gameTimer?.cancel();
      return;
    }

    setState(() {
      // Spawn enemy
      if (random.nextInt(100) < 3) {
        enemies.add(Enemy(
          Offset(random.nextDouble() * boardSize!.width, -50),
          2.0 + (score / 100).clamp(0, 5),
          1
        ));
      }

      // Move enemies
      Offset towerPos = Offset(boardSize!.width / 2, boardSize!.height - 50);
      for (int i = enemies.length - 1; i >= 0; i--) {
         Offset dir = (towerPos - enemies[i].position);
         double distance = dir.distance;
         if (distance < 30) {
           towerHealth -= 10;
           enemies.removeAt(i);
           continue;
         }
         Offset step = dir / distance * enemies[i].speed;
         enemies[i].position += step;
      }
    });
  }

  void _onEnemyTap(int index) {
    setState(() {
       enemies.removeAt(index);
       score += 10;
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
      title: "Tower Defender",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("SCORE: $score", style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("HEALTH: $towerHealth%", style: GoogleFonts.outfit(color: towerHealth > 30 ? Colors.greenAccent : Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                boardSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Container(
                  color: Colors.black45,
                  child: Stack(
                    children: [
                      // Tower
                      Positioned(
                        bottom: 0,
                        left: boardSize!.width / 2 - 40,
                        child: Container(
                          width: 80, height: 60,
                          decoration: BoxDecoration(
                             color: Colors.blueAccent.withOpacity(0.5),
                             border: Border.all(color: Colors.blueAccent, width: 2),
                             borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                             boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15)],
                          ),
                          child: const Icon(Icons.security, color: Colors.white, size: 40),
                        ),
                      ),
                      // Enemies
                      ...List.generate(enemies.length, (index) {
                         return Positioned(
                           left: enemies[index].position.dx - 20,
                           top: enemies[index].position.dy - 20,
                           child: GestureDetector(
                             onTap: () => _onEnemyTap(index),
                             child: Container(
                               width: 40, height: 40,
                               decoration: BoxDecoration(
                                 color: Colors.red.withOpacity(0.8),
                                 shape: BoxShape.circle,
                                 boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10)],
                               ),
                               child: const Icon(Icons.psychology, size: 24, color: Colors.white),
                             ),
                           ),
                         );
                      }),
                      if (towerHealth <= 0) 
                        Center(
                          child: Text("GAME OVER", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 40, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
