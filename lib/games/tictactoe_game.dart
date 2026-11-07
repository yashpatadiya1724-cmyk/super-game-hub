import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late List<String> board;
  late bool isXTurn;
  String winner = '';
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isXTurn = true;
      winner = '';
      isGameOver = false;
    });
  }

  void _handleTap(int index) {
    if (board[index] != '' || isGameOver) return;

    setState(() {
      board[index] = isXTurn ? 'X' : 'O';
      isXTurn = !isXTurn;
      _checkWinner();
    });
  }

  void _checkWinner() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var line in lines) {
      if (board[line[0]] != '' &&
          board[line[0]] == board[line[1]] &&
          board[line[0]] == board[line[2]]) {
        setState(() {
          winner = board[line[0]];
          isGameOver = true;
        });
        StorageService.saveHighScore('tictactoe', 1);
        return;
      }
    }

    if (!board.contains('')) {
      setState(() {
        winner = 'Draw';
        isGameOver = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Tic Tac Toe",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              isGameOver 
                ? (winner == 'Draw' ? "It's a Draw!" : "Winner: $winner")
                : "Player ${isXTurn ? 'X' : 'O'}'s Turn",
              style: GoogleFonts.outfit(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: board[index] == 'X' ? Colors.blue : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text("Restart Game"),
          ),
        ],
      ),
    );
  }
}
