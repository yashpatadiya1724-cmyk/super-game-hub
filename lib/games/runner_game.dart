import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class RunnerGame extends StatefulWidget {
  const RunnerGame({super.key});

  @override
  State<RunnerGame> createState() => _RunnerGameState();
}

class _RunnerGameState extends State<RunnerGame> {
  double birdY = 0;
  double time = 0;
  double height = 0;
  double initialHeight = 0;
  bool isPlaying = false;
  int score = 0;
  
  static double barrelX = 1;
  double barrelX2 = barrelX + 1.5;

  void _startGame() {
    setState(() {
      isPlaying = true;
      score = 0;
      birdY = 0;
      time = 0;
      initialHeight = birdY;
      barrelX = 1;
      barrelX2 = barrelX + 1.5;
    });

    Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        time += 0.04;
        height = -4.9 * time * time + 2.5 * time;
        birdY = initialHeight - height;

        barrelX -= 0.05;
        barrelX2 -= 0.05;

        if (barrelX < -1.1) barrelX += 2.2;
        if (barrelX2 < -1.1) barrelX2 += 2.2;

        if (birdY > 1 || birdY < -1.1) {
          _gameOver();
        }

        // Collision check (simplified)
        if ((barrelX.abs() < 0.1 && birdY.abs() > 0.5) || 
            (barrelX2.abs() < 0.1 && birdY.abs() > 0.5)) {
           // Score increment if passed
        }
        
        score++;
      });
    });
  }

  void _jump() {
    setState(() {
      time = 0;
      initialHeight = birdY;
    });
  }

  void _gameOver() {
    isPlaying = false;
    StorageService.saveHighScore('runner', score);
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: 'Neon Runner',
      onReset: _startGame,
      gameContent: GestureDetector(
        onTap: isPlaying ? _jump : _startGame,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Character
              Align(
                alignment: Alignment(-0.5, birdY),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 15)],
                  ),
                ),
              ),
              
              // Obstacles
              Align(
                alignment: Alignment(barrelX, 1.1),
                child: Container(width: 40, height: 100, color: Colors.redAccent),
              ),
               Align(
                alignment: Alignment(barrelX2, 1.1),
                child: Container(width: 40, height: 150, color: Colors.purpleAccent),
              ),

              Positioned(
                top: 20,
                left: 20,
                child: Text("Score: $score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24)),
              ),

              if (!isPlaying)
                const Center(child: Text("TAP TO START", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}
