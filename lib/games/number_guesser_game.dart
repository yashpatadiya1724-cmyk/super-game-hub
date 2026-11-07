import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class NumberGuesserGame extends StatefulWidget {
  const NumberGuesserGame({super.key});
  @override
  State<NumberGuesserGame> createState() => _NumberGuesserState();
}

class _NumberGuesserState extends State<NumberGuesserGame> {
  int secretNumber = 0;
  int guessCount = 0;
  String hint = '';
  bool won = false;
  bool phase1 = true; // P1 sets number, P2 guesses
  int p1Wins = 0, p2Wins = 0;
  final _ctrl = TextEditingController();

  void _setNumber() {
    final n = int.tryParse(_ctrl.text);
    if (n == null || n < 1 || n > 100) {
      setState(() => hint = 'Enter a number between 1 and 100!');
      return;
    }
    setState(() { secretNumber = n; phase1 = false; hint = 'P2: Guess the number (1-100)!'; _ctrl.clear(); });
  }

  void _guess() {
    final g = int.tryParse(_ctrl.text);
    if (g == null) return;
    _ctrl.clear();
    setState(() {
      guessCount++;
      if (g == secretNumber) {
        won = true;
        hint = '🎉 Correct in $guessCount guess${guessCount == 1 ? "" : "es"}!';
        if (guessCount <= 5) {
          p2Wins++;
        } else {
          p1Wins++;
        }
      } else if (g < secretNumber) {
        hint = '📈 Too LOW! Try higher.';
      } else {
        hint = '📉 Too HIGH! Try lower.';
      }
    });
  }

  void _reset() => setState(() { phase1 = true; won = false; guessCount = 0; hint = ''; secretNumber = 0; _ctrl.clear(); });

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Number Guesser',
      onReset: () { _reset(); setState(() { p1Wins = 0; p2Wins = 0; }); },
      gameContent: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _scoreBox('P1 (Setter)', p1Wins, Colors.redAccent),
              _scoreBox('P2 (Guesser)', p2Wins, Colors.greenAccent),
            ]),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
              child: Text(
                phase1 ? '🤫 PLAYER 1: Pick a secret number\n(1-100, Player 2 must not see!)' : (won ? '🏆 PLAYER 2 ${guessCount <= 5 ? "wins" : "took too long, P1 wins"}!' : 'PLAYER 2: Guess P1\'s number!\nGuesses: $guessCount'),
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            if (hint.isNotEmpty)
              Text(hint, style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (!won) ...[
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: phase1 ? 'Enter secret number...' : 'Your guess...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true, fillColor: Colors.white12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: phase1 ? _setNumber : _guess,
                style: ElevatedButton.styleFrom(backgroundColor: phase1 ? Colors.redAccent : Colors.greenAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                child: Text(phase1 ? 'SET NUMBER' : 'GUESS!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: Text('Switch Roles & Play Again', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreBox(String label, int score, Color color) => Column(children: [
    Text(label, style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
    Text('$score', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
  ]);
}
