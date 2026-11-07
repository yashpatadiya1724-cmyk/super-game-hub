import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class TankWarsGame extends StatefulWidget {
  const TankWarsGame({super.key});

  @override
  State<TankWarsGame> createState() => _TankWarsGameState();
}

class Projectile {
  Offset position;
  Offset velocity;
  Projectile(this.position, this.velocity);
}

class _TankWarsGameState extends State<TankWarsGame> {
  int health1 = 100;
  int health2 = 100;
  Offset tank1Pos = const Offset(50, 0);
  Offset tank2Pos = const Offset(0, 0);
  double angle1 = -0.52; // 30 deg in rad
  double angle2 = -2.61; // 150 deg in rad
  bool isP1Turn = true;
  
  Projectile? activeProjectile;
  Timer? gameTimer;
  Size? boardSize;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    health1 = 100;
    health2 = 100;
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
      if (activeProjectile != null) _updateProjectile();
    });
  }

  void _fire() {
    if (activeProjectile != null) return;
    setState(() {
      if (isP1Turn) {
        activeProjectile = Projectile(
          tank1Pos + Offset(cos(angle1) * 30, sin(angle1) * 30),
          Offset(cos(angle1) * 8, sin(angle1) * 8)
        );
      } else {
        activeProjectile = Projectile(
          tank2Pos + Offset(cos(angle2) * 30, sin(angle2) * 30),
          Offset(cos(angle2) * 8, sin(angle2) * 8)
        );
      }
    });
  }

  void _updateProjectile() {
    setState(() {
      activeProjectile!.velocity += const Offset(0, 0.15); // Gravity
      activeProjectile!.position += activeProjectile!.velocity;

      // Hit detection P1
      if ((activeProjectile!.position - tank1Pos).distance < 30) {
        health1 -= 25;
        activeProjectile = null;
        isP1Turn = !isP1Turn;
      } else if ((activeProjectile!.position - tank2Pos).distance < 30) {
        health2 -= 25;
        activeProjectile = null;
        isP1Turn = !isP1Turn;
      } else if (activeProjectile!.position.dy > boardSize!.height - 50 || 
                 activeProjectile!.position.dx < 0 || activeProjectile!.position.dx > boardSize!.width) {
        activeProjectile = null;
        isP1Turn = !isP1Turn;
      }
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
      title: "Tank Wars",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("P1: $health1%", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(isP1Turn ? "P1 TURN" : "P2 TURN", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("P2: $health2%", style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                boardSize = Size(constraints.maxWidth, constraints.maxHeight);
                tank1Pos = Offset(50, boardSize!.height - 65);
                tank2Pos = Offset(boardSize!.width - 50, boardSize!.height - 65);
                
                return Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Ground
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(height: 50, color: Colors.green.shade900),
                      ),
                      // Tank 1
                      Positioned(
                        left: tank1Pos.dx - 20, top: tank1Pos.dy - 10,
                        child: Transform.rotate(angle: 0, child: const Icon(Icons.military_tech, color: Colors.redAccent, size: 40)),
                      ),
                      // Tank 2
                      Positioned(
                        left: tank2Pos.dx - 20, top: tank2Pos.dy - 10,
                        child: Transform(transform: Matrix4.rotationY(pi), alignment: Alignment.center, child: const Icon(Icons.military_tech, color: Colors.blueAccent, size: 40)),
                      ),
                      // Active Projectile
                      if (activeProjectile != null)
                        Positioned(
                          left: activeProjectile!.position.dx,
                          top: activeProjectile!.position.dy,
                          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.yellowAccent, shape: BoxShape.circle)),
                        ),
                      // Controls
                      Positioned(
                        bottom: 60, left: 20,
                        child: Column(
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_upward, color: Colors.white), onPressed: () => setState(() => angle1 -= 0.1)),
                            IconButton(icon: const Icon(Icons.arrow_downward, color: Colors.white), onPressed: () => setState(() => angle1 += 0.1)),
                            ElevatedButton(onPressed: isP1Turn ? _fire : null, child: const Text("FIRE P1")),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 60, right: 20,
                        child: Column(
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_upward, color: Colors.white), onPressed: () => setState(() => angle2 += 0.1)),
                            IconButton(icon: const Icon(Icons.arrow_downward, color: Colors.white), onPressed: () => setState(() => angle2 -= 0.1)),
                            ElevatedButton(onPressed: !isP1Turn ? _fire : null, child: const Text("FIRE P2")),
                          ],
                        ),
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
