import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class TruthOrDareGame extends StatefulWidget {
  const TruthOrDareGame({super.key});
  @override
  State<TruthOrDareGame> createState() => _TruthOrDareState();
}

class _TruthOrDareState extends State<TruthOrDareGame> {
  final rng = Random();
  String currentCard = '';
  bool isTruth = true;
  int player = 1;
  int numPlayers = 2;

  final truths = [
    "What is your most embarrassing memory?",
    "Have you ever lied to your best friend?",
    "Who is your secret crush?",
    "What is the worst thing you've ever done?",
    "Have you ever cheated on a test?",
    "What is your biggest fear?",
    "Have you ever stolen anything?",
    "What's your most used app on your phone?",
    "When was the last time you cried and why?",
    "What was your biggest mistake this year?",
    "What is something you pretend to know but don't?",
    "Have you ever ghosted someone?",
    "What is something you're really bad at?",
  ];

  final dares = [
    "Do 20 push-ups right now!",
    "Speak in an accent for the next 3 rounds.",
    "Let someone post anything to your social media.",
    "Do your best celebrity impression.",
    "Sing a song out loud for 30 seconds.",
    "Do the worm dance move.",
    "Text someone 'I love you' without explanation.",
    "Do a handstand against the wall.",
    "Eat a spoonful of hot sauce.",
    "Talk like a robot for the next 2 minutes.",
    "Do 15 jumping jacks.",
    "Act like an animal for 1 minute.",
    "Say the alphabet backwards.",
  ];

  void _draw(bool truth) {
    setState(() {
      isTruth = truth;
      currentCard = truth
          ? truths[rng.nextInt(truths.length)]
          : dares[rng.nextInt(dares.length)];
    });
  }

  void _next() {
    setState(() {
      player = (player % numPlayers) + 1;
      currentCard = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Truth or Dare',
      onReset: () => setState(() { currentCard = ''; player = 1; }),
      gameContent: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Player count selector
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Players: ', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
              ...List.generate(5, (i) {
                final n = i + 2;
                return GestureDetector(
                  onTap: () => setState(() { numPlayers = n; player = 1; currentCard = ''; }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: numPlayers == n ? Colors.pink : Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: numPlayers == n ? Colors.pinkAccent : Colors.white24),
                    ),
                    child: Center(child: Text('$n', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                );
              }),
            ]),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pinkAccent)),
              child: Text('🎮 PLAYER $player\'s TURN', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
            ),
            const SizedBox(height: 30),
            if (currentCard.isEmpty) ...[
              Text('Choose your fate!', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _choiceBtn('🤔 TRUTH', Colors.blueAccent, () => _draw(true)),
                _choiceBtn('😈 DARE', Colors.redAccent, () => _draw(false)),
              ]),
            ] else ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey(currentCard),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isTruth ? Colors.blue.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isTruth ? Colors.blueAccent : Colors.redAccent, width: 2),
                  ),
                  child: Column(children: [
                    Text(isTruth ? '🤔 TRUTH' : '😈 DARE',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isTruth ? Colors.blueAccent : Colors.redAccent)),
                    const SizedBox(height: 16),
                    Text(currentCard, style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, height: 1.5), textAlign: TextAlign.center),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton(
                  onPressed: () => _draw(isTruth),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
                  child: Text('New ${isTruth ? "Truth" : "Dare"}', style: GoogleFonts.outfit(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: Text('Next Player ➡', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _choiceBtn(String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)]),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    ),
  );
}
