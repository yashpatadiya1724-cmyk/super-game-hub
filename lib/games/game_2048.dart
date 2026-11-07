import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  late List<List<int>> grid;
  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      isGameOver = false;
      _addRandomTile();
      _addRandomTile();
    });
  }

  void _addRandomTile() {
    List<Point<int>> emptyCells = [];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == 0) emptyCells.add(Point(r, c));
      }
    }
    if (emptyCells.isNotEmpty) {
      final cell = emptyCells[Random().nextInt(emptyCells.length)];
      grid[cell.x][cell.y] = Random().nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void _move(String direction) {
    if (isGameOver) return;
    bool moved = false;
    setState(() {
      if (direction == 'up') moved = _moveUp();
      if (direction == 'down') moved = _moveDown();
      if (direction == 'left') moved = _moveLeft();
      if (direction == 'right') moved = _moveRight();

      if (moved) {
        _addRandomTile();
        _checkGameOver();
        StorageService.saveHighScore('2048', score);
      }
    });
  }

  bool _moveLeft() {
    bool moved = false;
    for (int r = 0; r < 4; r++) {
      List<int> row = grid[r].where((tile) => tile != 0).toList();
      for (int i = 0; i < row.length - 1; i++) {
        if (row[i] == row[i + 1]) {
          row[i] *= 2;
          score += row[i];
          row.removeAt(i + 1);
          moved = true;
        }
      }
      while (row.length < 4) {
        row.add(0);
      }
      if (row != grid[r]) moved = true;
      grid[r] = row;
    }
    return moved;
  }

  bool _moveRight() {
    bool moved = false;
    for (int r = 0; r < 4; r++) {
      List<int> row = grid[r].where((tile) => tile != 0).toList();
      for (int i = row.length - 1; i > 0; i--) {
        if (row[i] == row[i - 1]) {
          row[i] *= 2;
          score += row[i];
          row.removeAt(i - 1);
          moved = true;
          i--;
        }
      }
      while (row.length < 4) {
        row.insert(0, 0);
      }
      if (row != grid[r]) moved = true;
      grid[r] = row;
    }
    return moved;
  }

  bool _moveUp() {
    bool moved = false;
    for (int c = 0; c < 4; c++) {
      List<int> col = [];
      for (int r = 0; r < 4; r++) {
        if (grid[r][c] != 0) col.add(grid[r][c]);
      }
      for (int i = 0; i < col.length - 1; i++) {
        if (col[i] == col[i + 1]) {
          col[i] *= 2;
          score += col[i];
          col.removeAt(i + 1);
          moved = true;
        }
      }
      while (col.length < 4) {
        col.add(0);
      }
      for (int r = 0; r < 4; r++) {
        if (grid[r][c] != col[r]) moved = true;
        grid[r][c] = col[r];
      }
    }
    return moved;
  }

  bool _moveDown() {
    bool moved = false;
    for (int c = 0; c < 4; c++) {
      List<int> col = [];
      for (int r = 0; r < 4; r++) {
        if (grid[r][c] != 0) col.add(grid[r][c]);
      }
      for (int i = col.length - 1; i > 0; i--) {
        if (col[i] == col[i - 1]) {
          col[i] *= 2;
          score += col[i];
          col.removeAt(i - 1);
          moved = true;
          i--;
        }
      }
      while (col.length < 4) {
        col.insert(0, 0);
      }
      for (int r = 0; r < 4; r++) {
        if (grid[r][c] != col[r]) moved = true;
        grid[r][c] = col[r];
      }
    }
    return moved;
  }

  void _checkGameOver() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == 0) return;
        if (r < 3 && grid[r][c] == grid[r + 1][c]) return;
        if (c < 3 && grid[r][c] == grid[r][c + 1]) return;
      }
    }
    setState(() => isGameOver = true);
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return Colors.blue[100]!;
      case 4: return Colors.blue[200]!;
      case 8: return Colors.blue[300]!;
      case 16: return Colors.blue[400]!;
      case 32: return Colors.blue[500]!;
      case 64: return Colors.blue[600]!;
      case 128: return Colors.blue[700]!;
      case 256: return Colors.blue[800]!;
      case 512: return Colors.blue[900]!;
      case 1024: return Colors.blueAccent;
      case 2048: return Colors.deepOrangeAccent;
      default: return Colors.white12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "2048",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _scoreCard("SCORE", score),
                _scoreCard("BEST", StorageService.getHighScore('2048')),
              ],
            ),
          ),
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) _move('up');
              if (details.primaryVelocity! > 0) _move('down');
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) _move('left');
              if (details.primaryVelocity! > 0) _move('right');
            },
            child: Container(
              width: 350,
              height: 350,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  int r = index ~/ 4;
                  int c = index % 4;
                  int val = grid[r][c];
                  return Container(
                    decoration: BoxDecoration(
                      color: _getTileColor(val),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        val == 0 ? '' : '$val',
                        style: GoogleFonts.outfit(
                          fontSize: val > 100 ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: val > 4 ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (isGameOver)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("GAME OVER!", style: GoogleFonts.outfit(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 30),
          Text("Swipe to move tiles", style: GoogleFonts.outfit(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _scoreCard(String label, int val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white54)),
          Text('$val', style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
