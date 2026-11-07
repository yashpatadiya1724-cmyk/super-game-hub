import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class WhackAMoleGame extends StatefulWidget {
  const WhackAMoleGame({super.key});

  @override
  State<WhackAMoleGame> createState() => _WhackAMoleGameState();
}

class _WhackAMoleGameState extends State<WhackAMoleGame> {
  int score = 0;
  int moleIndex = -1;
  Timer? timer;
  int timeLeft = 30;
  bool isPlaying = false;
  final Random random = Random();

  void _startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isPlaying = true;
      moleIndex = random.nextInt(9);
    });

    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
          moleIndex = random.nextInt(9);
        });
      } else {
        _gameOver();
      }
    });
  }

  void _hitMole(int index) {
    if (index == moleIndex && isPlaying) {
      setState(() {
        score += 10;
        moleIndex = -1; // Hide immediately
      });
    }
  }

  void _gameOver() {
    timer?.cancel();
    isPlaying = false;
    StorageService.saveHighScore('whack_a_mole', score);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Whack-A-Mole',
      onReset: _startGame,
      gameContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Score: $score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24)),
              Text("Time: $timeLeft", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                bool isMole = index == moleIndex;
                return GestureDetector(
                  onTap: () => _hitMole(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: isMole ? Colors.yellowAccent : Colors.white12, width: 2),
                      boxShadow: isMole ? [BoxShadow(color: Colors.yellowAccent.withValues(alpha: 0.3), blurRadius: 15)] : [],
                    ),
                    child: Center(
                      child: isMole 
                        ? const Icon(Icons.adb, color: Colors.yellowAccent, size: 50)
                        : const SizedBox(),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!isPlaying)
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellowAccent),
              child: Text("START WHACKING", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
