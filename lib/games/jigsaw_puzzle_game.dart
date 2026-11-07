import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class JigsawPuzzleGame extends StatefulWidget {
  const JigsawPuzzleGame({super.key});

  @override
  State<JigsawPuzzleGame> createState() => _JigsawPuzzleGameState();
}

class _JigsawPuzzleGameState extends State<JigsawPuzzleGame> {
  static const int gridSize = 3;
  late List<int?> tiles;
  int moves = 0;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    tiles = List.generate(gridSize * gridSize - 1, (i) => i + 1)..add(null);
    _shuffle();
    moves = 0;
    isWon = false;
    setState(() {});
  }

  void _shuffle() {
    // Perform random valid moves to ensure solvability
    Random r = Random();
    int emptyPos = tiles.indexOf(null);
    for (int i = 0; i < 100; i++) {
        List<int> validMoves = [];
        if (emptyPos % gridSize != 0) validMoves.add(emptyPos - 1);
        if (emptyPos % gridSize != gridSize - 1) validMoves.add(emptyPos + 1);
        if (emptyPos >= gridSize) validMoves.add(emptyPos - gridSize);
        if (emptyPos < gridSize * (gridSize - 1)) validMoves.add(emptyPos + gridSize);
        
        int move = validMoves[r.nextInt(validMoves.length)];
        tiles[emptyPos] = tiles[move];
        tiles[move] = null;
        emptyPos = move;
    }
  }

  void _onTileTap(int index) {
    if (isWon) return;
    int emptyPos = tiles.indexOf(null);
    
    // Check if neighbors
    bool isNeighbor = (index == emptyPos - 1 && index % gridSize != gridSize - 1) ||
                      (index == emptyPos + 1 && index % gridSize != 0) ||
                      (index == emptyPos - gridSize) ||
                      (index == emptyPos + gridSize);
                      
    if (isNeighbor) {
      setState(() {
        tiles[emptyPos] = tiles[index];
        tiles[index] = null;
        moves++;
        _checkWin();
      });
    }
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < tiles.length - 1; i++) {
       if (tiles[i] != i + 1) {
         win = false;
         break;
       }
    }
    if (win) isWon = true;
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Jigsaw Puzzle",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("MOVES: $moves", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                if (isWon) Text("YOU WIN!", style: GoogleFonts.outfit(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all(color: Colors.white12)),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize, 
                    mainAxisSpacing: 10, crossAxisSpacing: 10
                  ),
                  itemBuilder: (context, index) {
                    if (tiles[index] == null) return const SizedBox();
                    return GestureDetector(
                      onTap: () => _onTileTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                        ),
                        child: Center(
                          child: Text(tiles[index].toString(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
