import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_feedback_service.dart';
import '../theme/app_theme.dart';

class PackagesShowcaseScreen extends StatefulWidget {
  const PackagesShowcaseScreen({super.key});

  @override
  State<PackagesShowcaseScreen> createState() => _PackagesShowcaseScreenState();
}

class _PackagesShowcaseScreenState extends State<PackagesShowcaseScreen> with SingleTickerProviderStateMixin {
  // Demo State for flutter_game_juice
  double trauma = 0.0;
  final List<_DemoParticle> demoParticles = [];
  final List<_DemoPopupText> demoPopups = [];
  final Random _rnd = Random();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);
    _animController.repeat();
  }

  void _tick() {
    setState(() {
      // Trauma decay
      if (trauma > 0) {
        trauma = max(0.0, trauma - 0.02);
      }
      // Particles update
      demoParticles.removeWhere((p) => !p.update());
      // Popups update
      demoPopups.removeWhere((pop) => !pop.update());
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    AudioFeedbackService.vibrate(50);
    setState(() {
      trauma = 1.0;
    });
  }

  void _triggerParticles(Offset pos) {
    AudioFeedbackService.playClick();
    for (int i = 0; i < 25; i++) {
      double angle = _rnd.nextDouble() * 2 * pi;
      double speed = 2.0 + _rnd.nextDouble() * 6.0;
      demoParticles.add(_DemoParticle(
        x: pos.dx,
        y: pos.dy,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 4.0 + _rnd.nextDouble() * 6.0,
        color: [Colors.cyanAccent, Colors.pinkAccent, Colors.amberAccent, Colors.purpleAccent][_rnd.nextInt(4)],
      ));
    }
  }

  void _triggerDamagePopup(Offset pos) {
    AudioFeedbackService.playScore();
    int damage = 50 + _rnd.nextInt(150);
    demoPopups.add(_DemoPopupText(
      text: "+$damage CRIT! 💥",
      x: pos.dx,
      y: pos.dy,
      color: Colors.amberAccent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Shake translation calculation
    final shakeAmount = trauma * trauma;
    final shakeX = (_rnd.nextDouble() * 2 - 1) * 14.0 * shakeAmount;
    final shakeY = (_rnd.nextDouble() * 2 - 1) * 14.0 * shakeAmount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Custom Engine Packages",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Transform.translate(
        offset: Offset(shakeX, shakeY),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4338CA), Color(0xFF6D28D9), Color(0xFF9333EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.purple.withValues(alpha: 0.5), blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2, color: Colors.amberAccent, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              "PRODUCTION REUSABLE PACKAGES",
                              style: GoogleFonts.outfit(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Super Game Engine Kit",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Standalone, publishable Dart/Flutter packages built inside this repository for real game development.",
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Package 1: flutter_game_juice
                  _buildPackageCard(
                    title: "📦 flutter_game_juice",
                    version: "v1.0.0",
                    description: "Zero-dependency game feel & juice toolkit. Trauma screen shake, 60fps particle bursts, and floating damage numbers.",
                    path: "packages/flutter_game_juice",
                    accentColor: Colors.pinkAccent,
                    demoAction: (pos) => _triggerShake(),
                    demoLabel: "TEST TRAUMA SHAKE",
                    onSecondaryTap: (pos) => _triggerParticles(pos),
                    secondaryLabel: "SPAWN PARTICLES",
                    onTertiaryTap: (pos) => _triggerDamagePopup(pos),
                    tertiaryLabel: "DAMAGE NUMBERS",
                  ),

                  const SizedBox(height: 24),

                  // Package 2: fsm_game_ai
                  _buildPackageCard(
                    title: "🤖 fsm_game_ai",
                    version: "v1.0.0",
                    description: "Type-safe Finite State Machine (FSM) & A* 2D Grid Pathfinding algorithm for tactical enemies, patrols, and chase behaviors.",
                    path: "packages/fsm_game_ai",
                    accentColor: Colors.cyanAccent,
                    demoAction: (_) {
                      Navigator.pushNamed(context, '/smart_ai');
                    },
                    demoLabel: "LAUNCH A* AI DEMO",
                  ),

                  const SizedBox(height: 24),

                  // Pubspec Integration Guide
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "HOW TO USE IN ANY FLUTTER PROJECT",
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            "dependencies:\n  flutter_game_juice:\n    path: packages/flutter_game_juice\n  fsm_game_ai:\n    path: packages/fsm_game_ai",
                            style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Canvas for interactive particle bursts
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _DemoParticlePainter(demoParticles),
            ),

            // Floating Popups
            ...demoPopups.map((p) => Positioned(
                  left: p.x - 50,
                  top: p.y,
                  child: Text(
                    p.text,
                    style: GoogleFonts.outfit(
                      color: p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0)),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      shadows: [const Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String version,
    required String description,
    required String path,
    required Color accentColor,
    required void Function(Offset pos) demoAction,
    required String demoLabel,
    void Function(Offset pos)? onSecondaryTap,
    String? secondaryLabel,
    void Function(Offset pos)? onTertiaryTap,
    String? tertiaryLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: accentColor.withValues(alpha: 0.15), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor),
                ),
                child: Text(
                  version,
                  style: GoogleFonts.outfit(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            "📁 $path",
            style: GoogleFonts.firaCode(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => demoAction(const Offset(200, 300)),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(demoLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              if (onSecondaryTap != null && secondaryLabel != null)
                OutlinedButton.icon(
                  onPressed: () => onSecondaryTap(const Offset(200, 350)),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(secondaryLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: accentColor),
                    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              if (onTertiaryTap != null && tertiaryLabel != null)
                OutlinedButton.icon(
                  onPressed: () => onTertiaryTap(const Offset(200, 380)),
                  icon: const Icon(Icons.numbers, size: 18),
                  label: Text(tertiaryLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: accentColor),
                    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoParticle {
  double x, y, vx, vy, size;
  double alpha = 1.0;
  final Color color;
  _DemoParticle({required this.x, required this.y, required this.vx, required this.vy, required this.size, required this.color});

  bool update() {
    x += vx;
    y += vy;
    vy += 0.15;
    alpha -= 0.03;
    size = max(0, size - 0.1);
    return alpha > 0 && size > 0;
  }
}

class _DemoParticlePainter extends CustomPainter {
  final List<_DemoParticle> particles;
  _DemoParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _DemoPopupText {
  final String text;
  double x, y;
  double alpha = 1.0;
  final Color color;
  _DemoPopupText({required this.text, required this.x, required this.y, required this.color});

  bool update() {
    y -= 1.5;
    alpha -= 0.025;
    return alpha > 0;
  }
}
