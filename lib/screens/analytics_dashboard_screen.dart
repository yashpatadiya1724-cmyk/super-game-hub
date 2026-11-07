import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../registry/game_registry.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late int totalSessions;
  late int totalPlaySeconds;
  late List<Game> games;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    totalSessions = StorageService.getSessionCount();
    totalPlaySeconds = StorageService.getTotalPlayTimeSeconds();
    games = GameRegistry.getGames();
  }

  String _formatPlayTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes}m ${secs}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Game Analytics Dashboard",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    "TOTAL SESSIONS",
                    "$totalSessions",
                    Icons.directions_run,
                    Colors.cyanAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    "PLAY TIME",
                    _formatPlayTime(totalPlaySeconds),
                    Icons.timer,
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12, height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    "AVG SESSION",
                    "${(totalPlaySeconds / (totalSessions > 0 ? totalSessions : 1)).round()}s",
                    Icons.analytics,
                    Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    "TARGET FPS",
                    "60 FPS (Smooth)",
                    Icons.speed,
                    Colors.greenAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text("Top Played Games & Highscores",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Per-Game Stats List
            ...games.take(10).map((game) {
              int plays = StorageService.getGamePlayedCount(game.id);
              int score = StorageService.getHighScore(game.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: game.themeColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: game.themeColor.withValues(alpha: 0.2),
                      child: Icon(game.icon, color: game.themeColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(game.title,
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                          Text("Sessions Played: $plays",
                              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("HIGH SCORE",
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text("$score pts",
                            style: GoogleFonts.outfit(
                                color: Colors.yellowAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            // Session Log Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history, color: Colors.cyanAccent, size: 20),
                      const SizedBox(width: 8),
                      Text("Latest Session Timestamp",
                          style: GoogleFonts.outfit(
                              color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Last Active: ${StorageService.getLastSessionTime()}",
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text("Data Persisted: Local Encrypted SharedPreferences",
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.outfit(
                      color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.outfit(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
