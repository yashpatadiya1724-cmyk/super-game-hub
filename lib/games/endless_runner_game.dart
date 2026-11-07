import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class EndlessRunnerGame extends StatefulWidget {
  const EndlessRunnerGame({super.key});
  @override
  State<EndlessRunnerGame> createState() => _RunnerState();
}

class _RunnerState extends State<EndlessRunnerGame> {
  static const double groundY = 0.75;
  double playerY = groundY;
  double velY = 0;
  double obstacleX = 1.0;
  double obstacleH = 0.15;
  int score = 0;
  int hiScore = 0;
  bool isPlaying = false;
  bool isDead = false;
  Timer? timer;
  final rng = Random();
  double speed = 0.012;

  @override
  void initState() { super.initState(); hiScore = StorageService.getHighScore('endless_runner'); }

  void _start() {
    setState(() { playerY = groundY; velY = 0; obstacleX = 1.5; score = 0; isPlaying = true; isDead = false; speed = 0.012; });
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _jump() {
    if (!isPlaying) return;
    if ((playerY - groundY).abs() < 0.01) setState(() => velY = -0.025);
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      // Gravity
      velY += 0.002;
      playerY += velY;
      if (playerY >= groundY) { playerY = groundY; velY = 0; }

      // Obstacle
      obstacleX -= speed;
      if (obstacleX < -0.15) {
        obstacleX = 1.0 + rng.nextDouble() * 0.5;
        obstacleH = 0.1 + rng.nextDouble() * 0.15;
        score++;
        speed = 0.012 + score * 0.0002;
      }

      // Collision
      if (obstacleX < 0.18 && obstacleX > 0.05 && playerY > groundY - obstacleH - 0.05) {
        timer?.cancel();
        isPlaying = false;
        isDead = true;
        if (score > hiScore) { hiScore = score; StorageService.saveHighScore('endless_runner', hiScore); }
      }
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 32;
    final h = 250.0;
    return GameWrapper(
      title: 'Endless Runner',
      onReset: () { timer?.cancel(); setState(() { isPlaying = false; isDead = false; score = 0; playerY = groundY; }); },
      gameContent: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Score: $score', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Best: $hiScore', style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _jump,
          child: Container(
            width: w, height: h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1117), Color(0xFF1A2940)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3), width: 2),
            ),
            child: Stack(children: [
              // Ground line
              Positioned(top: h * groundY + 20, left: 0, right: 0, child: Container(height: 2, color: Colors.greenAccent.withValues(alpha: 0.5))),
              // Player (runner character)
              Positioned(
                left: w * 0.1 - 15,
                top: h * playerY - 30,
                child: Text(isDead ? '💀' : '🏃', style: const TextStyle(fontSize: 30)),
              ),
              // Obstacle  
              Positioned(
                left: w * obstacleX - 15,
                top: h * (groundY - obstacleH + 0.02),
                child: Container(
                  width: 25, height: h * obstacleH,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                ),
              ),
              if (!isPlaying)
                Center(child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                  child: Text(isDead ? 'Game Over! Score: $score\nTap to play again' : 'Tap to jump!\nAvoid the obstacles', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                )),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        if (!isPlaying)
          ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
            child: Text(isDead ? 'PLAY AGAIN!' : 'START RUNNING!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
          )
        else
          Text('TAP ANYWHERE TO JUMP!', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }
}
