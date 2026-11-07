import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/audio_feedback_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class GameWrapper extends StatefulWidget {
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
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  void _showLeaderboard() {
    AudioFeedbackService.playTap();
    final scores = StorageService.getLeaderboard(widget.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(
              "LEADERBOARD",
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: scores.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No scores recorded yet!\nPlay and set the first record.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white70),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: scores.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white12),
                  itemBuilder: (context, index) {
                    final item = scores[index];
                    Color medalColor = Colors.white70;
                    if (index == 0) medalColor = Colors.amber;
                    if (index == 1) medalColor = const Color(0xFFC0C0C0);
                    if (index == 2) medalColor = const Color(0xFFCD7F32);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: medalColor.withValues(alpha: 0.2),
                        child: Text(
                          "#${index + 1}",
                          style: TextStyle(color: medalColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      title: Text(item.playerName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(item.date, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                      trailing: Text(
                        "${item.score} pts",
                        style: GoogleFonts.outfit(color: AppTheme.accentBrain, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: Text("CLOSE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.title,
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
            tooltip: AudioFeedbackService.soundEnabled ? "Mute Sound" : "Unmute Sound",
            icon: Icon(
              AudioFeedbackService.soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: AudioFeedbackService.soundEnabled ? Colors.white : Colors.white38,
            ),
            onPressed: () {
              setState(() {
                AudioFeedbackService.toggleSound();
              });
            },
          ),
          IconButton(
            tooltip: "Leaderboard",
            icon: const Icon(Icons.leaderboard, color: Colors.amber),
            onPressed: _showLeaderboard,
          ),
          IconButton(
            tooltip: "Reset Game",
            icon: const Icon(Icons.refresh),
            onPressed: () {
              AudioFeedbackService.playTap();
              widget.onReset();
            },
          ),
          IconButton(
            tooltip: "Pause Menu",
            icon: const Icon(Icons.pause),
            onPressed: () {
              AudioFeedbackService.playTap();
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
                        AudioFeedbackService.playTap();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit game
                      },
                    ),
                    Container(
                      decoration: AppTheme.blocky(color: AppTheme.accentBrain),
                      child: TextButton(
                        child: Text("RESUME", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          AudioFeedbackService.playTap();
                          Navigator.pop(context);
                        },
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
          SafeArea(child: widget.gameContent),
          if (widget.overlay != null) widget.overlay!,
        ],
      ),
    );
  }
}
