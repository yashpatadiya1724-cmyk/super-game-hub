import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class DiceRollerGame extends StatefulWidget {
  const DiceRollerGame({super.key});
  @override
  State<DiceRollerGame> createState() => _DiceState();
}

class _DiceState extends State<DiceRollerGame> {
  int p1Dice = 1, p2Dice = 1;
  int p1Wins = 0, p2Wins = 0, draws = 0;
  bool rolled = false;
  final rng = Random();
  final faces = ['⚀','⚁','⚂','⚃','⚄','⚅'];

  void _rollBoth() {
    setState(() {
      p1Dice = rng.nextInt(6) + 1;
      p2Dice = rng.nextInt(6) + 1;
      rolled = true;
      if (p1Dice > p2Dice) p1Wins++;
      else if (p2Dice > p1Dice) p2Wins++;
      else draws++;
    });
  }

  String get result {
    if (!rolled) return '';
    if (p1Dice > p2Dice) return '🔴 Player 1 Wins this round!';
    if (p2Dice > p1Dice) return '🔵 Player 2 Wins this round!';
    return '🤝 It\'s a Draw!';
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Dice Roller',
      onReset: () => setState(() { p1Dice = 1; p2Dice = 1; p1Wins = 0; p2Wins = 0; draws = 0; rolled = false; }),
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _scoreBox('PLAYER 1', p1Wins, Colors.redAccent),
            Column(children: [
              Text('Draws', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
              Text('$draws', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 28, fontWeight: FontWeight.bold)),
            ]),
            _scoreBox('PLAYER 2', p2Wins, Colors.blueAccent),
          ]),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _diceWidget(p1Dice, Colors.redAccent),
            Text('VS', style: GoogleFonts.outfit(fontSize: 24, color: Colors.white54, fontWeight: FontWeight.bold)),
            _diceWidget(p2Dice, Colors.blueAccent),
          ]),
          const SizedBox(height: 30),
          if (rolled)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(result, key: ValueKey(result), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellowAccent), textAlign: TextAlign.center),
            ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _rollBoth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.redAccent, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)],
              ),
              child: Text('🎲 ROLL BOTH!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _diceWidget(int val, Color color) => Container(
    width: 100, height: 100,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2),
      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)]),
    child: Center(child: Text(faces[val - 1], style: const TextStyle(fontSize: 60))),
  );

  Widget _scoreBox(String label, int score, Color color) => Column(children: [
    Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    Text('$score', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
    Text('wins', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
  ]);
}
