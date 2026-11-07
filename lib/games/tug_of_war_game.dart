import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class TugOfWarGame extends StatefulWidget {
  const TugOfWarGame({super.key});
  @override
  State<TugOfWarGame> createState() => _TugOfWarState();
}

class _TugOfWarState extends State<TugOfWarGame> {
  double ropePos = 0.0; // -1.0 = P2 wins, 1.0 = P1 wins
  int timeLeft = 15;
  Timer? timer;
  bool isPlaying = false;
  String message = 'Tap your button as fast as you can!';

  void _startGame() {
    setState(() { ropePos = 0.0; timeLeft = 15; isPlaying = true; message = 'GO!'; });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 1) {
        t.cancel();
        setState(() {
          isPlaying = false;
          if (ropePos > 0.2) {
            message = '🔴 Player 1 WINS!';
          } else if (ropePos < -0.2) {
            message = '🔵 Player 2 WINS!';
          } else {
            message = "It's a Draw! 🤝";
          }
        });
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _tap(int player) {
    if (!isPlaying) return;
    setState(() => ropePos += player == 1 ? 0.04 : -0.04);
    ropePos = ropePos.clamp(-1.0, 1.0);
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 40;
    final ropeX = width / 2 + ropePos * width / 2;
    return GameWrapper(
      title: 'Tug of War',
      onReset: () { timer?.cancel(); setState(() { ropePos = 0; isPlaying = false; message = 'Tap your button as fast as you can!'; }); },
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (isPlaying) Text('⏱ $timeLeft', style: GoogleFonts.outfit(fontSize: 36, color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // Rope visualization
          SizedBox(
            height: 60, width: width,
            child: Stack(children: [
              Positioned.fill(child: Container(
                margin: const EdgeInsets.symmetric(vertical: 25),
                color: Colors.white24,
              )),
              Positioned(left: 0, top: 0, bottom: 0, child: Container(width: ropeX, color: Colors.red.withValues(alpha: 0.5))),
              Positioned(left: ropeX - 20, top: 5, child: Container(width: 40, height: 50,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('🪢', style: TextStyle(fontSize: 24))),
              )),
            ]),
          ),
          const SizedBox(height: 40),
          Row(children: [
            Expanded(child: GestureDetector(
              onTapDown: (_) => _tap(1),
              child: Container(
                height: 120, margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent, width: 2)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('💪', style: TextStyle(fontSize: 50)),
                  Text('P1 TAP!', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ]),
              ),
            )),
            const SizedBox(width: 20),
            Expanded(child: GestureDetector(
              onTapDown: (_) => _tap(2),
              child: Container(
                height: 120, margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent, width: 2)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('💪', style: TextStyle(fontSize: 50)),
                  Text('P2 TAP!', style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ]),
              ),
            )),
          ]),
          const SizedBox(height: 30),
          if (!isPlaying)
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
              child: Text('START!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            ),
        ],
      ),
    );
  }
}
