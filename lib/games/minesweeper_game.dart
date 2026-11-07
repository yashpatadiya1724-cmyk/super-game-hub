import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({super.key});

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  static const int rows = 12;
  static const int cols = 9;
  static const int mines = 15;

  late List<List<bool>> hasMine;
  late List<List<bool>> revealed;
  late List<List<bool>> flagged;
  late List<List<int>> neighborMines;
  bool isGameOver = false;
  bool isGameWon = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      hasMine = List.generate(rows, (_) => List.filled(cols, false));
      revealed = List.generate(rows, (_) => List.filled(cols, false));
      flagged = List.generate(rows, (_) => List.filled(cols, false));
      neighborMines = List.generate(rows, (_) => List.filled(cols, 0));
      isGameOver = false;
      isGameWon = false;

      _placeMines();
      _calculateNeighbors();
    });
  }

  void _placeMines() {
    int count = 0;
    Random rnd = Random();
    while (count < mines) {
      int r = rnd.nextInt(rows);
      int c = rnd.nextInt(cols);
      if (!hasMine[r][c]) {
        hasMine[r][c] = true;
        count++;
      }
    }
  }

  void _calculateNeighbors() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (hasMine[r][c]) continue;
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = r + dr, nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && hasMine[nr][nc]) {
              count++;
            }
          }
        }
        neighborMines[r][c] = count;
      }
    }
  }

  void _onCellTap(int r, int c) {
    if (isGameOver || revealed[r][c] || flagged[r][c]) return;
    setState(() {
      if (hasMine[r][c]) {
        _revealAllMines();
        isGameOver = true;
      } else {
        _revealRecursive(r, c);
        _checkWin();
      }
    });
  }

  void _revealRecursive(int r, int c) {
    if (r < 0 || r >= rows || c < 0 || c >= cols || revealed[r][c]) return;
    revealed[r][c] = true;
    if (neighborMines[r][c] == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          _revealRecursive(r + dr, c + dc);
        }
      }
    }
  }

  void _revealAllMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (hasMine[r][c]) revealed[r][c] = true;
      }
    }
  }

  void _checkWin() {
    int revealedCount = 0;
    for (var r in revealed) {
      for (var c in r) {
        if (c) revealedCount++;
      }
    }
    if (revealedCount == (rows * cols - mines)) {
      setState(() {
        isGameWon = true;
        isGameOver = true;
      });
      StorageService.saveHighScore('minesweeper', rows * cols);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Minesweeper",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              isGameOver ? (isGameWon ? "YOU WON!" : "BOOM! GAME OVER") : "Find all the safe cells!",
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isGameWon ? Colors.greenAccent : (isGameOver ? Colors.redAccent : Colors.white)),
            ),
          ),
          Center(child: _buildGrid()),
          const SizedBox(height: 30),
          Text("Long press to flag mines", style: GoogleFonts.outfit(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      width: 320,
      height: 480,
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          int r = index ~/ cols;
          int c = index % cols;
          return _buildCell(r, c);
        },
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    bool isRev = revealed[r][c];
    bool isFlag = flagged[r][c];

    return GestureDetector(
      onTap: () => _onCellTap(r, c),
      onLongPress: () {
        if (!revealed[r][c] && !isGameOver) setState(() => flagged[r][c] = !flagged[r][c]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isRev ? (hasMine[r][c] ? Colors.red : Colors.white.withValues(alpha: 0.05)) : Colors.blueAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: Center(
          child: Text(
            isFlag ? '🚩' : (isRev ? (hasMine[r][c] ? '💣' : (neighborMines[r][c] > 0 ? '${neighborMines[r][c]}' : '')) : ''),
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: neighborMines[r][c] == 1 ? Colors.blue : (neighborMines[r][c] == 2 ? Colors.green : Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
