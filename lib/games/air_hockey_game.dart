import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class AirHockeyGame extends StatefulWidget {
  const AirHockeyGame({super.key});

  @override
  State<AirHockeyGame> createState() => _AirHockeyGameState();
}

class _AirHockeyGameState extends State<AirHockeyGame> {
  static const double malletRadius = 30.0;
  static const double puckRadius = 20.0;
  
  Offset player1Pos = const Offset(0, 0);
  Offset player2Pos = const Offset(0, 0);
  Offset puckPos = const Offset(0, 0);
  Offset puckVelocity = const Offset(0, 0);
  
  int score1 = 0;
  int score2 = 0;
  Timer? gameTimer;
  Size? tableSize;

  void _resetPuck() {
    if (tableSize == null) return;
    puckPos = Offset(tableSize!.width / 2, tableSize!.height / 2);
    puckVelocity = Offset(Random().nextBool() ? 2.0 : -2.0, Random().nextBool() ? 2.0 : -2.0);
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
    if (tableSize == null) return;

    setState(() {
      // Move puck
      puckPos += puckVelocity;

      // Wall collisions
      if (puckPos.dx <= puckRadius || puckPos.dx >= tableSize!.width - puckRadius) {
        puckVelocity = Offset(-puckVelocity.dx, puckVelocity.dy);
        puckPos = Offset(puckPos.dx.clamp(puckRadius, tableSize!.width - puckRadius), puckPos.dy);
      }

      // Goal detection
      if (puckPos.dy <= puckRadius) {
        if (puckPos.dx > tableSize!.width * 0.3 && puckPos.dx < tableSize!.width * 0.7) {
          score2++;
          _resetPuck();
        } else {
          puckVelocity = Offset(puckVelocity.dx, -puckVelocity.dy);
          puckPos = Offset(puckPos.dx, puckRadius);
        }
      } else if (puckPos.dy >= tableSize!.height - puckRadius) {
        if (puckPos.dx > tableSize!.width * 0.3 && puckPos.dx < tableSize!.width * 0.7) {
          score1++;
          _resetPuck();
        } else {
          puckVelocity = Offset(puckVelocity.dx, -puckVelocity.dy);
          puckPos = Offset(puckPos.dx, tableSize!.height - puckRadius);
        }
      }

      // Mallet collisions (Player 1)
      double dist1 = (puckPos - player1Pos).distance;
      if (dist1 < malletRadius + puckRadius) {
        Offset normal = (puckPos - player1Pos) / dist1;
        puckVelocity = normal * 10.0; // Basic bounce reflecting hit direction
        puckPos = player1Pos + normal * (malletRadius + puckRadius + 1);
      }

      // Mallet collisions (Player 2)
      double dist2 = (puckPos - player2Pos).distance;
      if (dist2 < malletRadius + puckRadius) {
        Offset normal = (puckPos - player2Pos) / dist2;
        puckVelocity = normal * 10.0;
        puckPos = player2Pos + normal * (malletRadius + puckRadius + 1);
      }

      // Friction
      puckVelocity *= 0.99;
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
      title: "Air Hockey",
      onReset: () {
        setState(() {
          score1 = 0;
          score2 = 0;
          _resetPuck();
        });
      },
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          if (tableSize == null) {
            tableSize = Size(constraints.maxWidth, constraints.maxHeight);
            player1Pos = Offset(tableSize!.width / 2, tableSize!.height * 0.8);
            player2Pos = Offset(tableSize!.width / 2, tableSize!.height * 0.2);
            _resetPuck();
            _startGame();
          }
          
          return Stack(
            children: [
              // Table lines
              CustomPaint(
                size: tableSize!,
                painter: _TablePainter(),
              ),
              // Scores
              Positioned(
                right: 20,
                top: tableSize!.height / 2 - 30,
                child: Column(
                  children: [
                    Text("P2: $score2", style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("P1: $score1", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // Touch Layer Player 1 (Bottom)
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    double dy = details.localPosition.dy.clamp(tableSize!.height / 2 + malletRadius, tableSize!.height - malletRadius);
                    double dx = details.localPosition.dx.clamp(malletRadius, tableSize!.width - malletRadius);
                    player1Pos = Offset(dx, dy);
                  });
                },
                child: Container(color: Colors.transparent),
              ),
              // Touch Layer Player 2 (Top)
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    double dy = details.localPosition.dy.clamp(malletRadius, tableSize!.height / 2 - malletRadius);
                    double dx = details.localPosition.dx.clamp(malletRadius, tableSize!.width - malletRadius);
                    player2Pos = Offset(dx, dy);
                  });
                },
                child: Container(color: Colors.transparent),
              ),
              // Puck
              Positioned(
                left: puckPos.dx - puckRadius,
                top: puckPos.dy - puckRadius,
                child: Container(
                  width: puckRadius * 2,
                  height: puckRadius * 2,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white54, blurRadius: 10)],
                  ),
                ),
              ),
              // Mallet 1
              Positioned(
                left: player1Pos.dx - malletRadius,
                top: player1Pos.dy - malletRadius,
                child: Container(
                  width: malletRadius * 2,
                  height: malletRadius * 2,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
              // Mallet 2
              Positioned(
                left: player2Pos.dx - malletRadius,
                top: player2Pos.dy - malletRadius,
                child: Container(
                  width: malletRadius * 2,
                  height: malletRadius * 2,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Center line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, paint);
    
    // Goals
    final goalPaint = Paint()..color = Colors.white10..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, 10), goalPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height - 10, size.width * 0.4, 10), goalPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
