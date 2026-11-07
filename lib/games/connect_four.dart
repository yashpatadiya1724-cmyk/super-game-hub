import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class ConnectFourGame extends StatefulWidget {
  const ConnectFourGame({super.key});

  @override
  State<ConnectFourGame> createState() => _ConnectFourGameState();
}

class _ConnectFourGameState extends State<ConnectFourGame> {
  static const int rows = 6;
  static const int cols = 7;
  List<List<int>> board = List.generate(rows, (_) => List.filled(cols, 0)); // 0: empty, 1: Red, 2: Yellow
  int currentPlayer = 1;
  bool isGameOver = false;
  String message = "Player 1's Turn";

  void _dropPiece(int col) {
    if (isGameOver) return;
    int row = -1;
    for (int r = rows - 1; r >= 0; r--) {
      if (board[r][col] == 0) {
        row = r;
        break;
      }
    }

    if (row != -1) {
      setState(() {
        board[row][col] = currentPlayer;
        if (_checkWin(row, col)) {
          isGameOver = true;
          message = "Player $currentPlayer Wins!";
          StorageService.saveHighScore('connect_four', 1);
        } else if (board.every((r) => r.every((c) => c != 0))) {
          isGameOver = true;
          message = "It's a Draw!";
        } else {
          currentPlayer = currentPlayer == 1 ? 2 : 1;
          message = "Player $currentPlayer's Turn";
        }
      });
    }
  }

  bool _checkWin(int r, int c) {
    int p = board[r][c];
    // Horizontal
    int count = 0;
    for (int j = 0; j < cols; j++) {
      if (board[r][j] == p) {
        count++;
        if (count == 4) return true;
      } else {
        count = 0;
      }
    }
    // Vertical
    count = 0;
    for (int i = 0; i < rows; i++) {
      if (board[i][c] == p) {
        count++;
        if (count == 4) return true;
      } else {
        count = 0;
      }
    }
    // Diagonals (simplified check)
    return _checkDiagonal(r, c, 1, 1) || _checkDiagonal(r, c, 1, -1);
  }

  bool _checkDiagonal(int r, int c, int dr, int dc) {
    int p = board[r][c];
    int count = 1;
    // Positive direction
    int nr = r + dr, nc = c + dc;
    while (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc] == p) {
      count++;
      nr += dr; nc += dc;
    }
    // Negative direction
    nr = r - dr; nc = c - dc;
    while (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc] == p) {
      count++;
      nr -= dr; nc -= dc;
    }
    return count >= 4;
  }

  void _resetGame() {
    setState(() {
      board = List.generate(rows, (_) => List.filled(cols, 0));
      currentPlayer = 1;
      isGameOver = false;
      message = "Player 1's Turn";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Connect Four",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              message,
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue[800], borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: List.generate(rows, (r) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(cols, (c) => GestureDetector(
                        onTap: () => _dropPiece(c),
                        child: Container(
                          width: 45,
                          height: 45,
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: board[r][c] == 0 ? Colors.white24 : (board[r][c] == 1 ? Colors.red : Colors.yellow),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),
                    )),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text("Restart Game"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
