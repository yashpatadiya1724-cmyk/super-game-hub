import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../theme/app_theme.dart';

class DotsAndBoxesGame extends StatefulWidget {
  const DotsAndBoxesGame({super.key});

  @override
  State<DotsAndBoxesGame> createState() => _DotsAndBoxesGameState();
}

class _DotsAndBoxesGameState extends State<DotsAndBoxesGame> {
  static const int gridSize = 5; // 5x5 boxes
  List<List<bool>> horizontalLines = List.generate(gridSize + 1, (_) => List.filled(gridSize, false));
  List<List<bool>> verticalLines = List.generate(gridSize, (_) => List.filled(gridSize + 1, false));
  List<List<int>> boxes = List.generate(gridSize, (_) => List.filled(gridSize, 0)); // 0: None, 1: P1, 2: P2

  int currentPlayer = 1;
  int p1Score = 0;
  int p2Score = 0;
  bool isGameOver = false;

  void _resetGame() {
    setState(() {
      horizontalLines = List.generate(gridSize + 1, (_) => List.filled(gridSize, false));
      verticalLines = List.generate(gridSize, (_) => List.filled(gridSize + 1, false));
      boxes = List.generate(gridSize, (_) => List.filled(gridSize, 0));
      currentPlayer = 1;
      p1Score = 0;
      p2Score = 0;
      isGameOver = false;
    });
  }

  void _handleTap(bool isHorizontal, int r, int c) {
    if (isGameOver) return;
    if (isHorizontal) {
      if (horizontalLines[r][c]) return;
      horizontalLines[r][c] = true;
    } else {
      if (verticalLines[r][c]) return;
      verticalLines[r][c] = true;
    }

    bool captured = false;
    int newP1 = 0;
    int newP2 = 0;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (boxes[i][j] == 0) {
          if (horizontalLines[i][j] && horizontalLines[i + 1][j] && verticalLines[i][j] && verticalLines[i][j + 1]) {
            boxes[i][j] = currentPlayer;
            captured = true;
          }
        }
        if (boxes[i][j] == 1) newP1++;
        if (boxes[i][j] == 2) newP2++;
      }
    }

    setState(() {
      p1Score = newP1;
      p2Score = newP2;

      if (p1Score + p2Score == gridSize * gridSize) {
        isGameOver = true;
      } else if (!captured) {
        currentPlayer = currentPlayer == 1 ? 2 : 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Dots & Boxes",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreCard("P1 (RED)", p1Score, AppTheme.accentArcade, currentPlayer == 1),
              _scoreCard("P2 (BLUE)", p2Score, AppTheme.accentPuzzle, currentPlayer == 2),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.blocky(color: AppTheme.surface),
              child: _buildGrid(),
            ),
          ),
          if (isGameOver)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Text(
                    p1Score > p2Score ? "PLAYER 1 WINS!" : (p2Score > p1Score ? "PLAYER 2 WINS!" : "IT'S A DRAW!"),
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBrain),
                    onPressed: _resetGame,
                    child: Text("PLAY AGAIN", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _scoreCard(String title, int score, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: AppTheme.blocky(color: isActive ? color.withValues(alpha: 0.4) : Colors.transparent),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
          Text("$score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    double spacing = 45;
    double dotSize = 10;
    
    return SizedBox(
      width: spacing * gridSize + dotSize,
      height: spacing * gridSize + dotSize,
      child: Stack(
        children: [
          // Boxes
          for (int r = 0; r < gridSize; r++)
            for (int c = 0; c < gridSize; c++)
              if (boxes[r][c] != 0)
                Positioned(
                  left: c * spacing + dotSize / 2,
                  top: r * spacing + dotSize / 2,
                  child: Container(
                    width: spacing,
                    height: spacing,
                    color: boxes[r][c] == 1 ? AppTheme.accentArcade.withValues(alpha: 0.5) : AppTheme.accentPuzzle.withValues(alpha: 0.5),
                  ),
                ),
                
          // Horizontal Lines
          for (int r = 0; r <= gridSize; r++)
            for (int c = 0; c < gridSize; c++)
              Positioned(
                left: c * spacing + dotSize,
                top: r * spacing,
                child: GestureDetector(
                  onTap: () => _handleTap(true, r, c),
                  child: Container(
                    height: dotSize,
                    width: spacing - dotSize,
                    color: horizontalLines[r][c] ? Colors.white : Colors.white12,
                  ),
                ),
              ),

          // Vertical Lines
          for (int r = 0; r < gridSize; r++)
            for (int c = 0; c <= gridSize; c++)
              Positioned(
                left: c * spacing,
                top: r * spacing + dotSize,
                child: GestureDetector(
                  onTap: () => _handleTap(false, r, c),
                  child: Container(
                    width: dotSize,
                    height: spacing - dotSize,
                    color: verticalLines[r][c] ? Colors.white : Colors.white12,
                  ),
                ),
              ),

          // Dots
          for (int r = 0; r <= gridSize; r++)
            for (int c = 0; c <= gridSize; c++)
              Positioned(
                left: c * spacing,
                top: r * spacing,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                ),
              ),
        ],
      ),
    );
  }
}
