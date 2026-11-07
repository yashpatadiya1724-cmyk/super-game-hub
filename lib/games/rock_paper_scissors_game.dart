import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class RockPaperScissorsGame extends StatefulWidget {
  const RockPaperScissorsGame({super.key});
  @override
  State<RockPaperScissorsGame> createState() => _RPSState();
}

class _RPSState extends State<RockPaperScissorsGame> {
  int p1Score = 0, p2Score = 0;
  String p1Choice = '', p2Choice = '';
  String result = '';
  bool showResult = false;

  final choices = ['✊', '✋', '✌️'];

  void _select(int player, String choice) {
    setState(() {
      if (player == 1) {
        p1Choice = choice;
      } else {
        p2Choice = choice;
      }
      if (p1Choice.isNotEmpty && p2Choice.isNotEmpty) _resolve();
    });
  }

  void _resolve() {
    final wins = {'✊': '✌️', '✋': '✊', '✌️': '✋'};
    if (p1Choice == p2Choice) {
      result = "It's a Draw! 🤝";
    } else if (wins[p1Choice] == p2Choice) {
      result = "Player 1 Wins! 🎉";
      p1Score++;
    } else {
      result = "Player 2 Wins! 🎉";
      p2Score++;
    }
    showResult = true;
  }

  void _nextRound() {
    setState(() { p1Choice = ''; p2Choice = ''; result = ''; showResult = false; });
  }

  Widget _choiceBtn(String emoji, int player) {
    bool chosen = (player == 1 ? p1Choice : p2Choice) == emoji;
    return GestureDetector(
      onTap: showResult ? null : () => _select(player, emoji),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75, height: 75,
        decoration: BoxDecoration(
          color: chosen ? Colors.white24 : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: chosen ? Colors.white : Colors.white24, width: chosen ? 2 : 1),
          boxShadow: chosen ? [const BoxShadow(color: Colors.white38, blurRadius: 10)] : [],
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 36))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Rock Paper Scissors',
      onReset: () => setState(() { p1Score = 0; p2Score = 0; _nextRound(); }),
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _scoreBox('P1', p1Score, Colors.redAccent),
            Text('VS', style: GoogleFonts.outfit(fontSize: 28, color: Colors.white54, fontWeight: FontWeight.bold)),
            _scoreBox('P2', p2Score, Colors.blueAccent),
          ]),
          const SizedBox(height: 40),
          if (!showResult) ...[
            _playerSection('PLAYER 1', 1, Colors.redAccent),
            const SizedBox(height: 30),
            _playerSection('PLAYER 2', 2, Colors.blueAccent),
          ] else ...[
            Text(p1Choice, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 10),
            Text(result, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
            const SizedBox(height: 10),
            Text(p2Choice, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _nextRound,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
              child: Text('NEXT ROUND', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int score, Color color) {
    return Column(children: [
      Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
      Text('$score', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
    ]);
  }

  Widget _playerSection(String label, int player, Color color) {
    bool hasChosen = (player == 1 ? p1Choice : p2Choice).isNotEmpty;
    return Column(children: [
      Text(label, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
      const SizedBox(height: 10),
      hasChosen
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text('✅ Chosen!', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
            )
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: choices.map((c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8), child: _choiceBtn(c, player))).toList()),
    ]);
  }
}
