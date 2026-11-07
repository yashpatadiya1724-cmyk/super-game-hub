import 'package:flutter/material.dart';

/// A widget that renders a game logo using a custom painter.
class GameLogo extends StatelessWidget {
  final String gameId;
  final Color themeColor;
  final double size;

  const GameLogo({
    super.key,
    required this.gameId,
    required this.themeColor,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: CustomPaint(
          painter: _getPainter(gameId, themeColor),
        ),
      ),
    );
  }

  CustomPainter _getPainter(String id, Color color) {
    switch (id) {
      case 'snake':
        return SnakeLogoPainter(color);
      case 'bird':
        return BirdLogoPainter(color);
      case 'tictactoe':
        return TicTacToeLogoPainter(color);
      case 'pong':
        return PongLogoPainter(color);
      case 'brick_breaker':
        return BrickBreakerLogoPainter(color);
      case '2048':
        return Game2048LogoPainter(color);
      case 'minesweeper':
        return MinesweeperLogoPainter(color);
      case 'sudoku':
        return SudokuLogoPainter(color);
      case 'memorymatch':
        return MemoryMatchLogoPainter(color);
      case 'connect_four':
        return ConnectFourLogoPainter(color);
      case 'dots_and_boxes':
        return DotsAndBoxesLogoPainter(color);
      case 'classic_ludo':
        return LudoLogoPainter(color);
      case 'air_hockey':
        return AirHockeyLogoPainter(color);
      case 'chess':
        return ChessLogoPainter(color);
      case 'pinball':
        return PinballLogoPainter(color);
      case 'solitaire':
        return SolitaireLogoPainter(color);
      case 'word_search':
        return WordSearchLogoPainter(color);
      case 'jigsaw_puzzle':
        return JigsawPuzzleLogoPainter(color);
      case 'tower_defender':
        return TowerDefenderLogoPainter(color);
      case 'tank_wars':
        return TankWarsLogoPainter(color);
      case 'thumb_fighter':
        return ThumbFighterLogoPainter(color);
      case 'racing_blocks':
        return RacingBlocksLogoPainter(color);
      case 'othello':
        return OthelloLogoPainter(color);
      case 'go_fish':
        return GoFishLogoPainter(color);
      case 'tic_tac_toe_3d':
        return TicTacToe3DLogoPainter(color);
      case 'battleship':
        return BattleshipLogoPainter(color);
      case 'truth_or_dare':
        return TruthOrDareLogoPainter(color);
      case 'hangman':
        return HangmanLogoPainter(color);
      case 'number_guesser':
        return NumberGuesserLogoPainter(color);
      case 'finger_battle':
        return FingerBattleLogoPainter(color);
      case 'tap_color':
        return TapColorLogoPainter(color);
      case 'bubble_pop':
        return BubblePopLogoPainter(color);
      case 'color_match':
        return ColorMatchLogoPainter(color);
      case 'whack_a_mole':
        return WhackAMoleLogoPainter(color);
      default:
        return GenericLogoPainter(color, id.isNotEmpty ? id[0].toUpperCase() : 'G');
    }
  }
}

class AirHockeyLogoPainter extends CustomPainter {
  final Color color;
  AirHockeyLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    // Table lines
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.1, w*0.8, w*0.8), p);
    canvas.drawLine(Offset(w*0.1, w*0.5), Offset(w*0.9, w*0.5), p);
    canvas.drawCircle(Offset(w*0.5, w*0.5), w*0.15, p);
    // Mallets
    canvas.drawCircle(Offset(w*0.5, w*0.25), w*0.08, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(w*0.5, w*0.75), w*0.08, Paint()..color = Colors.blue);
    // Puck
    canvas.drawCircle(Offset(w*0.4, w*0.45), w*0.05, Paint()..color = Colors.white);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ChessLogoPainter extends CustomPainter {
  final Color color;
  ChessLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Board grid
    for(int i=0; i<4; i++) {
      for(int j=0; j<4; j++) {
        if((i+j)%2 == 0) {
          canvas.drawRect(Rect.fromLTWH(w*0.1 + i*w*0.2, w*0.1 + j*w*0.2, w*0.2, w*0.2), Paint()..color = color.withValues(alpha: 0.5));
        }
      }
    }
    // A simplified Knight piece
    final p = Paint()..color = Colors.white;
    canvas.drawPath(Path()..moveTo(w*0.3, w*0.8)..lineTo(w*0.7, w*0.8)..lineTo(w*0.6, w*0.4)..lineTo(w*0.8, w*0.3)..lineTo(w*0.7, w*0.2)..lineTo(w*0.4, w*0.2)..close(), p);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PinballLogoPainter extends CustomPainter {
  final Color color;
  PinballLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3;
    // Outer frame
    canvas.drawPath(Path()..moveTo(w*0.2, w*0.9)..lineTo(w*0.2, w*0.2)..quadraticBezierTo(w*0.5, 0, w*0.8, w*0.2)..lineTo(w*0.8, w*0.9), p);
    // Flippers
    canvas.drawLine(Offset(w*0.3, w*0.85), Offset(w*0.45, w*0.8), Paint()..color = Colors.red..strokeWidth = 5);
    canvas.drawLine(Offset(w*0.7, w*0.85), Offset(w*0.55, w*0.8), Paint()..color = Colors.red..strokeWidth = 5);
    // Ball
    canvas.drawCircle(Offset(w*0.5, w*0.4), w*0.05, Paint()..color = Colors.white);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SolitaireLogoPainter extends CustomPainter {
  final Color color;
  SolitaireLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Stacked cards
    for(int i=0; i<3; i++) {
      canvas.drawRRect(RRect.fromLTRBR(w*0.15 + i*w*0.15, w*0.2 + i*w*0.1, w*0.5 + i*w*0.15, w*0.7 + i*w*0.1, const Radius.circular(4)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromLTRBR(w*0.15 + i*w*0.15, w*0.2 + i*w*0.1, w*0.5 + i*w*0.15, w*0.7 + i*w*0.1, const Radius.circular(4)), Paint()..color = color.withValues(alpha: 0.3)..style = PaintingStyle.stroke);
    }
    // Ace of Spades symbol on top card
    final p = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(w*0.52, w*0.5), w*0.04, p);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WordSearchLogoPainter extends CustomPainter {
  final Color color;
  WordSearchLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Letter grid
    final letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I"];
    for(int i=0; i<3; i++) {
      for(int j=0; j<3; j++) {
        final tp = TextPainter(text: TextSpan(text: letters[i*3+j], style: TextStyle(color: Colors.white24, fontSize: w*0.15)), textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(w*0.2 + i*w*0.25, w*0.2 + j*w*0.25));
      }
    }
    // Highlighting a word
    final p = Paint()..color = color.withValues(alpha: 0.4)..strokeCap = StrokeCap.round..strokeWidth = w*0.15;
    canvas.drawLine(Offset(w*0.25, w*0.25), Offset(w*0.75, w*0.75), p);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class JigsawPuzzleLogoPainter extends CustomPainter {
  final Color color;
  JigsawPuzzleLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color;
    // A simplified puzzle piece shape
    final path = Path()
      ..moveTo(w*0.3, w*0.3)
      ..lineTo(w*0.45, w*0.3)..arcToPoint(Offset(w*0.55, w*0.3), radius: Radius.circular(w*0.05))
      ..lineTo(w*0.7, w*0.3)
      ..lineTo(w*0.7, w*0.45)..arcToPoint(Offset(w*0.7, w*0.55), radius: Radius.circular(w*0.05), clockwise: false)
      ..lineTo(w*0.7, w*0.7)
      ..lineTo(w*0.3, w*0.7)..close();
    canvas.drawPath(path, p);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TowerDefenderLogoPainter extends CustomPainter {
  final Color color;
  TowerDefenderLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Castle tower
    canvas.drawRect(Rect.fromLTWH(w*0.3, w*0.4, w*0.4, w*0.5), Paint()..color = color);
    // Battlements
    for(int i=0; i<3; i++) {
       canvas.drawRect(Rect.fromLTWH(w*0.3 + i*w*0.15, w*0.3, w*0.1, w*0.15), Paint()..color = color);
    }
    // Flag
    canvas.drawLine(Offset(w*0.5, w*0.3), Offset(w*0.5, w*0.15), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(w*0.5, w*0.15, w*0.2, w*0.1), Paint()..color = Colors.red);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TankWarsLogoPainter extends CustomPainter {
  final Color color;
  TankWarsLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color;
    // Tank body
    canvas.drawRRect(RRect.fromLTRBR(w*0.2, w*0.5, w*0.8, w*0.8, const Radius.circular(5)), p);
    // Turret
    canvas.drawRRect(RRect.fromLTRBR(w*0.35, w*0.35, w*0.65, w*0.5, const Radius.circular(5)), p);
    // Barrel
    canvas.drawRect(Rect.fromLTWH(w*0.65, w*0.4, w*0.25, w*0.08), p);
    // Wheels
    for(int i=0; i<4; i++) {
      canvas.drawCircle(Offset(w*0.3 + i*w*0.13, w*0.8), w*0.05, Paint()..color = Colors.black);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ThumbFighterLogoPainter extends CustomPainter {
  final Color color;
  ThumbFighterLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Two thumbs clashing
    final p1 = Paint()..color = Colors.orange.shade300;
    canvas.drawRRect(RRect.fromLTRBR(w*0.1, w*0.4, w*0.3, w*0.9, const Radius.circular(10)), p1);
    canvas.drawRect(Rect.fromLTWH(w*0.3, w*0.5, w*0.15, w*0.1), p1); // thumb tip
    
    final p2 = Paint()..color = Colors.pink.shade300;
    canvas.drawRRect(RRect.fromLTRBR(w*0.7, w*0.4, w*0.9, w*0.9, const Radius.circular(10)), p2);
    canvas.drawRect(Rect.fromLTWH(w*0.55, w*0.5, w*0.15, w*0.1), p2); // thumb tip
    
    // Spark
    canvas.drawCircle(Offset(w*0.5, w*0.45), w*0.08, Paint()..color = Colors.yellowAccent);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RacingBlocksLogoPainter extends CustomPainter {
  final Color color;
  RacingBlocksLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Road lines
    final rp = Paint()..color = Colors.white12;
    canvas.drawRect(Rect.fromLTWH(w*0.45, 0, w*0.1, w), rp);
    // Two racing blocks
    canvas.drawRect(Rect.fromLTWH(w*0.2, w*0.6, w*0.2, w*0.2), Paint()..color = Colors.blueAccent);
    canvas.drawRect(Rect.fromLTWH(w*0.6, w*0.3, w*0.2, w*0.2), Paint()..color = Colors.redAccent);
    // Finish line
    for(int i=0; i<10; i++) {
      canvas.drawRect(Rect.fromLTWH(i*w*0.1, w*0.1, w*0.1, w*0.05), Paint()..color = i%2==0 ? Colors.white : Colors.black);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class OthelloLogoPainter extends CustomPainter {
  final Color color;
  OthelloLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.1, w*0.8, w*0.8), Paint()..color = Colors.green.shade900);
    // Grid
    final gp = Paint()..color = Colors.white12..style = PaintingStyle.stroke;
    for(int i=1; i<4; i++) {
       canvas.drawLine(Offset(w*0.1 + i*w*0.2, w*0.1), Offset(w*0.1 + i*w*0.2, w*0.9), gp);
       canvas.drawLine(Offset(w*0.1, w*0.1 + i*w*0.2), Offset(w*0.9, w*0.1 + i*w*0.2), gp);
    }
    // Chips 
    canvas.drawCircle(Offset(w*0.4, w*0.4), w*0.08, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w*0.6, w*0.6), w*0.08, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w*0.6, w*0.4), w*0.08, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(w*0.4, w*0.6), w*0.08, Paint()..color = Colors.black);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GoFishLogoPainter extends CustomPainter {
  final Color color;
  GoFishLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Fish shape
    final p = Paint()..color = color;
    final path = Path()
      ..moveTo(w*0.2, w*0.5)
      ..quadraticBezierTo(w*0.4, w*0.2, w*0.7, w*0.5)
      ..quadraticBezierTo(w*0.4, w*0.8, w*0.2, w*0.5)
      ..moveTo(w*0.7, w*0.5)
      ..lineTo(w*0.9, w*0.3)
      ..lineTo(w*0.9, w*0.7)
      ..close();
    canvas.drawPath(path, p);
    // Eye
    canvas.drawCircle(Offset(w*0.35, w*0.45), w*0.03, Paint()..color = Colors.white);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TicTacToe3DLogoPainter extends CustomPainter {
  final Color color;
  TicTacToe3DLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    // Three layers of grids
    for(int i=0; i<3; i++) {
       final yOffset = w*0.2 + i*w*0.25;
       canvas.drawRect(Rect.fromLTWH(w*0.2, yOffset, w*0.6, w*0.15), p);
       canvas.drawLine(Offset(w*0.4, yOffset), Offset(w*0.4, yOffset + w*0.15), p);
       canvas.drawLine(Offset(w*0.6, yOffset), Offset(w*0.6, yOffset + w*0.15), p);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BattleshipLogoPainter extends CustomPainter {
  final Color color;
  BattleshipLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color;
    // Ship hull
    canvas.drawPath(Path()..moveTo(w*0.1, w*0.6)..lineTo(w*0.9, w*0.6)..lineTo(w*0.8, w*0.8)..lineTo(w*0.2, w*0.8)..close(), p);
    // Bridge
    canvas.drawRect(Rect.fromLTWH(w*0.4, w*0.4, w*0.2, w*0.2), p);
    // Radar
    canvas.drawLine(Offset(w*0.5, w*0.4), Offset(w*0.5, w*0.2), Paint()..color = Colors.white);
    // Water
    final wp = Paint()..color = Colors.blue.withValues(alpha: 0.3);
    canvas.drawRect(Rect.fromLTWH(0, w*0.7, w, w*0.3), wp);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TruthOrDareLogoPainter extends CustomPainter {
  final Color color;
  TruthOrDareLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Spinning bottle
    canvas.save();
    canvas.translate(w*0.5, w*0.5);
    canvas.rotate(0.5);
    canvas.drawRRect(RRect.fromLTRBR(-w*0.08, -w*0.3, w*0.08, w*0.3, const Radius.circular(5)), Paint()..color = color);
    canvas.drawCircle(Offset(0, -w*0.35), w*0.05, Paint()..color = Colors.white70);
    canvas.restore();
    // Question marks
    final tp = TextPainter(text: TextSpan(text: "?", style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: w*0.3)), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(w*0.1, w*0.1));
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HangmanLogoPainter extends CustomPainter {
  final Color color;
  HangmanLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color..strokeWidth = 3..style = PaintingStyle.stroke;
    // Gallows
    canvas.drawLine(Offset(w*0.2, w*0.9), Offset(w*0.6, w*0.9), p);
    canvas.drawLine(Offset(w*0.3, w*0.9), Offset(w*0.3, w*0.1), p);
    canvas.drawLine(Offset(w*0.3, w*0.1), Offset(w*0.7, w*0.1), p);
    canvas.drawLine(Offset(w*0.7, w*0.1), Offset(w*0.7, w*0.25), p);
    // Victim (simplified)
    canvas.drawCircle(Offset(w*0.7, w*0.35), w*0.1, p);
    canvas.drawLine(Offset(w*0.7, w*0.45), Offset(w*0.7, w*0.7), p);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NumberGuesserLogoPainter extends CustomPainter {
  final Color color;
  NumberGuesserLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Numbers cloud
    final tp = TextPainter(text: TextSpan(text: "7", style: TextStyle(color: color, fontSize: w*0.5, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(w*0.3, w*0.2));
    
    final tp2 = TextPainter(text: TextSpan(text: "42", style: TextStyle(color: color.withValues(alpha: 0.3), fontSize: w*0.2)), textDirection: TextDirection.ltr);
    tp2.layout();
    tp2.paint(canvas, Offset(w*0.1, w*0.6));
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FingerBattleLogoPainter extends CustomPainter {
  final Color color;
  FingerBattleLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Red vs Blue sides
    canvas.drawRect(Rect.fromLTWH(0, 0, w, w*0.5), Paint()..color = Colors.red.withValues(alpha: 0.5));
    canvas.drawRect(Rect.fromLTWH(0, w*0.5, w, w*0.5), Paint()..color = Colors.blue.withValues(alpha: 0.5));
    // Tap icons
    canvas.drawCircle(Offset(w*0.5, w*0.25), w*0.1, Paint()..color = Colors.white54);
    canvas.drawCircle(Offset(w*0.5, w*0.75), w*0.1, Paint()..color = Colors.white54);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TapColorLogoPainter extends CustomPainter {
  final Color color;
  TapColorLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Colored circles
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
    for(int i=0; i<4; i++) {
       canvas.drawCircle(Offset(w*0.3 + (i%2)*w*0.4, w*0.3 + (i~/2)*w*0.4), w*0.15, Paint()..color = colors[i]);
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SnakeLogoPainter extends CustomPainter {
  final Color color;
  SnakeLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width / 8;
    final h = size.height / 8;

    // Draw a pixelated snake 'S' shape
    final snakePixels = [
      [1, 1], [2, 1], [3, 1], [4, 1],
      [1, 2],
      [1, 3], [2, 3], [3, 3], [4, 3],
      [4, 4],
      [4, 5], [3, 5], [2, 5], [1, 5],
      [1, 6],
    ];

    for (var p in snakePixels) {
      canvas.drawRect(Rect.fromLTWH((p[0] + 1) * w, (p[1] + 1) * h, w - 1, h - 1), paint);
    }

    // Add a 'head' eye
    canvas.drawRect(Rect.fromLTWH(2 * w + 2, 7 * h + 2, 4, 4), Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BirdLogoPainter extends CustomPainter {
  final Color color;
  BirdLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width / 10;
    
    // Body
    canvas.drawRect(Rect.fromLTWH(3*w, 3*w, 4*w, 4*w), paint);
    // Beak
    canvas.drawRect(Rect.fromLTWH(7*w, 4*w, 2*w, 2*w), Paint()..color = Colors.orange);
    // Eye
    canvas.drawRect(Rect.fromLTWH(6*w, 4*w, w, w), Paint()..color = Colors.white);
    // Wing
    canvas.drawRect(Rect.fromLTWH(2*w, 4*w, 2*w, 2*w), Paint()..color = Colors.white38);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TicTacToeLogoPainter extends CustomPainter {
  final Color color;
  TicTacToeLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 4..style = PaintingStyle.stroke;
    final w = size.width;
    
    // Grid
    canvas.drawLine(Offset(w*0.33, w*0.1), Offset(w*0.33, w*0.9), paint);
    canvas.drawLine(Offset(w*0.66, w*0.1), Offset(w*0.66, w*0.9), paint);
    canvas.drawLine(Offset(w*0.1, w*0.33), Offset(w*0.9, w*0.33), paint);
    canvas.drawLine(Offset(w*0.1, w*0.66), Offset(w*0.9, w*0.66), paint);

    // One X and One O
    final pX = Paint()..color = Colors.redAccent..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w*0.1, w*0.1), Offset(w*0.25, w*0.25), pX);
    canvas.drawLine(Offset(w*0.25, w*0.1), Offset(w*0.1, w*0.25), pX);
    
    final pO = Paint()..color = Colors.blueAccent..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w*0.82, w*0.82), w*0.08, pO);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PongLogoPainter extends CustomPainter {
  final Color color;
  PongLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final w = size.width;
    
    // Left Paddle
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.3, w*0.1, w*0.4), p);
    // Right Paddle
    canvas.drawRect(Rect.fromLTWH(w*0.8, w*0.4, w*0.1, w*0.4), p);
    // Ball
    canvas.drawRect(Rect.fromLTWH(w*0.45, w*0.45, w*0.1, w*0.1), Paint()..color = Colors.white);
    // Dotted line
    final dashP = Paint()..color = Colors.white12;
    for(double i=0; i<w; i+=10) {
      canvas.drawRect(Rect.fromLTWH(w*0.48, i, 2, 5), dashP);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BrickBreakerLogoPainter extends CustomPainter {
  final Color color;
  BrickBreakerLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    
    // Bricks
    for(int i=0; i<3; i++) {
       for(int j=0; j<3; j++) {
         canvas.drawRect(
           Rect.fromLTWH(w*0.1 + i*w*0.28, w*0.1 + j*w*0.12, w*0.24, w*0.08), 
           Paint()..color = color.withValues(alpha: 1.0 - (j*0.2))
         );
       }
    }
    // Paddle 
    canvas.drawRect(Rect.fromLTWH(w*0.3, w*0.8, w*0.4, w*0.06), Paint()..color = Colors.white54);
    // Ball
    canvas.drawCircle(Offset(w*0.5, w*0.7), w*0.04, Paint()..color = Colors.yellowAccent);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Game2048LogoPainter extends CustomPainter {
  final Color color;
  Game2048LogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.1, w*0.8, w*0.8), Paint()..color = color.withValues(alpha: 0.3));
    
    final textStyle = TextStyle(color: color, fontSize: w*0.3, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: "2k", style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w*0.2, w*0.3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MinesweeperLogoPainter extends CustomPainter {
  final Color color;
  MinesweeperLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Main bomb body
    canvas.drawCircle(Offset(w*0.5, w*0.55), w*0.3, Paint()..color = Colors.grey.shade800);
    // Spike
    canvas.drawRect(Rect.fromLTWH(w*0.45, w*0.2, w*0.1, w*0.1), Paint()..color = Colors.grey.shade700);
    // Fuse
    final fuseP = Paint()..color = Colors.orangeAccent..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(w*0.5, w*0.2)..quadraticBezierTo(w*0.6, w*0.1, w*0.7, w*0.15), fuseP);
    // Number '3'
    final textPainter = TextPainter(
      text: TextSpan(text: "3", style: TextStyle(color: color, fontSize: w*0.25, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w*0.1, w*0.1));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SudokuLogoPainter extends CustomPainter {
  final Color color;
  SudokuLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color..strokeWidth = 1..style = PaintingStyle.stroke;
    
    // Grid
    for(int i=1; i<4; i++) {
      canvas.drawLine(Offset(i*w*0.25, w*0.1), Offset(i*w*0.25, w*0.9), p);
      canvas.drawLine(Offset(w*0.1, i*w*0.25), Offset(w*0.9, i*w*0.25), p);
    }

    final tp = TextPainter(
      text: TextSpan(text: "9", style: TextStyle(color: color, fontSize: w*0.4, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(w*0.35, w*0.3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MemoryMatchLogoPainter extends CustomPainter {
  final Color color;
  MemoryMatchLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Two matching "cards"
    canvas.drawRRect(RRect.fromLTRBR(w*0.1, w*0.2, w*0.45, w*0.8, const Radius.circular(4)), Paint()..color = color);
    canvas.drawRRect(RRect.fromLTRBR(w*0.55, w*0.2, w*0.9, w*0.8, const Radius.circular(4)), Paint()..color = color);
    
    // Question marks
    final tp = TextPainter(
      text: TextSpan(text: "?", style: TextStyle(color: Colors.black54, fontSize: w*0.3, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(w*0.18, w*0.35));
    tp.paint(canvas, Offset(w*0.62, w*0.35));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ConnectFourLogoPainter extends CustomPainter {
  final Color color;
  ConnectFourLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.1, w*0.8, w*0.8), Paint()..color = Colors.blue.shade900);
    
    // Some holes with pieces
    for(int i=0; i<3; i++) {
      for(int j=0; j<3; j++) {
        Color c = Colors.black26;
        if(i == 1 && j == 1) c = Colors.red;
        if(i == 1 && j == 2) c = Colors.yellow;
        canvas.drawCircle(Offset(w*0.25 + i*w*0.25, w*0.25 + j*w*0.25), w*0.08, Paint()..color = c);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DotsAndBoxesLogoPainter extends CustomPainter {
  final Color color;
  DotsAndBoxesLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = Colors.white54;
    
    // Draw dots
    for(int i=0; i<3; i++) {
       for(int j=0; j<3; j++) {
         canvas.drawCircle(Offset(w*0.2 + i*w*0.3, w*0.2 + j*w*0.3), 3, p);
       }
    }
    // Some lines
    final lp = Paint()..color = color..strokeWidth = 3;
    canvas.drawLine(Offset(w*0.2, w*0.2), Offset(w*0.5, w*0.2), lp);
    canvas.drawLine(Offset(w*0.2, w*0.2), Offset(w*0.2, w*0.5), lp);
    // Filled box
    canvas.drawRect(Rect.fromLTWH(w*0.52, w*0.52, w*0.26, w*0.26), Paint()..color = color.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LudoLogoPainter extends CustomPainter {
  final Color color;
  LudoLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // 4 colors quadrants
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.1, w*0.4, w*0.4), Paint()..color = Colors.red.shade400);
    canvas.drawRect(Rect.fromLTWH(w*0.5, w*0.1, w*0.4, w*0.4), Paint()..color = Colors.green.shade400);
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.5, w*0.4, w*0.4), Paint()..color = Colors.blue.shade400);
    canvas.drawRect(Rect.fromLTWH(w*0.5, w*0.5, w*0.4, w*0.4), Paint()..color = Colors.yellow.shade400);
    
    // Center white cross
    canvas.drawRect(Rect.fromLTWH(w*0.4, w*0.1, w*0.2, w*0.8), Paint()..color = Colors.white24);
    canvas.drawRect(Rect.fromLTWH(w*0.1, w*0.4, w*0.8, w*0.2), Paint()..color = Colors.white24);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GenericLogoPainter extends CustomPainter {
  final Color color;
  final String letter;
  GenericLogoPainter(this.color, this.letter);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Block background
    canvas.drawRect(Rect.fromLTWH(w*0.2, w*0.2, w*0.6, w*0.6), Paint()..color = color.withValues(alpha: 0.2));
    
    final tp = TextPainter(
      text: TextSpan(text: letter, style: TextStyle(color: color, fontSize: w*0.5, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(w*0.3, w*0.25));
    
    // Decorative corners
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(w*0.1, w*0.3)..lineTo(w*0.1, w*0.1)..lineTo(w*0.3, w*0.1), p);
    canvas.drawPath(Path()..moveTo(w*0.7, w*0.9)..lineTo(w*0.9, w*0.9)..lineTo(w*0.9, w*0.7), p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BubblePopLogoPainter extends CustomPainter {
  final Color color;
  BubblePopLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final p = Paint()..color = color.withValues(alpha: 0.6)..style = PaintingStyle.fill;
    final stroke = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(w * 0.35, w * 0.4), w * 0.22, p);
    canvas.drawCircle(Offset(w * 0.35, w * 0.4), w * 0.22, stroke);

    canvas.drawCircle(Offset(w * 0.65, w * 0.65), w * 0.25, p);
    canvas.drawCircle(Offset(w * 0.65, w * 0.65), w * 0.25, stroke);

    canvas.drawCircle(Offset(w * 0.7, w * 0.25), w * 0.12, p);
    canvas.drawCircle(Offset(w * 0.7, w * 0.25), w * 0.12, stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ColorMatchLogoPainter extends CustomPainter {
  final Color color;
  ColorMatchLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final paints = [
      Paint()..color = Colors.redAccent,
      Paint()..color = Colors.blueAccent,
      Paint()..color = Colors.greenAccent,
      Paint()..color = Colors.amberAccent,
    ];
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, w * 0.15, w * 0.3, w * 0.3), const Radius.circular(8)), paints[0]);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, w * 0.15, w * 0.3, w * 0.3), const Radius.circular(8)), paints[1]);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, w * 0.55, w * 0.3, w * 0.3), const Radius.circular(8)), paints[2]);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, w * 0.55, w * 0.3, w * 0.3), const Radius.circular(8)), paints[3]);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WhackAMoleLogoPainter extends CustomPainter {
  final Color color;
  WhackAMoleLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final mound = Paint()..color = Colors.brown.shade700..style = PaintingStyle.fill;
    final mole = Paint()..color = Colors.brown.shade400..style = PaintingStyle.fill;
    final eyes = Paint()..color = Colors.black..style = PaintingStyle.fill;

    // Mole body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, w * 0.25, w * 0.4, w * 0.5), const Radius.circular(16)), mole);
    // Eyes
    canvas.drawCircle(Offset(w * 0.4, w * 0.4), w * 0.04, eyes);
    canvas.drawCircle(Offset(w * 0.6, w * 0.4), w * 0.04, eyes);
    // Nose
    canvas.drawCircle(Offset(w * 0.5, w * 0.5), w * 0.05, Paint()..color = Colors.pinkAccent);
    // Mound / Hole
    canvas.drawOval(Rect.fromLTWH(w * 0.15, w * 0.65, w * 0.7, w * 0.25), mound);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
