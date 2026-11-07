import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class Match3Game extends StatefulWidget {
  const Match3Game({super.key});
  @override
  State<Match3Game> createState() => _Match3State();
}

class _Match3State extends State<Match3Game> {
  static const int cols = 6, rows = 8;
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
  final rng = Random();
  late List<List<int>> grid;
  int? selR, selC;
  int score = 0;
  bool gameOver = false;
  int movesLeft = 20;

  @override
  void initState() { super.initState(); _initGrid(); }

  void _initGrid() {
    grid = List.generate(rows, (_) => List.generate(cols, (_) => rng.nextInt(5)));
    score = 0; movesLeft = 20; gameOver = false; selR = null; selC = null;
  }

  void _tap(int r, int c) {
    if (gameOver) return;
    setState(() {
      if (selR == null) { selR = r; selC = c; }
      else {
        // Swap adjacent
        if ((selR! - r).abs() + (selC! - c).abs() == 1) {
          final tmp = grid[r][c]; grid[r][c] = grid[selR!][selC!]; grid[selR!][selC!] = tmp;
          final matched = _findMatches();
          if (matched.isEmpty) { final t2 = grid[r][c]; grid[r][c] = grid[selR!][selC!]; grid[selR!][selC!] = t2; }
          else { _clearMatches(matched); movesLeft--; if (movesLeft <= 0) gameOver = true; StorageService.saveHighScore('match_3', score); }
        }
        selR = null; selC = null;
      }
    });
  }

  List<List<int>> _findMatches() {
    final matched = <List<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 2; c++) {
        if (grid[r][c] == grid[r][c+1] && grid[r][c] == grid[r][c+2]) { matched.addAll([[r,c],[r,c+1],[r,c+2]]); }
      }
    }
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows - 2; r++) {
        if (grid[r][c] == grid[r+1][c] && grid[r][c] == grid[r+2][c]) { matched.addAll([[r,c],[r+1,c],[r+2,c]]); }
      }
    }
    return matched;
  }

  void _clearMatches(List<List<int>> matched) {
    final pts = matched.toSet();
    score += pts.length * 10;
    for (final p in pts) {
      grid[p[0]][p[1]] = -1;
    }
    // Drop down
    for (int c = 0; c < cols; c++) {
      int write = rows - 1;
      for (int r = rows - 1; r >= 0; r--) { if (grid[r][c] != -1) { grid[write][c] = grid[r][c]; write--; } }
      for (int r = write; r >= 0; r--) {
        grid[r][c] = rng.nextInt(5);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width - 40) / cols;
    return GameWrapper(
      title: 'Match 3',
      onReset: () => setState(_initGrid),
      gameContent: Column(children: [
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Score: $score', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Moves: $movesLeft', style: GoogleFonts.outfit(color: movesLeft <= 5 ? Colors.redAccent : Colors.yellowAccent, fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        if (gameOver) ...[
          Text('Game Over! Final Score: $score', style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => setState(_initGrid), style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: Text('Play Again', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.4), width: 2), borderRadius: BorderRadius.circular(12)),
          child: Column(children: List.generate(rows, (r) => Row(children: List.generate(cols, (c) {
            final colorIdx = grid[r][c];
            final isSel = selR == r && selC == c;
            return GestureDetector(
              onTap: () => _tap(r, c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: cellSize, height: cellSize,
                decoration: BoxDecoration(
                  color: colorIdx >= 0 ? colors[colorIdx].withValues(alpha: 0.8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSel ? Colors.white : Colors.black26, width: isSel ? 2.5 : 0.5),
                  boxShadow: isSel ? [BoxShadow(color: colors[colorIdx >= 0 ? colorIdx : 0].withValues(alpha: 0.6), blurRadius: 8)] : null,
                ),
                margin: const EdgeInsets.all(2),
              ),
            );
          })))),
        ),
      ]),
    );
  }
}
