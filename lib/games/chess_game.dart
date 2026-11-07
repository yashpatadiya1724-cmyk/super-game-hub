import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class ChessGame extends StatefulWidget {
  const ChessGame({super.key});

  @override
  State<ChessGame> createState() => _ChessGameState();
}

enum ChessPieceType { pawn, rook, knight, bishop, queen, king }
enum ChessPieceColor { white, black }

class ChessPiece {
  final ChessPieceType type;
  final ChessPieceColor color;
  const ChessPiece(this.type, this.color);
}

class _ChessGameState extends State<ChessGame> {
  late List<List<ChessPiece?>> board;
  int? selectedRow;
  int? selectedCol;
  ChessPieceColor currentPlayer = ChessPieceColor.white;

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    board = List.generate(8, (_) => List.filled(8, null));
    // Set pieces
    for (int i = 0; i < 8; i++) {
       board[1][i] = const ChessPiece(ChessPieceType.pawn, ChessPieceColor.black);
       board[6][i] = const ChessPiece(ChessPieceType.pawn, ChessPieceColor.white);
    }
    // Rooks
    board[0][0] = board[0][7] = const ChessPiece(ChessPieceType.rook, ChessPieceColor.black);
    board[7][0] = board[7][7] = const ChessPiece(ChessPieceType.rook, ChessPieceColor.white);
    // Knights
    board[0][1] = board[0][6] = const ChessPiece(ChessPieceType.knight, ChessPieceColor.black);
    board[7][1] = board[7][6] = const ChessPiece(ChessPieceType.knight, ChessPieceColor.white);
    // Bishops
    board[0][2] = board[0][5] = const ChessPiece(ChessPieceType.bishop, ChessPieceColor.black);
    board[7][2] = board[7][5] = const ChessPiece(ChessPieceType.bishop, ChessPieceColor.white);
    // Queen/King
    board[0][3] = const ChessPiece(ChessPieceType.queen, ChessPieceColor.black);
    board[0][4] = const ChessPiece(ChessPieceType.king, ChessPieceColor.black);
    board[7][3] = const ChessPiece(ChessPieceType.queen, ChessPieceColor.white);
    board[7][4] = const ChessPiece(ChessPieceType.king, ChessPieceColor.white);
    
    selectedRow = null;
    selectedCol = null;
    currentPlayer = ChessPieceColor.white;
  }

  void _onSquareTapped(int row, int col) {
    setState(() {
      if (selectedRow == null) {
        if (board[row][col]?.color == currentPlayer) {
          selectedRow = row;
          selectedCol = col;
        }
      } else {
        // Move selection
        if (selectedRow == row && selectedCol == col) {
          selectedRow = null;
          selectedCol = null;
        } else if (board[row][col]?.color == currentPlayer) {
          selectedRow = row;
          selectedCol = col;
        } else {
          // Attempt move (Simplified: All moves allowed for now to keep mini-game feel or basic board functionality)
          board[row][col] = board[selectedRow!][selectedCol!];
          board[selectedRow!][selectedCol!] = null;
          selectedRow = null;
          selectedCol = null;
          currentPlayer = currentPlayer == ChessPieceColor.white ? ChessPieceColor.black : ChessPieceColor.white;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Chess",
      onReset: _resetBoard,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${currentPlayer.name.toUpperCase()}'s TURN",
              style: GoogleFonts.outfit(color: currentPlayer == ChessPieceColor.white ? Colors.white : Colors.blue.shade300, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 2)),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    int row = index ~/ 8;
                    int col = index % 8;
                    bool isDark = (row + col) % 2 != 0;
                    bool isSelected = selectedRow == row && selectedCol == col;
                    
                    return GestureDetector(
                      onTap: () => _onSquareTapped(row, col),
                      child: Container(
                        color: isSelected 
                          ? Colors.yellow.withOpacity(0.4) 
                          : (isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.white10),
                        child: Center(
                          child: _buildPiece(board[row][col]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildPiece(ChessPiece? piece) {
    if (piece == null) return const SizedBox();
    IconData icon;
    switch (piece.type) {
      case ChessPieceType.pawn: icon = Icons.person; break;
      case ChessPieceType.rook: icon = Icons.castle; break;
      case ChessPieceType.knight: icon = Icons.pets; break;
      case ChessPieceType.bishop: icon = Icons.flare; break;
      case ChessPieceType.queen: icon = Icons.workspace_premium; break;
      case ChessPieceType.king: icon = Icons.military_tech; break;
    }
    return Icon(icon, color: piece.color == ChessPieceColor.white ? Colors.white : Colors.blue.shade300, size: 30);
  }
}
