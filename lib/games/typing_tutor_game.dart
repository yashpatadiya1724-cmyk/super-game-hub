import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class TypingTutorGame extends StatefulWidget {
  const TypingTutorGame({super.key});
  @override
  State<TypingTutorGame> createState() => _TypingState();
}

class _TypingState extends State<TypingTutorGame> {
  final words = ['flutter', 'android', 'mobile', 'screen', 'widget', 'button', 'scroll', 'navigation', 'keyboard', 'develop', 'gaming', 'super', 'velocity', 'cascade', 'triangle', 'phoenix'];
  final rng = Random();
  final _ctrl = TextEditingController();
  String currentWord = '';
  int score = 0, timeLeft = 30, streak = 0;
  Timer? timer;
  bool isPlaying = false;
  String feedback = '';
  Color feedbackColor = Colors.transparent;

  void _start() {
    setState(() { score = 0; timeLeft = 30; streak = 0; isPlaying = true; feedback = ''; _nextWord(); });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 1) {
        t.cancel();
        setState(() { isPlaying = false; StorageService.saveHighScore('typing_tutor', score); });
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _nextWord() {
    _ctrl.clear();
    setState(() => currentWord = words[rng.nextInt(words.length)]);
  }

  void _check(String val) {
    if (val.toLowerCase().trim() == currentWord) {
      setState(() {
        score += 10 + streak * 2;
        streak++;
        feedback = '✅ +${10 + (streak - 1) * 2}';
        feedbackColor = Colors.greenAccent;
      });
      _nextWord();
    }
  }

  @override
  void dispose() { timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Typing Tutor',
      onReset: () { timer?.cancel(); setState(() { isPlaying = false; score = 0; streak = 0; }); },
      gameContent: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _stat('Score', '$score', Colors.yellowAccent),
            _stat('Time', '⏱ $timeLeft', timeLeft <= 5 ? Colors.redAccent : Colors.white),
            _stat('Streak', '🔥 $streak', Colors.orangeAccent),
          ]),
          const SizedBox(height: 40),
          if (isPlaying) ...[
            Text('Type this word:', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.lightBlueAccent, width: 2),
                boxShadow: [BoxShadow(color: Colors.lightBlueAccent.withValues(alpha: 0.2), blurRadius: 16)],
              ),
              child: Text(currentWord, style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent, letterSpacing: 4)),
            ),
            const SizedBox(height: 20),
            if (feedback.isNotEmpty)
              Text(feedback, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: feedbackColor)),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Type here...', hintStyle: const TextStyle(color: Colors.white24),
                filled: true, fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: _check,
            ),
          ] else ...[
            Text(
              isPlaying == false && score > 0 ? 'Time\'s Up!\nFinal Score: $score\nBest Streak: $streak' : 'Type the words as\nfast as you can!',
              style: GoogleFonts.outfit(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _start,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
              child: Text('START TYPING!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _stat(String label, String val, Color color) => Column(children: [
    Text(label, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
    Text(val, style: GoogleFonts.outfit(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
  ]);
}
