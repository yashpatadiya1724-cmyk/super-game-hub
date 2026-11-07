import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/audio_feedback_service.dart';

class FingerBattleGame extends StatefulWidget {
  const FingerBattleGame({super.key});

  @override
  State<FingerBattleGame> createState() => _FingerBattleGameState();
}

class _FingerBattleGameState extends State<FingerBattleGame> with TickerProviderStateMixin {
  // Territory ratio: 0.5 is dead center. 0.0 = P2 full win, 1.0 = P1 full win.
  double territoryRatio = 0.5;
  int p1Combo = 0;
  int p2Combo = 0;
  DateTime lastP1Tap = DateTime.now();
  DateTime lastP2Tap = DateTime.now();

  String? winner;
  bool isPlaying = false;
  int countdown = 3;
  Timer? countdownTimer;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      territoryRatio = 0.5;
      winner = null;
      countdown = 3;
      isPlaying = false;
      p1Combo = 0;
      p2Combo = 0;
    });

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (countdown > 1) {
          countdown--;
          AudioFeedbackService.playClick();
        } else {
          timer.cancel();
          isPlaying = true;
          countdown = 0;
          AudioFeedbackService.vibrate(50);
        }
      });
    });
  }

  void _handleP1Tap() {
    if (!isPlaying || winner != null) return;
    final now = DateTime.now();
    if (now.difference(lastP1Tap).inMilliseconds < 250) {
      p1Combo = (p1Combo + 1).clamp(1, 10);
    } else {
      p1Combo = 1;
    }
    lastP1Tap = now;

    double pushPower = 0.02 + (p1Combo * 0.003);
    AudioFeedbackService.playClick();
    if (p1Combo >= 5) AudioFeedbackService.vibrate(15);

    setState(() {
      territoryRatio += pushPower;
      if (territoryRatio >= 0.96) {
        territoryRatio = 1.0;
        winner = "PLAYER 1 DOMINATES!";
        isPlaying = false;
        AudioFeedbackService.vibrate(80);
      }
    });
  }

  void _handleP2Tap() {
    if (!isPlaying || winner != null) return;
    final now = DateTime.now();
    if (now.difference(lastP2Tap).inMilliseconds < 250) {
      p2Combo = (p2Combo + 1).clamp(1, 10);
    } else {
      p2Combo = 1;
    }
    lastP2Tap = now;

    double pushPower = 0.02 + (p2Combo * 0.003);
    AudioFeedbackService.playClick();
    if (p2Combo >= 5) AudioFeedbackService.vibrate(15);

    setState(() {
      territoryRatio -= pushPower;
      if (territoryRatio <= 0.04) {
        territoryRatio = 0.0;
        winner = "PLAYER 2 DOMINATES!";
        isPlaying = false;
        AudioFeedbackService.vibrate(80);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Finger Battle ⚡",
      onReset: _startCountdown,
      gameContent: LayoutBuilder(
        builder: (context, constraints) {
          final totalH = constraints.maxHeight;
          final p1Height = (totalH * territoryRatio).clamp(0.0, totalH);
          final p2Height = totalH - p1Height;

          return Stack(
            children: [
              // Split Screen: Top Player 2 (Cyan/Blue) & Bottom Player 1 (Red/Orange)
              Column(
                children: [
                  // Player 2 Zone (Top - Inverted for opponent)
                  Expanded(
                    flex: ((1.0 - territoryRatio) * 1000).toInt().clamp(1, 1000),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => _handleP2Tap(),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF0284C7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "PLAYER 2",
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.cyanAccent,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "TAP TO PUSH!",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (p2Combo > 2)
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.cyanAccent.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.cyanAccent),
                                    ),
                                    child: Text(
                                      "⚡ ${p2Combo}x COMBO!",
                                      style: GoogleFonts.outfit(
                                        color: Colors.cyanAccent,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Player 1 Zone (Bottom)
                  Expanded(
                    flex: (territoryRatio * 1000).toInt().clamp(1, 1000),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => _handleP1Tap(),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFF450A0A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "PLAYER 1",
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.amberAccent,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "TAP TO PUSH!",
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (p1Combo > 2)
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.amberAccent),
                                  ),
                                  child: Text(
                                    "🔥 ${p1Combo}x COMBO!",
                                    style: GoogleFonts.outfit(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Glowing High-Voltage Dividing Beam
              Positioned(
                top: p2Height - 14,
                left: 0,
                right: 0,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.9),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.amberAccent.withValues(alpha: 0.7),
                        blurRadius: 28,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Countdown Overlay
              if (!isPlaying && winner == null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.65),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (countdown > 0) ...[
                            Text(
                              "$countdown",
                              style: GoogleFonts.outfit(
                                fontSize: 90,
                                fontWeight: FontWeight.w900,
                                color: Colors.amberAccent,
                                shadows: [
                                  const Shadow(color: Colors.amber, blurRadius: 30),
                                ],
                              ),
                            ),
                            Text(
                              "GET READY TO TAP!",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 2,
                              ),
                            ),
                          ] else ...[
                            ElevatedButton(
                              onPressed: _startCountdown,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: Text(
                                "START BATTLE",
                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              // Victory Screen
              if (winner != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on, size: 80, color: Colors.amberAccent),
                          const SizedBox(height: 16),
                          Text(
                            winner!,
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                const Shadow(color: Colors.redAccent, blurRadius: 20),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _startCountdown,
                            icon: const Icon(Icons.replay),
                            label: const Text("REMATCH"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
