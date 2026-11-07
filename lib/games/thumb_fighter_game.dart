import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/audio_feedback_service.dart';

class ThumbFighterGame extends StatefulWidget {
  const ThumbFighterGame({super.key});

  @override
  State<ThumbFighterGame> createState() => _ThumbFighterGameState();
}

class _ThumbFighterGameState extends State<ThumbFighterGame> with TickerProviderStateMixin {
  double health1 = 100.0;
  double health2 = 100.0;
  double stamina1 = 100.0;
  double stamina2 = 100.0;

  bool isP1Punching = false;
  bool isP2Punching = false;
  bool isClashing = false;
  String? winner;

  Timer? staminaTimer;

  @override
  void initState() {
    super.initState();
    staminaTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        if (stamina1 < 100) stamina1 = (stamina1 + 4).clamp(0, 100);
        if (stamina2 < 100) stamina2 = (stamina2 + 4).clamp(0, 100);
      });
    });
  }

  @override
  void dispose() {
    staminaTimer?.cancel();
    super.dispose();
  }

  void _p1Attack() {
    if (winner != null || stamina1 < 15) return;
    AudioFeedbackService.playClick();

    setState(() {
      isP1Punching = true;
      stamina1 = (stamina1 - 20).clamp(0, 100);

      if (isP2Punching) {
        // Clash!
        isClashing = true;
        AudioFeedbackService.vibrate(35);
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => isClashing = false);
        });
      } else {
        // Hit Player 2
        double damage = 6.0 + (stamina1 > 50 ? 4.0 : 0.0);
        health2 = (health2 - damage).clamp(0, 100);
        AudioFeedbackService.vibrate(20);
        if (health2 <= 0) {
          winner = "PLAYER 1 (RED) KNOCKS OUT!";
          AudioFeedbackService.vibrate(90);
        }
      }
    });

    Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => isP1Punching = false);
    });
  }

  void _p2Attack() {
    if (winner != null || stamina2 < 15) return;
    AudioFeedbackService.playClick();

    setState(() {
      isP2Punching = true;
      stamina2 = (stamina2 - 20).clamp(0, 100);

      if (isP1Punching) {
        // Clash!
        isClashing = true;
        AudioFeedbackService.vibrate(35);
        Timer(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => isClashing = false);
        });
      } else {
        // Hit Player 1
        double damage = 6.0 + (stamina2 > 50 ? 4.0 : 0.0);
        health1 = (health1 - damage).clamp(0, 100);
        AudioFeedbackService.vibrate(20);
        if (health1 <= 0) {
          winner = "PLAYER 2 (CYAN) KNOCKS OUT!";
          AudioFeedbackService.vibrate(90);
        }
      }
    });

    Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => isP2Punching = false);
    });
  }

  void _reset() {
    setState(() {
      health1 = 100.0;
      health2 = 100.0;
      stamina1 = 100.0;
      stamina2 = 100.0;
      winner = null;
      isP1Punching = false;
      isP2Punching = false;
      isClashing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Thumb Fighter Pro 🥊",
      onReset: _reset,
      gameContent: Column(
        children: [
          // Player 2 Area (Top, Inverted for opponent)
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _p2Attack(),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // HUD: Health & Stamina
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: _buildHUD("PLAYER 2 (CYAN)", health2, stamina2, Colors.cyanAccent),
                      ),

                      // Animated Thumb Fighter
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOutBack,
                          transform: Matrix4.translationValues(
                            0,
                            isP2Punching ? 50 : 0,
                            0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                                  border: Border.all(color: Colors.cyanAccent, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.front_hand,
                                  size: 80,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "TAP TO PUNCH",
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center Ring Divider with Clash Effect
          Container(
            height: 60,
            color: const Color(0xFF1E293B),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 80, height: 4, color: Colors.cyanAccent),
                    const SizedBox(width: 16),
                    Text(
                      "⚡ VS ⚡",
                      style: GoogleFonts.outfit(
                        color: Colors.amberAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 80, height: 4, color: Colors.redAccent),
                  ],
                ),
                if (isClashing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.white, blurRadius: 15, spreadRadius: 4),
                      ],
                    ),
                    child: Text(
                      "💥 CLASH! 💥",
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Player 1 Area (Bottom)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _p1Attack(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF991B1B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // HUD: Health & Stamina
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: _buildHUD("PLAYER 1 (RED)", health1, stamina1, Colors.redAccent),
                    ),

                    // Animated Thumb Fighter
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.translationValues(
                          0,
                          isP1Punching ? -50 : 0,
                          0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent.withValues(alpha: 0.2),
                                border: Border.all(color: Colors.redAccent, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.front_hand,
                                size: 80,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "TAP TO PUNCH",
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Winner Knockout Modal
          if (winner != null)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black.withValues(alpha: 0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🥊 KNOCKOUT! 🥊",
                    style: GoogleFonts.outfit(
                      color: Colors.amberAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    winner!,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "REMATCH",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD(String title, double health, double stamina, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.outfit(color: themeColor, fontWeight: FontWeight.bold, fontSize: 16)),
            Text("${health.toInt()} HP", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        // Health Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 14,
            color: Colors.white12,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: health / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeColor, Colors.white],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Stamina Bar
        Row(
          children: [
            const Icon(Icons.bolt, size: 12, color: Colors.amberAccent),
            const SizedBox(width: 4),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  color: Colors.white10,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: stamina / 100,
                    child: Container(color: Colors.amberAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
