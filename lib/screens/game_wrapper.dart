import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class GameWrapper extends StatelessWidget {
  final String title;
  final Widget gameContent;
  final VoidCallback onReset;
  final Widget? overlay;

  const GameWrapper({
    super.key,
    required this.title,
    required this.gameContent,
    required this.onReset,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            shadows: const [Shadow(color: Colors.black, blurRadius: 0, offset: Offset(2, 2))],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              // Show pause menu
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white12, width: 2),
                  ),
                  title: Text("PAUSED", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900)),
                  content: Text("Do you want to continue?", style: GoogleFonts.outfit(color: Colors.white70)),
                  actions: [
                    TextButton(
                      child: Text("EXIT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white54)),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit game
                      },
                    ),
                    Container(
                      decoration: AppTheme.blocky(color: AppTheme.accentBrain),
                      child: TextButton(
                        child: Text("RESUME", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(child: gameContent),
          ?overlay,
        ],
      ),
    );
  }
}
