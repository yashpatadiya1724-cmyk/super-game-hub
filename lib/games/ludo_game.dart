import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../theme/app_theme.dart';

class LudoGame extends StatefulWidget {
  const LudoGame({super.key});

  @override
  State<LudoGame> createState() => _LudoGameState();
}

class _LudoGameState extends State<LudoGame> {
  // Mini Ludo! 2 Players, 1 Token each, circular track of 40 steps.
  static const int trackLength = 40;
  
  int redPos = -1; // -1 means home base
  int bluePos = -1; 
  
  int currentPlayer = 1; // 1: Red, 2: Blue
  int diceValue = 1;
  bool isRolling = false;
  String message = "Red's Turn! Roll 6 to start.";
  bool isGameOver = false;

  void _resetGame() {
    setState(() {
      redPos = -1;
      bluePos = -1;
      currentPlayer = 1;
      diceValue = 1;
      isRolling = false;
      message = "Red's Turn! Roll 6 to start.";
      isGameOver = false;
    });
  }

  void _rollDice() async {
    if (isRolling || isGameOver) return;
    setState(() {
      isRolling = true;
      message = "Rolling...";
    });

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => diceValue = Random().nextInt(6) + 1);
    }

    setState(() {
      isRolling = false;
      _processMove();
    });
  }

  void _processMove() {
    bool gotSix = diceValue == 6;

    if (currentPlayer == 1) { // Red
      if (redPos == -1) {
        if (gotSix) {
          redPos = 0;
          message = "Red entered! Roll again.";
        } else {
          message = "Red needs a 6. Blue's Turn.";
          currentPlayer = 2;
        }
      } else {
        redPos += diceValue;
        if (redPos >= trackLength - 1) {
          message = "RED WINS!";
          redPos = trackLength - 1;
          isGameOver = true;
          return;
        }
        _checkCapture(0);
        if (!gotSix) {
          message = "Blue's Turn.";
          currentPlayer = 2;
        } else {
          message = "Red rolled a 6! Roll again.";
        }
      }
    } else { // Blue
      if (bluePos == -1) {
        if (gotSix) {
          bluePos = 20;
          message = "Blue entered! Roll again.";
        } else {
          message = "Blue needs a 6. Red's Turn.";
          currentPlayer = 1;
        }
      } else {
        bluePos += diceValue;
        _checkCapture(1);
        
        if (bluePos >= 59) {
           message = "BLUE WINS!";
           bluePos = 59;
           isGameOver = true;
           return;
        }
        
        if (!gotSix) {
          message = "Red's Turn.";
          currentPlayer = 1;
        } else {
          message = "Blue rolled a 6! Roll again.";
        }
      }
    }
  }

  void _checkCapture(int movingPlayer) {
    if (redPos != -1 && bluePos != -1) {
      if ((bluePos % trackLength) == (redPos % trackLength)) {
        if (movingPlayer == 0) { // Red moved onto Blue touching same tile modulo
          bluePos = -1;
          message = "Red captured Blue! Roll again.";
          currentPlayer = 1; // Extra turn for capture
        } else {
          redPos = -1;
          message = "Blue captured Red! Roll again.";
          currentPlayer = 2;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Mini Ludo",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: AppTheme.blocky(color: Colors.black54),
            child: Text(
              message,
              style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          _buildBoard(),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _rollDice,
            child: Container(
              width: 100,
              height: 100,
              decoration: AppTheme.blocky(color: Colors.white).copyWith(
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: isRolling 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      "$diceValue",
                      style: GoogleFonts.outfit(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "TAP DICE TO ROLL",
            style: GoogleFonts.outfit(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    // Render a simple circular track visualization
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background track circle
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 30),
          ),
        ),
        // Start marks
        const Positioned(top: 10, child: Text("RED END", style: TextStyle(color: AppTheme.accentArcade))),
        const Positioned(bottom: 10, child: Text("BLUE END", style: TextStyle(color: AppTheme.accentPuzzle))),
        
        // Red Token
        if (redPos != -1) _buildToken(redPos, AppTheme.accentArcade),
        // Blue Token
        if (bluePos != -1) _buildToken(bluePos, AppTheme.accentPuzzle),

        // Bases
        Positioned(
          left: 20, top: 20,
          child: Column(
            children: [
              Text("RED BASE", style: GoogleFonts.outfit(color: AppTheme.accentArcade)),
              if (redPos == -1) Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppTheme.accentArcade, shape: BoxShape.circle)),
            ],
          ),
        ),
        Positioned(
          right: 20, bottom: 20,
          child: Column(
            children: [
              if (bluePos == -1) Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppTheme.accentPuzzle, shape: BoxShape.circle)),
              Text("BLUE BASE", style: GoogleFonts.outfit(color: AppTheme.accentPuzzle)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToken(int position, Color color) {
    // Map linear position to polar coordinates for circular track
    double angle = (position % trackLength) / trackLength * 2 * pi - pi / 2;
    // radius is half the visual container size minus border thickness
    double radius = 150 - 15;
    double x = cos(angle) * radius;
    double y = sin(angle) * radius;

    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))],
        ),
      ),
    );
  }
}
