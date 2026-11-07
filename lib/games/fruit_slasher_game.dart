import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

class _Fruit {
  double x, y, vy, vx;
  String emoji;
  bool sliced;
  _Fruit(this.x, this.y, this.vy, this.vx, this.emoji) : sliced = false;
}

class FruitSlasherGame extends StatefulWidget {
  const FruitSlasherGame({super.key});
  @override
  State<FruitSlasherGame> createState() => _FruitSlasherState();
}

class _FruitSlasherState extends State<FruitSlasherGame> {
  final fruits = ['🍎', '🍊', '🍋', '🍇', '🍉', '🍓', '🥝'];
  List<_Fruit> activeFruits = [];
  List<Offset> slashTrail = [];
  int score = 0, lives = 3, hiScore = 0;
  bool isPlaying = false;
  Timer? spawnTimer, gameTimer;
  int timeLeft = 60;
  final rng = Random();

  @override
  void initState() { super.initState(); hiScore = StorageService.getHighScore('fruit_slasher'); }

  void _start() {
    setState(() { activeFruits = []; score = 0; lives = 3; timeLeft = 60; isPlaying = true; });
    spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) => _spawnFruit());
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !isPlaying) { t.cancel(); return; }
      setState(() { timeLeft--; if (timeLeft <= 0 || lives <= 0) { _end(); t.cancel(); } });
    });
  }

  void _spawnFruit() {
    if (!isPlaying) return;
    setState(() => activeFruits.add(_Fruit(
      0.1 + rng.nextDouble() * 0.8, 1.1,
      -(0.018 + rng.nextDouble() * 0.01),
      (rng.nextDouble() - 0.5) * 0.005,
      fruits[rng.nextInt(fruits.length)],
    )));
  }

  void _tick() {
    if (!mounted || !isPlaying) return;
    setState(() {
      for (final f in activeFruits) { f.y += f.vy; f.x += f.vx; f.vy += 0.0006; }
      // Remove fruits that fell off screen
      final missed = activeFruits.where((f) => f.y > 1.2 && !f.sliced).length;
      if (missed > 0) { lives -= missed; if (lives <= 0) _end(); }
      activeFruits.removeWhere((f) => f.y > 1.2);
    });
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    final pos = Offset(d.localPosition.dx / size.width, d.localPosition.dy / size.height);
    setState(() {
      slashTrail.add(pos);
      if (slashTrail.length > 12) slashTrail.removeAt(0);
      for (final f in activeFruits) {
        if (!f.sliced && (Offset(f.x, f.y) - pos).distance < 0.08) { f.sliced = true; score += 10; }
      }
    });
  }

  void _end() {
    spawnTimer?.cancel(); gameTimer?.cancel();
    setState(() { isPlaying = false; if (score > hiScore) { hiScore = score; StorageService.saveHighScore('fruit_slasher', hiScore); } });
  }

  @override
  void dispose() { spawnTimer?.cancel(); gameTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = Size(MediaQuery.of(context).size.width - 32, 380.0);
    return GameWrapper(
      title: 'Fruit Slasher',
      onReset: () { spawnTimer?.cancel(); gameTimer?.cancel(); setState(() { isPlaying = false; activeFruits = []; score = 0; lives = 3; }); },
      gameContent: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Score: $score', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('❤️ $lives', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('⏱ $timeLeft', style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        GestureDetector(
          onPanUpdate: (d) => isPlaying ? _onPanUpdate(d, size) : null,
          onPanEnd: (_) => setState(() => slashTrail.clear()),
          child: Container(
            width: size.width, height: size.height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1a0a2e), Color(0xFF0f0f1e)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.4), width: 2),
            ),
            child: Stack(children: [
              // Slash trail
              CustomPaint(size: size, painter: _SlashPainter(slashTrail)),
              // Fruits
              ...activeFruits.where((f) => !f.sliced).map((f) => Positioned(
                left: f.x * size.width - 20, top: f.y * size.height - 20,
                child: Text(f.emoji, style: const TextStyle(fontSize: 36)),
              )),
              if (!isPlaying)
                Center(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
                  child: Text(score > 0 ? 'Game Over!\nScore: $score\nBest: $hiScore' : 'Swipe to slice fruits!\nDon\'t let them fall!', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        if (!isPlaying)
          ElevatedButton(onPressed: _start, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
            child: Text('SLICE!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18))),
      ]),
    );
  }
}

class _SlashPainter extends CustomPainter {
  final List<Offset> trail;
  _SlashPainter(this.trail);
  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(trail.first.dx * size.width, trail.first.dy * size.height);
    for (int i = 1; i < trail.length; i++) {
      path.lineTo(trail[i].dx * size.width, trail[i].dy * size.height);
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _SlashPainter o) => true;
}
