import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});
  @override
  State<HangmanGame> createState() => _HangmanState();
}

class _HangmanState extends State<HangmanGame> {
  final List<String> wordBank = ['FLUTTER', 'ANDROID', 'PROGRAMMING', 'KEYBOARD', 'GALAXY', 'QUANTUM', 'JAVASCRIPT', 'MOUNTAIN', 'ELEPHANT', 'DIAMOND'];
  String word = '';
  Set<String> guessed = {};
  int wrong = 0;
  bool phase1 = true;
  final _ctrl = TextEditingController();
  bool customWord = false;

  void _startWithWord(String w) {
    setState(() { word = w.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), ''); phase1 = false; guessed = {}; wrong = 0; _ctrl.clear(); });
  }

  void _guess(String letter) {
    if (guessed.contains(letter) || isOver) return;
    setState(() {
      guessed.add(letter);
      if (!word.contains(letter)) wrong++;
    });
  }

  bool get isWon => word.isNotEmpty && word.split('').every((l) => guessed.contains(l));
  bool get isLost => wrong >= 6;
  bool get isOver => isWon || isLost;

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Hangman',
      onReset: () => setState(() { phase1 = true; word = ''; guessed = {}; wrong = 0; customWord = false; _ctrl.clear(); }),
      gameContent: phase1 ? _buildSetup() : _buildGame(),
    );
  }

  Widget _buildSetup() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('🎭 PLAYER 1', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 10),
      Text('Choose a word for Player 2 to guess!', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
      const SizedBox(height: 30),
      TextField(
        controller: _ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Type your secret word...', hintStyle: const TextStyle(color: Colors.white38),
          filled: true, fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onSubmitted: (v) { if (v.isNotEmpty) _startWithWord(v); },
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () { if (_ctrl.text.isNotEmpty) _startWithWord(_ctrl.text); },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
        child: Text('SET WORD', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      const SizedBox(height: 20),
      Text('— OR —', style: GoogleFonts.outfit(color: Colors.white38)),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () => _startWithWord(wordBank[DateTime.now().millisecond % wordBank.length]),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
        child: Text('Use Random Word', style: GoogleFonts.outfit(color: Colors.white)),
      ),
    ]),
  );

  Widget _buildGame() {
    final display = word.split('').map((l) => guessed.contains(l) ? l : '_').join(' ');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Hangman drawing
          CustomPaint(size: const Size(180, 180), painter: _HangmanPainter(wrong)),
          const SizedBox(height: 16),
          Text(display, style: GoogleFonts.outfit(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 8)),
          const SizedBox(height: 10),
          Text('Wrong: $wrong/6', style: GoogleFonts.outfit(color: wrong >= 4 ? Colors.redAccent : Colors.white70, fontSize: 16)),
          const SizedBox(height: 16),
          if (isOver) ...[
            Text(isWon ? '🎉 Player 2 Wins!' : '💀 Player 1 Wins!\nWord was: $word',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isWon ? Colors.greenAccent : Colors.redAccent), textAlign: TextAlign.center),
          ] else
            _buildKeyboard(),
        ]),
      ),
    );
  }

  Widget _buildKeyboard() {
    final rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    return Column(children: rows.map((row) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: row.split('').map((l) {
        final isGuessed = guessed.contains(l);
        final isCorrect = isGuessed && word.contains(l);
        final isWrong = isGuessed && !word.contains(l);
        return GestureDetector(
          onTap: () => _guess(l),
          child: Container(
            margin: const EdgeInsets.all(3), width: 32, height: 36,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.withValues(alpha: 0.4) : isWrong ? Colors.red.withValues(alpha: 0.2) : Colors.white12,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isCorrect ? Colors.greenAccent : isWrong ? Colors.redAccent : Colors.white24),
            ),
            child: Center(child: Text(l, style: TextStyle(color: isGuessed ? (isCorrect ? Colors.greenAccent : Colors.red) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          ),
        );
      }).toList()),
    )).toList());
  }
}

class _HangmanPainter extends CustomPainter {
  final int wrong;
  _HangmanPainter(this.wrong);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    // Base
    canvas.drawLine(Offset(20, size.height - 10), Offset(size.width - 20, size.height - 10), p);
    if (wrong > 0) canvas.drawLine(Offset(size.width / 2, size.height - 10), Offset(size.width / 2, 10), p);
    if (wrong > 1) canvas.drawLine(Offset(size.width / 2, 10), Offset(size.width * 0.75, 10), p);
    if (wrong > 2) canvas.drawLine(Offset(size.width * 0.75, 10), Offset(size.width * 0.75, 40), p);
    // Head
    if (wrong > 3) canvas.drawCircle(Offset(size.width * 0.75, 55), 15, p);
    // Body
    if (wrong > 4) canvas.drawLine(Offset(size.width * 0.75, 70), Offset(size.width * 0.75, 120), p);
    if (wrong > 5) {
      canvas.drawLine(Offset(size.width * 0.75, 85), Offset(size.width * 0.6, 105), p);
      canvas.drawLine(Offset(size.width * 0.75, 85), Offset(size.width * 0.9, 105), p);
      canvas.drawLine(Offset(size.width * 0.75, 120), Offset(size.width * 0.6, 145), p);
      canvas.drawLine(Offset(size.width * 0.75, 120), Offset(size.width * 0.9, 145), p);
    }
  }
  @override
  bool shouldRepaint(covariant _HangmanPainter o) => o.wrong != wrong;
}
