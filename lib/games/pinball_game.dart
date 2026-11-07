import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class PinballGame extends StatefulWidget {
  const PinballGame({super.key});

  @override
  State<PinballGame> createState() => _PinballGameState();
}

class _PinballGameState extends State<PinballGame> {
  static const double ballRadius = 12.0;
  static const double bumperRadius = 25.0;
  
  Offset ballPos = Offset.zero;
  Offset ballVelocity = const Offset(0, 0);
  int score = 0;
  Timer? gameTimer;
  Size? boardSize;
  
  bool leftFlipperUp = false;
  bool rightFlipperUp = false;
  
  final List<Offset> bumpers = [
    const Offset(100, 150),
    const Offset(200, 150),
    const Offset(150, 250),
  ];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    if (boardSize != null) {
      ballPos = Offset(boardSize!.width * 0.8, boardSize!.height * 0.8);
      ballVelocity = const Offset(-2, -10);
    }
  }

  void _startGame() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updatePhysics();
    });
  }

  void _updatePhysics() {
    if (boardSize == null) return;

    setState(() {
      // Gravity
      ballVelocity += const Offset(0, 0.2);
      ballPos += ballVelocity;

      // Wall collisions
      if (ballPos.dx <= ballRadius || ballPos.dx >= boardSize!.width - ballRadius) {
        ballVelocity = Offset(-ballVelocity.dx * 0.8, ballVelocity.dy);
        ballPos = Offset(ballPos.dx.clamp(ballRadius, boardSize!.width - ballRadius), ballPos.dy);
      }
      if (ballPos.dy <= ballRadius) {
        ballVelocity = Offset(ballVelocity.dx, -ballVelocity.dy * 0.8);
        ballPos = Offset(ballPos.dx, ballRadius);
      }

      // Lose ball
      if (ballPos.dy >= boardSize!.height + 50) {
        _resetGame();
      }

      // Bumpers
      for (var bumper in bumpers) {
        double dist = (ballPos - bumper).distance;
        if (dist < bumperRadius + ballRadius) {
          Offset normal = (ballPos - bumper) / dist;
          ballVelocity = normal * 12.0;
          score += 10;
        }
      }

      // Flippers (Simplified physics)
      double flipperY = boardSize!.height * 0.85;
      if (ballPos.dy > flipperY - 20 && ballPos.dy < flipperY + 20) {
        if (leftFlipperUp && ballPos.dx < boardSize!.width / 2 && ballPos.dx > 50) {
          ballVelocity = const Offset(2, -15);
          score += 5;
        }
        if (rightFlipperUp && ballPos.dx > boardSize!.width / 2 && ballPos.dx < boardSize!.width - 50) {
          ballVelocity = const Offset(-2, -15);
          score += 5;
        }
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Pinball",
      onReset: () {
        setState(() => score = 0);
        _resetGame();
      },
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text("SCORE: $score", style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (boardSize == null) {
                  boardSize = Size(constraints.maxWidth, constraints.maxHeight);
                  _resetGame();
                  _startGame();
                }
                return GestureDetector(
                  onTapDown: (details) {
                    if (details.localPosition.dx < boardSize!.width / 2) {
                      setState(() => leftFlipperUp = true);
                    } else {
                      setState(() => rightFlipperUp = true);
                    }
                  },
                  onTapUp: (_) {
                    setState(() {
                      leftFlipperUp = false;
                      rightFlipperUp = false;
                    });
                  },
                  child: Container(
                    color: Colors.black,
                    child: CustomPaint(
                      size: boardSize!,
                      painter: _PinballPainter(
                        ballPos: ballPos,
                        bumpers: bumpers,
                        leftFlipperUp: leftFlipperUp,
                        rightFlipperUp: rightFlipperUp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PinballPainter extends CustomPainter {
  final Offset ballPos;
  final List<Offset> bumpers;
  final bool leftFlipperUp;
  final bool rightFlipperUp;

  _PinballPainter({
    required this.ballPos,
    required this.bumpers,
    required this.leftFlipperUp,
    required this.rightFlipperUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Bumpers
    for (var bumper in bumpers) {
      canvas.drawCircle(bumper, 25, Paint()..color = Colors.pinkAccent);
      canvas.drawCircle(bumper, 20, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    
    // Flippers
    final flipperPaint = Paint()..color = Colors.redAccent..strokeWidth = 10..strokeCap = StrokeCap.round;
    double flipperY = size.height * 0.85;
    
    // Left Flipper
    canvas.drawLine(
      Offset(50, flipperY), 
      Offset(size.width * 0.4, flipperY + (leftFlipperUp ? -size.width * 0.1 : size.width * 0.05)), 
      flipperPaint
    );
    
    // Right Flipper
    canvas.drawLine(
      Offset(size.width - 50, flipperY), 
      Offset(size.width * 0.6, flipperY + (rightFlipperUp ? -size.width * 0.1 : size.width * 0.05)), 
      flipperPaint
    );
    
    // Ball
    canvas.drawCircle(ballPos, 12, Paint()..color = Colors.white);
    canvas.drawCircle(ballPos, 12, Paint()..color = Colors.white38..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
