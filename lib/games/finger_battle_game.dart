import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class FingerBattleGame extends StatefulWidget {
  const FingerBattleGame({super.key});
  @override
  State<FingerBattleGame> createState() => _FingerBattleState();
}

class _FingerBattleState extends State<FingerBattleGame> {
  int p1Taps = 0, p2Taps = 0;
  int timeLeft = 10;
  Timer? timer;
  bool isPlaying = false;
  bool isOver = false;

  void _start() {
    setState(() { p1Taps = 0; p2Taps = 0; timeLeft = 10; isPlaying = true; isOver = false; });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 1) {
        t.cancel();
        setState(() { isPlaying = false; isOver = true; });
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  String get result {
    if (p1Taps > p2Taps) return '🔴 Player 1 WINS!\n${p1Taps} vs ${p2Taps} taps';
    if (p2Taps > p1Taps) return '🔵 Player 2 WINS!\n${p2Taps} vs ${p1Taps} taps';
    return '🤝 DRAW!\nBoth tapped ${p1Taps} times';
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Finger Battle',
      onReset: () { timer?.cancel(); setState(() { isPlaying = false; isOver = false; p1Taps = 0; p2Taps = 0; timeLeft = 10; }); },
      gameContent: Column(
        children: [
          const SizedBox(height: 20),
          if (isPlaying)
            Text('⏱ $timeLeft', style: GoogleFonts.outfit(fontSize: 52, fontWeight: FontWeight.bold, color: timeLeft <= 3 ? Colors.redAccent : Colors.yellowAccent))
          else if (isOver)
            Text(result, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)
          else
            Text('Both players tap their button as fast as possible!', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (!isOver) ...[
            Expanded(
              child: Row(children: [
                // P1 Button (Left half)
                Expanded(child: GestureDetector(
                  onTapDown: isPlaying ? (_) => setState(() => p1Taps++) : null,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: isPlaying ? 0.4 : 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent, width: 3),
                      boxShadow: isPlaying ? [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.4), blurRadius: 20)] : [],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('🔴', style: const TextStyle(fontSize: 60)),
                      const SizedBox(height: 10),
                      Text('PLAYER 1', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('$p1Taps', style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      Text('taps', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                    ]),
                  ),
                )),
                // P2 Button (Right half)
                Expanded(child: GestureDetector(
                  onTapDown: isPlaying ? (_) => setState(() => p2Taps++) : null,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: isPlaying ? 0.4 : 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent, width: 3),
                      boxShadow: isPlaying ? [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.4), blurRadius: 20)] : [],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('🔵', style: const TextStyle(fontSize: 60)),
                      const SizedBox(height: 10),
                      Text('PLAYER 2', style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('$p2Taps', style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                      Text('taps', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14)),
                    ]),
                  ),
                )),
              ]),
            ),
          ],
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16)),
                child: Text(isOver ? 'PLAY AGAIN!' : 'START BATTLE!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
              ),
            ),
        ],
      ),
    );
  }
}
