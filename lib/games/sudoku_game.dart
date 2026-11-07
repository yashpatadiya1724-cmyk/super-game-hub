import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  late List<List<int>> board;
  late List<List<bool>> isOriginal;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    _generateSudoku();
  }

  void _generateSudoku() {
    setState(() {
      board = List.generate(9, (_) => List.filled(9, 0));
      isOriginal = List.generate(9, (_) => List.filled(9, false));
      
      _solve(0, 0); // Generate a full valid board
      
      _removeNumbers(40); // Remove 40 numbers to create the puzzle

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (board[r][c] != 0) isOriginal[r][c] = true;
        }
      }
    });
  }

  bool _solve(int row, int col) {
    if (row == 9) return true;
    if (col == 9) return _solve(row + 1, 0);

    List<int> nums = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle();
    for (int num in nums) {
      if (_isValid(row, col, num)) {
        board[row][col] = num;
        if (_solve(row, col + 1)) return true;
        board[row][col] = 0;
      }
    }
    return false;
  }

  bool _isValid(int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  void _removeNumbers(int count) {
    Random rng = Random();
    int removed = 0;
    while (removed < count) {
      int r = rng.nextInt(9);
      int c = rng.nextInt(9);
      if (board[r][c] != 0) {
        board[r][c] = 0;
        removed++;
      }
    }
  }

  void _onCellTap(int r, int c) {
    if (isOriginal[r][c]) return;
    setState(() {
      selectedRow = r;
      selectedCol = c;
    });
  }

  void _onNumberInput(int num) {
    if (selectedRow == null || selectedCol == null) return;
    setState(() {
      board[selectedRow!][selectedCol!] = num;
      _checkWin();
    });
  }

  void _checkWin() {
    // Basic win check logic (simplified)
    bool isFull = true;
    for (var row in board) {
      if (row.contains(0)) isFull = false;
    }
    if (isFull) {
      StorageService.saveHighScore('sudoku', 1);
      // Show win dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Sudoku",
      onReset: _generateSudoku,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBoard(),
          const SizedBox(height: 30),
          _buildNumberPad(),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
          itemCount: 81,
          itemBuilder: (context, index) {
            int r = index ~/ 9;
            int c = index % 9;
            bool isSelected = selectedRow == r && selectedCol == c;
            bool isDark = (r % 6 < 3 && c % 6 < 3) || (r % 6 >= 3 && c % 6 >= 3);
            
            return GestureDetector(
              onTap: () => _onCellTap(r, c),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent.withValues(alpha: 0.5) : (isDark ? Colors.white12 : Colors.transparent),
                  border: Border.all(color: Colors.white10, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    board[r][c] == 0 ? '' : '${board[r][c]}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: isOriginal[r][c] ? FontWeight.bold : FontWeight.normal,
                      color: isOriginal[r][c] ? Colors.white : Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(9, (index) {
        int num = index + 1;
        return ElevatedButton(
          onPressed: () => _onNumberInput(num),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            minimumSize: const Size(60, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('$num', style: GoogleFonts.outfit(fontSize: 24, color: Colors.white)),
        );
      }),
    );
  }
}
