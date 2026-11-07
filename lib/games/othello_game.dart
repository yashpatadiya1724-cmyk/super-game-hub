import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class OthelloGame extends StatefulWidget {
  const OthelloGame({super.key});

  @override
  State<OthelloGame> createState() => _OthelloGameState();
}

enum BoardPiece { none, black, white }

class _OthelloGameState extends State<OthelloGame> {
  static const int size = 8;
  late List<List<BoardPiece>> board;
  BoardPiece currentPlayer = BoardPiece.black;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    board = List.generate(size, (_) => List.generate(size, (_) => BoardPiece.none));
    board[3][3] = board[4][4] = BoardPiece.white;
    board[3][4] = board[4][3] = BoardPiece.black;
    currentPlayer = BoardPiece.black;
    isGameOver = false;
    setState(() {});
  }

  void _onSquareTap(int r, int c) {
    if (isGameOver || board[r][c] != BoardPiece.none) return;
    
    List<Offset> flippedPositions = _getFlippablePieces(r, c, currentPlayer);
    if (flippedPositions.isEmpty) return;

    setState(() {
      board[r][c] = currentPlayer;
      for (var pos in flippedPositions) {
        board[pos.dx.toInt()][pos.dy.toInt()] = currentPlayer;
      }
      currentPlayer = (currentPlayer == BoardPiece.black) ? BoardPiece.white : BoardPiece.black;
      _checkGameOver();
    });
  }

  List<Offset> _getFlippablePieces(int r, int c, BoardPiece player) {
    List<Offset> flips = [];
    final directions = [
      [-1,-1], [-1,0], [-1,1], [0,-1], [0,1], [1,-1], [1,0], [1,1]
    ];
    
    for (var dir in directions) {
      List<Offset> temp = [];
      int currR = r + dir[0];
      int currC = c + dir[1];
      
      while (currR >= 0 && currR < size && currC >= 0 && currC < size) {
        if (board[currR][currC] == BoardPiece.none) break;
        if (board[currR][currC] == player) {
          flips.addAll(temp);
          break;
        }
        temp.add(Offset(currR.toDouble(), currC.toDouble()));
        currR += dir[0];
        currC += dir[1];
      }
    }
    return flips;
  }

  void _checkGameOver() {
    // Check if any player can move
    bool canBlackMove = _canPlayerMove(BoardPiece.black);
    bool canWhiteMove = _canPlayerMove(BoardPiece.white);
    
    if (!canBlackMove && !canWhiteMove) {
      isGameOver = true;
    } else if (currentPlayer == BoardPiece.black && !canBlackMove) {
      currentPlayer = BoardPiece.white;
    } else if (currentPlayer == BoardPiece.white && !canWhiteMove) {
      currentPlayer = BoardPiece.black;
    }
  }

  bool _canPlayerMove(BoardPiece player) {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == BoardPiece.none && _getFlippablePieces(r, c, player).isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    int blackCount = 0;
    int whiteCount = 0;
    for(var row in board) {
       for(var p in row) {
         if (p == BoardPiece.black) blackCount++;
         if (p == BoardPiece.white) whiteCount++;
       }
    }

    return GameWrapper(
      title: "Othello",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreInfo("BLACK", blackCount, BoardPiece.black),
                _buildScoreInfo("WHITE", whiteCount, BoardPiece.white),
              ],
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.green.shade900,
                child: GridView.builder(
                  itemCount: size * size,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size),
                  itemBuilder: (context, index) {
                    int r = index ~/ size;
                    int c = index % size;
                    return GestureDetector(
                      onTap: () => _onSquareTap(r, c),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 0.5)),
                        child: Center(
                          child: _buildPiece(board[r][c]),
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

  Widget _buildScoreInfo(String label, int count, BoardPiece player) {
    bool isCurrent = currentPlayer == player && !isGameOver;
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: isCurrent ? Colors.yellowAccent : Colors.white60, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(count.toString(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPiece(BoardPiece p) {
    if (p == BoardPiece.none) return const SizedBox();
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: p == BoardPiece.black ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: const Offset(1, 1))],
      ),
    );
  }
}
