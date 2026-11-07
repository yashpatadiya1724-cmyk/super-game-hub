import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class TicTacToe3DGame extends StatefulWidget {
  const TicTacToe3DGame({super.key});

  @override
  State<TicTacToe3DGame> createState() => _TicTacToe3DGameState();
}

enum Player { none, x, o }

class _TicTacToe3DGameState extends State<TicTacToe3DGame> {
  // 3 layers, each 3x3
  late List<List<List<Player>>> board;
  Player currentPlayer = Player.x;
  String? winner;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    board = List.generate(3, (_) => List.generate(3, (_) => List.generate(3, (_) => Player.none)));
    currentPlayer = Player.x;
    winner = null;
    setState(() {});
  }

  void _onTap(int layer, int r, int c) {
    if (winner != null || board[layer][r][c] != Player.none) return;

    setState(() {
      board[layer][r][c] = currentPlayer;
      if (_checkWin(layer, r, c)) {
        winner = currentPlayer == Player.x ? "PLAYER X" : "PLAYER O";
      } else {
        currentPlayer = (currentPlayer == Player.x) ? Player.o : Player.x;
      }
    });
  }

  bool _checkWin(int l, int r, int c) {
    // Check all directions in 3D space from the current move (layer, row, col)
    final p = board[l][r][c];

    // Directions: [dL, dR, dC]
    final directions = [
      [1,0,0], [0,1,0], [0,0,1], // main axes
      [1,1,0], [1,-1,0], [1,0,1], [1,0,-1], [0,1,1], [0,1,-1], // 2D diagonals
      [1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1] // 3D diagonals
    ];

    for (var dir in directions) {
      int count = 1;
      // Check positive direction
      for (int i = 1; i < 3; i++) {
        int nl = l + dir[0] * i;
        int nr = r + dir[1] * i;
        int nc = c + dir[2] * i;
        if (nl >= 0 && nl < 3 && nr >= 0 && nr < 3 && nc >= 0 && nc < 3 && board[nl][nr][nc] == p) {
          count++;
        } else {
          break;
        }
      }
      // Check negative direction
      for (int i = 1; i < 3; i++) {
        int nl = l - dir[0] * i;
        int nr = r - dir[1] * i;
        int nc = c - dir[2] * i;
        if (nl >= 0 && nl < 3 && nr >= 0 && nr < 3 && nc >= 0 && nc < 3 && board[nl][nr][nc] == p) {
          count++;
        } else {
          break;
        }
      }
      if (count >= 3) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Tic Tac Toe 3D",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              winner != null ? "$winner WINS!" : "${currentPlayer.name.toUpperCase()}'s TURN",
              style: GoogleFonts.outfit(color: winner != null ? Colors.greenAccent : Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, layer) {
                return Column(
                  children: [
                    Text("LAYER ${layer + 1}", style: GoogleFonts.outfit(color: Colors.white24, fontSize: 14)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.white12)),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 9,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                        itemBuilder: (context, index) {
                          int r = index ~/ 3;
                          int c = index % 3;
                          return GestureDetector(
                            onTap: () => _onTap(layer, r, c),
                            child: Container(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              child: Center(child: _buildPiece(board[layer][r][c])),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPiece(Player p) {
    if (p == Player.none) return const SizedBox();
    return Text(
      p == Player.x ? "X" : "O",
      style: GoogleFonts.outfit(color: p == Player.x ? Colors.redAccent : Colors.blueAccent, fontSize: 32, fontWeight: FontWeight.bold),
    );
  }
}
