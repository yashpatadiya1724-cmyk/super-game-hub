import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class RacingBlocksGame extends StatefulWidget {
  const RacingBlocksGame({super.key});

  @override
  State<RacingBlocksGame> createState() => _RacingBlocksGameState();
}

class _RacingBlocksGameState extends State<RacingBlocksGame> {
  double pos1 = 0;
  double pos2 = 0;
  String? winner;

  void _tap1() {
    if (winner != null) return;
    setState(() {
      pos1 += 0.05;
      if (pos1 >= 0.9) winner = "PLAYER 1";
    });
  }

  void _tap2() {
    if (winner != null) return;
    setState(() {
      pos2 += 0.05;
      if (pos2 >= 0.9) winner = "PLAYER 2";
    });
  }

  void _reset() {
    setState(() {
      pos1 = 0;
      pos2 = 0;
      winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Racing Blocks",
      onReset: _reset,
      gameContent: Column(
        children: [
          // Player 2 Area (Top) - Tap to race
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: GestureDetector(
                onTapDown: (_) => _tap2(),
                child: Container(
                  color: Colors.blueAccent.withOpacity(0.1),
                  child: Stack(
                    children: [
                      _buildTrack(pos2, Colors.blueAccent),
                      Positioned(
                        top: 20, left: 0, right: 0,
                        child: Center(child: Text("TAP TO RACE", style: GoogleFonts.outfit(color: Colors.white24, fontSize: 32, fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Container(
            height: 4,
            color: Colors.yellowAccent.withOpacity(0.5),
          ),

          // Player 1 Area (Bottom) - Tap to race
          Expanded(
            child: GestureDetector(
              onTapDown: (_) => _tap1(),
              child: Container(
                color: Colors.redAccent.withOpacity(0.1),
                child: Stack(
                  children: [
                    _buildTrack(pos1, Colors.redAccent),
                    Positioned(
                      top: 20, left: 0, right: 0,
                      child: Center(child: Text("TAP TO RACE", style: GoogleFonts.outfit(color: Colors.white24, fontSize: 32, fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (winner != null)
            Center(
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                 color: Colors.black87,
                 child: Text("$winner WINS!", style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 32, fontWeight: FontWeight.bold)),
               ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrack(double pos, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
             // Finish Line
             Positioned(
               right: 50, top: 0, bottom: 0,
               child: Container(
                 width: 10,
                 color: Colors.white24,
                 child: Column(
                   children: List.generate(10, (i) => Container(height: 20, color: i%2==0 ? Colors.white : Colors.black)),
                 ),
               ),
             ),
             // Racing Block
             AnimatedPositioned(
               duration: const Duration(milliseconds: 100),
               left: (constraints.maxWidth - 100) * pos,
               top: constraints.maxHeight / 2 - 25,
               child: Container(
                 width: 60, height: 40,
                 decoration: BoxDecoration(
                   color: color,
                   borderRadius: BorderRadius.circular(5),
                   boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)],
                 ),
                 child: const Icon(Icons.flash_on, color: Colors.white),
               ),
             ),
          ],
        );
      }
    );
  }
}
