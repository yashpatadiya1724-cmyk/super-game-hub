import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class ReactionGame extends StatefulWidget {
  const ReactionGame({super.key});

  @override
  State<ReactionGame> createState() => _ReactionGameState();
}

class _ReactionGameState extends State<ReactionGame> {
  String status = "Tap to start";
  Color bgColor = Colors.blueAccent;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  bool isWaiting = false;
  bool isReady = false;
  int lastReactionTime = 0;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      status = "Wait for GREEN...";
      bgColor = Colors.redAccent;
      isWaiting = true;
      isReady = false;
    });

    int waitTime = 2000 + Random().nextInt(3000);
    timer = Timer(Duration(milliseconds: waitTime), () {
      if (!isWaiting) return;
      setState(() {
        status = "TAP NOW!";
        bgColor = Colors.greenAccent;
        isWaiting = false;
        isReady = true;
        stopwatch.reset();
        stopwatch.start();
      });
    });
  }

  void _handleTap() {
    if (status == "Tap to start" || status.contains("ms")) {
      _startTest();
    } else if (isWaiting) {
      timer?.cancel();
      setState(() {
        status = "Too soon! Tap to try again.";
        bgColor = Colors.deepOrange;
        isWaiting = false;
      });
    } else if (isReady) {
      stopwatch.stop();
      int reaction = stopwatch.elapsedMilliseconds;
      setState(() {
        status = "$reaction ms\nTap to try again.";
        bgColor = Colors.blueAccent;
        isReady = false;
        lastReactionTime = reaction;
        StorageService.saveHighScore('reaction', reaction == 0 ? 9999 : reaction); // Save "best" as lowest
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Reaction Test",
      onReset: () {
        timer?.cancel();
        setState(() {
          status = "Tap to start";
          bgColor = Colors.blueAccent;
          isWaiting = false;
          isReady = false;
        });
      },
      gameContent: GestureDetector(
        onTap: _handleTap,
        child: Container(
          color: bgColor.withValues(alpha: 0.8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app, size: 80, color: Colors.white),
                const SizedBox(height: 30),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  "Best: ${StorageService.getHighScore('reaction')} ms",
                  style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
