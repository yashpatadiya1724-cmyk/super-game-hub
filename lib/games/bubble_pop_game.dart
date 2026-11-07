import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> {
  int score = 0;
  List<Bubble> bubbles = [];
  Timer? timer;
  bool isPlaying = false;
  final Random random = Random();

  void _startGame() {
    setState(() {
      score = 0;
      bubbles.clear();
      isPlaying = true;
    });
    timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          bubbles.add(Bubble(
            id: DateTime.now().millisecondsSinceEpoch,
            x: random.nextDouble(),
            y: 1.2,
            size: 40 + random.nextDouble() * 40,
            color: Colors.accents[random.nextInt(Colors.accents.length)],
            speed: 0.005 + random.nextDouble() * 0.01,
          ));
        });
      }
    });

    // Update loop
    Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!isPlaying) {
        t.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          for (var b in bubbles) {
            b.y -= b.speed;
          }
          bubbles.removeWhere((b) => b.y < -0.2);
        });
      }
    });
  }

  void _popBubble(Bubble bubble) {
    setState(() {
      bubbles.removeWhere((b) => b.id == bubble.id);
      score += 10;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Bubble Pop',
      onReset: _startGame,
      gameContent: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ...bubbles.map((b) => Positioned(
            left: b.x * (MediaQuery.of(context).size.width - 100) + 20,
            top: b.y * MediaQuery.of(context).size.height,
            child: GestureDetector(
              onTap: () => _popBubble(b),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: b.size,
                height: b.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: b.color.withValues(alpha: 0.5),
                  border: Border.all(color: b.color, width: 2),
                  boxShadow: [
                    BoxShadow(color: b.color.withValues(alpha: 0.3), blurRadius: 10),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: b.size * 0.3,
                    height: b.size * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          )),
          Positioned(
            top: 20,
            left: 20,
            child: Text("Score: $score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          if (!isPlaying)
            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                child: const Text("START POPPING"),
              ),
            ),
        ],
      ),
    );
  }
}

class Bubble {
  final int id;
  double x;
  double y;
  double size;
  Color color;
  double speed;

  Bubble({required this.id, required this.x, required this.y, required this.size, required this.color, required this.speed});
}
