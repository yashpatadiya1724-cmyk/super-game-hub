import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  final List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
  final List<String> colorNames = ["RED", "BLUE", "GREEN", "YELLOW", "PURPLE", "ORANGE"];
  
  late int targetColorIndex;
  late int nameTextIndex;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  bool isPlaying = false;
  final Random random = Random();

  void _startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isPlaying = true;
      _nextRound();
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _gameOver();
      }
    });
  }

  void _nextRound() {
    targetColorIndex = random.nextInt(colors.length);
    nameTextIndex = random.nextInt(colorNames.length);
  }

  void _checkAnswer(bool match) {
    if (!isPlaying) return;
    bool actualMatch = targetColorIndex == nameTextIndex;
    if (match == actualMatch) {
      setState(() {
        score += 10;
        _nextRound();
      });
    } else {
      setState(() {
        score = max(0, score - 5);
        _nextRound();
      });
    }
  }

  void _gameOver() {
    timer?.cancel();
    isPlaying = false;
    StorageService.saveHighScore('color_match', score);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Color Match',
      onReset: _startGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Score: $score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24)),
          Text("Time: $timeLeft", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 50),
          if (isPlaying) ...[
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                colorNames[nameTextIndex],
                style: GoogleFonts.outfit(
                  color: colors[targetColorIndex],
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: colors[targetColorIndex].withValues(alpha: 0.5), blurRadius: 20)],
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton("MATCH", Colors.greenAccent, () => _checkAnswer(true)),
                _actionButton("NO MATCH", Colors.redAccent, () => _checkAnswer(false)),
              ],
            ),
          ] else
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text("START CHALLENGE"),
            ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color),
        ),
        child: Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
