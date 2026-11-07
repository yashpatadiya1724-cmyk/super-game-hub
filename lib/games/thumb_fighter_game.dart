import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class ThumbFighterGame extends StatefulWidget {
  const ThumbFighterGame({super.key});

  @override
  State<ThumbFighterGame> createState() => _ThumbFighterGameState();
}

class _ThumbFighterGameState extends State<ThumbFighterGame> {
  double health1 = 100.0;
  double health2 = 100.0;
  bool isP1Down = false;
  bool isP2Down = false;
  String? winner;

  void _p1Attack() {
    if (winner != null) return;
    setState(() {
      isP1Down = true;
      if (isP2Down) {
        // If both are down, it's a clash, no damage
      } else {
        health2 -= 5;
        if (health2 <= 0) {
          health2 = 0;
          winner = "PLAYER 1";
        }
      }
    });
    Timer(const Duration(milliseconds: 150), () => setState(() => isP1Down = false));
  }

  void _p2Attack() {
    if (winner != null) return;
    setState(() {
      isP2Down = true;
      if (isP1Down) {
        // Clash
      } else {
        health1 -= 5;
        if (health1 <= 0) {
          health1 = 0;
          winner = "PLAYER 2";
        }
      }
    });
    Timer(const Duration(milliseconds: 150), () => setState(() => isP2Down = false));
  }

  void _reset() {
    setState(() {
      health1 = 100.0;
      health2 = 100.0;
      winner = null;
      isP1Down = false;
      isP2Down = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Thumb Fighter",
      onReset: _reset,
      gameContent: Column(
        children: [
          // Player 2 Area (Top) - Rotated
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (_) => _p2Attack(),
                    child: Container(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          margin: EdgeInsets.only(bottom: isP2Down ? 0 : 50),
                          child: const Icon(Icons.thumb_up, size: 100, color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40, left: 20, right: 20,
                    child: _buildHealthBar(health2, Colors.blueAccent),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            height: 60,
            color: Colors.white10,
            child: Center(
              child: Text(
                winner ?? "VS",
                style: GoogleFonts.outfit(
                  color: winner != null ? Colors.yellowAccent : Colors.white24,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          // Player 1 Area (Bottom)
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTapDown: (_) => _p1Attack(),
                  child: Container(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        margin: EdgeInsets.only(bottom: isP1Down ? 0 : 50),
                        child: const Icon(Icons.thumb_up, size: 100, color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40, left: 20, right: 20,
                  child: _buildHealthBar(health1, Colors.redAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBar(double health, Color color) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: health / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)],
          ),
        ),
      ),
    );
  }
}
