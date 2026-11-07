import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../theme/app_theme.dart';

class ClassicLudoGame extends StatefulWidget {
  const ClassicLudoGame({super.key});

  @override
  State<ClassicLudoGame> createState() => _ClassicLudoGameState();
}

class Token {
  int playerIndex; // 0=Red, 1=Green, 2=Yellow, 3=Blue
  int position; // -1 = base. 0..51 = perimeter relative to board (Absolute). 52..56 = home stretch. 57 = home.
  int absolutePosId; // Actual index in the perimeter array.
  
  Token(this.playerIndex, this.position, {this.absolutePosId = -1});
}

class _ClassicLudoGameState extends State<ClassicLudoGame> {
  // Ludo 52-step path
  final List<List<int>> pathBlocks = [
    [1, 6], [2, 6], [3, 6], [4, 6], [5, 6], // Red path
    [6, 5], [6, 4], [6, 3], [6, 2], [6, 1], [6, 0], // Top arm left
    [7, 0], [8, 0], // Top turn
    [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], // Top arm right
    [9, 6], [10, 6], [11, 6], [12, 6], [13, 6], [14, 6], // Right arm top
    [14, 7], [14, 8], // Right turn
    [13, 8], [12, 8], [11, 8], [10, 8], [9, 8], // Right arm bottom
    [8, 9], [8, 10], [8, 11], [8, 12], [8, 13], [8, 14], // Bottom arm right
    [7, 14], [6, 14], // Bottom turn
    [6, 13], [6, 12], [6, 11], [6, 10], [6, 9], // Bottom arm left
    [5, 8], [4, 8], [3, 8], [2, 8], [1, 8], [0, 8], // Left arm bottom
    [0, 7], [0, 6] // Left turn
  ];

  final List<List<List<int>>> homePaths = [
    [[1, 7], [2, 7], [3, 7], [4, 7], [5, 7]], // 0: Red
    [[7, 1], [7, 2], [7, 3], [7, 4], [7, 5]], // 1: Green
    [[13, 7], [12, 7], [11, 7], [10, 7], [9, 7]], // 2: Yellow
    [[7, 13], [7, 12], [7, 11], [7, 10], [7, 9]], // 3: Blue
  ];

  // Colors - Updated for vibrant high contrast
  final List<Color> playerColors = [
    const Color(0xFFFF3333), // Vibrant Red
    const Color(0xFF19DF58), // Vibrant Green
    const Color(0xFFFFD500), // Vibrant Yellow
    const Color(0xFF1E90FF), // Vibrant Blue
  ];

  // Start Indices in perimeter array
  final List<int> startPos = [0, 13, 26, 39];
  final List<int> enteringHomePos = [50, 11, 24, 37]; // Moving past this index enters home stretch
  final List<int> safeIndices = [0, 8, 13, 21, 26, 34, 39, 47];

  List<Token> tokens = [];
  int currentPlayer = 0; // 0..3
  int diceValue = 1;
  bool isRolling = false;
  bool waitingForTokenTap = false;
  String message = "Red's Turn! Roll Dice.";

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    tokens.clear();
    for (int p = 0; p < 4; p++) {
      for (int i = 0; i < 4; i++) {
        tokens.add(Token(p, -1));
      }
    }
    setState(() {
      currentPlayer = 0;
      diceValue = 1;
      isRolling = false;
      waitingForTokenTap = false;
      message = "Red's Turn! Roll Dice.";
    });
  }

  Future<void> _rollDice() async {
    if (isRolling || waitingForTokenTap) return;
    setState(() {
      isRolling = true;
      message = "Rolling...";
    });

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => diceValue = Random().nextInt(6) + 1);
    }

    setState(() {
      isRolling = false;
      _evalMoves();
    });
  }

  void _evalMoves() {
    List<Token> movable = [];
    for (var t in tokens.where((x) => x.playerIndex == currentPlayer)) {
      if (t.position == -1 && diceValue == 6) {
        movable.add(t);
      } else if (t.position != -1 && t.position + diceValue <= 57) {
        movable.add(t);
      }
    }

    if (movable.isEmpty) {
      _nextTurn(extraTurn: false, msg: "No moves possible.");
    } else if (movable.length == 1) {
      _moveToken(movable.first);
    } else {
      bool allSamePos = movable.map((t) => t.position).toSet().length == 1 && movable.first.position != -1;
      if (allSamePos) {
        _moveToken(movable.first); // Auto move if all choices are literally the same token on top of each other
      } else {
        waitingForTokenTap = true;
        message = "Tap a pulsing token to move.";
      }
    }
  }

  void _nextTurn({required bool extraTurn, String? msg}) {
    if (!extraTurn) {
      currentPlayer = (currentPlayer + 1) % 4;
    }
    String colName = ["Red", "Green", "Yellow", "Blue"][currentPlayer];
    message = msg != null ? "$msg $colName's Turn." : "$colName's Turn.";
    waitingForTokenTap = false;
    
    // Check for win condition
    int wonTokens = tokens.where((t) => t.playerIndex == currentPlayer && t.position == 57).length;
    if (wonTokens == 4) {
      message = "$colName WINS!";
      waitingForTokenTap = true; // Lock the game
    }
  }

  void _moveToken(Token token) {
    bool captured = false;

    if (token.position == -1) {
      token.position = 0;
      token.absolutePosId = startPos[token.playerIndex];
    } else {
      for (int st = 0; st < diceValue; st++) {
        token.position++;
        if (token.position < 52) {
          token.absolutePosId = (token.absolutePosId + 1) % 52;
        }
      }
    }

    // Check Capture
    if (token.position < 52 && !safeIndices.contains(token.absolutePosId)) {
      for (var t in tokens) {
        if (t.playerIndex != token.playerIndex && t.position < 52 && t.absolutePosId == token.absolutePosId) {
          t.position = -1;
          t.absolutePosId = -1;
          captured = true;
          break; // Only capture one token
        }
      }
    }

    setState(() {
      _nextTurn(extraTurn: diceValue == 6 || captured, msg: captured ? "Captured!" : null);
    });
  }

  void _handleTokenTap(Token token) {
    if (!waitingForTokenTap || token.playerIndex != currentPlayer) return;
    if (token.position == -1 && diceValue != 6) return;
    if (token.position + diceValue > 57) return;

    setState(() => _moveToken(token));
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Classic Ludo",
      onReset: _resetGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: AppTheme.blocky(color: playerColors[currentPlayer].withValues(alpha: 0.5)),
            child: Text(
              message,
              style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2))]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.width * 0.95,
              child: _buildGrid(),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _rollDice,
            child: Container(
              width: 80,
              height: 80,
              decoration: AppTheme.blocky(color: playerColors[currentPlayer]),
              alignment: Alignment.center,
              child: isRolling
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("$diceValue", style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2))])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      decoration: AppTheme.blocky(color: AppTheme.surface),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 15,
        ),
        itemCount: 225,
        itemBuilder: (context, index) {
          int x = index % 15;
          int y = index ~/ 15;
          return _buildCell(x, y);
        },
      ),
    );
  }

  Widget _buildCell(int x, int y) {
    Color cellColor = Colors.white12;
    
    // Check if base
    if (x <= 5 && y <= 5) {
      cellColor = playerColors[0].withValues(alpha: 0.3);
    } else if (x >= 9 && y <= 5) {
      cellColor = playerColors[1].withValues(alpha: 0.3);
    } else if (x >= 9 && y >= 9) {
      cellColor = playerColors[2].withValues(alpha: 0.3);
    } else if (x <= 5 && y >= 9) {
      cellColor = playerColors[3].withValues(alpha: 0.3);
    }

    // Center Home
    if (x >= 6 && x <= 8 && y >= 6 && y <= 8) {
      if (x == 7 && y == 7) {
        cellColor = Colors.black87;
      } else if (x == 7 && y == 6) {
        cellColor = playerColors[1];
      } else if (x == 7 && y == 8) {
        cellColor = playerColors[3];
      } else if (x == 6 && y == 7) {
        cellColor = playerColors[0];
      } else if (x == 8 && y == 7) {
        cellColor = playerColors[2];
      } else {
        cellColor = Colors.white;
      }
    }

    // Identify perimeter path indices
    int pathIdx = pathBlocks.indexWhere((p) => p[0] == x && p[1] == y);
    if (pathIdx != -1) {
      cellColor = Colors.white24;
      if (safeIndices.contains(pathIdx)) {
        if (pathIdx == 0) {
          cellColor = playerColors[0].withValues(alpha: 0.7);
        } else if (pathIdx == 13) {
          cellColor = playerColors[1].withValues(alpha: 0.7);
        } else if (pathIdx == 26) {
          cellColor = playerColors[2].withValues(alpha: 0.7);
        } else if (pathIdx == 39) {
          cellColor = playerColors[3].withValues(alpha: 0.7);
        } else {
          cellColor = Colors.grey; // Extra safe spots
        }
      }
    }

    // Home stretches
    for (int p = 0; p < 4; p++) {
      int homeIdx = homePaths[p].indexWhere((pos) => pos[0] == x && pos[1] == y);
      if (homeIdx != -1) {
        cellColor = playerColors[p].withValues(alpha: 0.7);
      }
    }

    // Find Tokens at this exact coordinate
    List<Token> cellTokens = [];

    // Base Tokens
    for (var t in tokens) {
      if (t.position == -1) {
        if (t.playerIndex == 0 && x == 2 + (t.hashCode % 2)*2 && y == 2 + (t.hashCode ~/ 2 % 2)*2) {
          cellTokens.add(t);
        }
        if (t.playerIndex == 1 && x == 11 + (t.hashCode % 2)*2 && y == 2 + (t.hashCode ~/ 2 % 2)*2) {
          cellTokens.add(t);
        }
        if (t.playerIndex == 2 && x == 11 + (t.hashCode % 2)*2 && y == 11 + (t.hashCode ~/ 2 % 2)*2) {
          cellTokens.add(t);
        }
        if (t.playerIndex == 3 && x == 2 + (t.hashCode % 2)*2 && y == 11 + (t.hashCode ~/ 2 % 2)*2) {
          cellTokens.add(t);
        }
      } else if (t.position < 52) {
        if (pathBlocks[t.absolutePosId][0] == x && pathBlocks[t.absolutePosId][1] == y) {
          cellTokens.add(t);
        }
      } else if (t.position < 57) {
        if (homePaths[t.playerIndex][t.position - 52][0] == x && homePaths[t.playerIndex][t.position - 52][1] == y) {
          cellTokens.add(t);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor, 
        border: Border.all(color: Colors.black87, width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: cellTokens.map((t) {
          bool isClickable = waitingForTokenTap && t.playerIndex == currentPlayer;
          // Visual stacking
          double offsetAmt = (cellTokens.indexOf(t) * 3).toDouble();
          return Transform.translate(
            offset: Offset(offsetAmt, offsetAmt),
            child: GestureDetector(
              onTap: () => _handleTokenTap(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isClickable ? 18 : 14,
                height: isClickable ? 18 : 14,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.white.withValues(alpha: 0.6), playerColors[t.playerIndex]],
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.8,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: isClickable ? Colors.white : Colors.black87, width: isClickable ? 1.5 : 1.0),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 3, offset: const Offset(1, 2)),
                    if (isClickable) const BoxShadow(color: Colors.yellowAccent, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
