import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class TapTheColorGame extends StatefulWidget {
  const TapTheColorGame({super.key});
  @override
  State<TapTheColorGame> createState() => _TapColorState();
}

class _TapColorState extends State<TapTheColorGame> {
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
  final colorNames = ['RED', 'BLUE', 'GREEN', 'YELLOW', 'PURPLE', 'ORANGE'];
  final rng = Random();

  int score = 0, timeLeft = 30, targetIdx = 0;
  List<Color> options = [];
  Timer? timer;
  bool isPlaying = false;
  String feedback = '';

  void _start() {
    setState(() { score = 0; timeLeft = 30; isPlaying = true; feedback = ''; _nextRound(); });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 1) { t.cancel(); setState(() { isPlaying = false; StorageService.saveHighScore('tap_color', score); }); }
      else {
        setState(() => timeLeft--);
      }
    });
  }

  void _nextRound() {
    targetIdx = rng.nextInt(colors.length);
    final opts = List<Color>.from(colors)..shuffle();
    setState(() => options = opts.take(4).toList());
  }

  void _tap(Color c) {
    if (!isPlaying) return;
    setState(() {
      if (c == colors[targetIdx]) { score += 10; feedback = '✅ Correct!'; }
      else { score = max(0, score - 5); feedback = '❌ Wrong!'; }
      _nextRound();
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Tap The Color',
      onReset: () { timer?.cancel(); setState(() { isPlaying = false; score = 0; timeLeft = 30; feedback = ''; }); },
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text('Score: $score', style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('⏱ $timeLeft', style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 30),
          if (isPlaying) ...[
            Text('Tap the color:', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 10),
            Text(colorNames[targetIdx], style: GoogleFonts.outfit(fontSize: 52, fontWeight: FontWeight.w900, color: colors[targetIdx],
              shadows: [Shadow(color: colors[targetIdx].withValues(alpha: 0.5), blurRadius: 20)])),
            const SizedBox(height: 10),
            if (feedback.isNotEmpty) Text(feedback, style: GoogleFonts.outfit(fontSize: 20, color: feedback.contains('✅') ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: options.map((c) => GestureDetector(
              onTap: () => _tap(c),
              child: Container(width: 130, height: 70,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 10)]),
              ),
            )).toList()),
          ] else ...[
            Text(!isPlaying && score > 0 ? 'Game Over!\nScore: $score' : 'Tap the right color\nas fast as you can!',
              style: GoogleFonts.outfit(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _start,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
              child: Text('START!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
            ),
          ],
        ],
      ),
    );
  }
}
