import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class CheckersGame extends StatefulWidget {
  const CheckersGame({super.key});
  @override
  State<CheckersGame> createState() => _CheckersState();
}

class _CheckersState extends State<CheckersGame> {
  // 8x8 board: 0=empty, 1=red, 2=red-king, 3=black, 4=black-king
  late List<List<int>> board;
  int currentPlayer = 1; // 1=red, 3=black
  int? selRow, selCol;
  List<List<int>> validMoves = [];
  int redPieces = 12, blackPieces = 12;

  @override
  void initState() { super.initState(); _initBoard(); }

  void _initBoard() {
    board = List.generate(8, (r) => List.generate(8, (c) {
      if ((r + c) % 2 == 0) return 0;
      if (r < 3) return 3; // black top
      if (r > 4) return 1; // red bottom
      return 0;
    }));
    currentPlayer = 1; selRow = null; selCol = null; validMoves = []; redPieces = 12; blackPieces = 12;
  }

  List<List<int>> _getMovesFor(int r, int c) {
    final piece = board[r][c];
    if (piece == 0) return [];
    final moves = <List<int>>[];
    final dirs = piece == 1 ? [[-1, -1], [-1, 1]] : (piece == 3 ? [[1, -1], [1, 1]] : [[-1,-1],[-1,1],[1,-1],[1,1]]);
    for (final d in dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 && board[nr][nc] == 0) moves.add([nr, nc, 0]);
      // capture
      final er = r + d[0], ec = c + d[1];
      final lr = r + d[0] * 2, lc = c + d[1] * 2;
      if (lr >= 0 && lr < 8 && lc >= 0 && lc < 8) {
        final mid = board[er][ec];
        final isEnemy = (piece == 1 || piece == 2) ? (mid == 3 || mid == 4) : (mid == 1 || mid == 2);
        if (isEnemy && board[lr][lc] == 0) moves.add([lr, lc, 1]);
      }
    }
    return moves;
  }

  void _onTap(int r, int c) {
    final piece = board[r][c];
    final isCurrentPlayer = (currentPlayer == 1 && (piece == 1 || piece == 2)) || (currentPlayer == 3 && (piece == 3 || piece == 4));
    setState(() {
      if (selRow != null) {
        // Check if tapping a valid move
        final move = validMoves.where((m) => m[0] == r && m[1] == c).toList();
        if (move.isNotEmpty) {
          board[r][c] = board[selRow!][selCol!];
          board[selRow!][selCol!] = 0;
          if (move[0][2] == 1) { // capture
            board[(selRow! + r) ~/ 2][(selCol! + c) ~/ 2] = 0;
            if (currentPlayer == 1) blackPieces--; else redPieces--;
          }
          // King promotion
          if (r == 0 && board[r][c] == 1) board[r][c] = 2;
          if (r == 7 && board[r][c] == 3) board[r][c] = 4;
          currentPlayer = currentPlayer == 1 ? 3 : 1;
          selRow = null; selCol = null; validMoves = [];
        } else if (isCurrentPlayer) {
          selRow = r; selCol = c; validMoves = _getMovesFor(r, c);
        } else {
          selRow = null; selCol = null; validMoves = [];
        }
      } else if (isCurrentPlayer) {
        selRow = r; selCol = c; validMoves = _getMovesFor(r, c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool gameOver = redPieces == 0 || blackPieces == 0;
    final cellSize = (MediaQuery.of(context).size.width - 32) / 8;
    return GameWrapper(
      title: 'Checkers',
      onReset: () => setState(_initBoard),
      gameContent: Column(children: [
        const SizedBox(height: 10),
        if (gameOver)
          Text(redPieces == 0 ? '⚫ Black Wins!' : '🔴 Red Wins!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellowAccent))
        else
          Text('${currentPlayer == 1 ? "🔴 Red" : "⚫ Black"}\'s Turn', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: currentPlayer == 1 ? Colors.redAccent : Colors.white70)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('🔴 Red: $redPieces', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          Text('⚫ Black: $blackPieces', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.white30, width: 2), borderRadius: BorderRadius.circular(4)),
          child: Column(children: List.generate(8, (r) => Row(children: List.generate(8, (c) {
            final isLight = (r + c) % 2 != 0;
            final piece = board[r][c];
            final isSel = selRow == r && selCol == c;
            final isValidMove = validMoves.any((m) => m[0] == r && m[1] == c);
            return GestureDetector(
              onTap: () => _onTap(r, c),
              child: Container(
                width: cellSize, height: cellSize,
                color: isSel ? Colors.yellowAccent.withValues(alpha: 0.4) : isValidMove ? Colors.greenAccent.withValues(alpha: 0.3) : isLight ? const Color(0xFF8B4513) : const Color(0xFF2C1810),
                child: Center(child: piece == 0 ? null : Container(
                  width: cellSize * 0.7, height: cellSize * 0.7,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(colors: piece == 1 || piece == 2 ? [Colors.red.shade300, Colors.red.shade800] : [Colors.grey.shade400, Colors.grey.shade900]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(1, 2))],
                    border: Border.all(color: isSel ? Colors.yellow : Colors.white30, width: isSel ? 2 : 1),
                  ),
                  child: piece == 2 || piece == 4 ? const Center(child: Text('♛', style: TextStyle(fontSize: 14))) : null,
                )),
              ),
            );
          })))),
        ),
      ]),
    );
  }
}
