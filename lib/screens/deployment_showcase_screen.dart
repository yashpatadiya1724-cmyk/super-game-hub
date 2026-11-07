import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DeploymentShowcaseScreen extends StatelessWidget {
  const DeploymentShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Deployment & Play Store Assets",
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
            // APK & Build Info Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade900, Colors.green.shade800],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.greenAccent, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ANDROID APK DEPLOYMENT",
                          style: GoogleFonts.outfit(
                              color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("BUILD READY",
                            style: GoogleFonts.outfit(
                                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Super Game Hub v3.0 (Release)",
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Package: com.example.super_game_hub | Min SDK: 21 | Target SDK: 34",
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("APK Build Command: flutter build apk --release --split-per-abi"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.android),
                    label: Text("VIEW APK BUILD SPECS", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text("Google Play Store Listing Assets",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // App Icon & Graphic Card
            _buildAssetSection(
              title: "1. High-Res App Icon (512x512 PNG)",
              icon: Icons.app_shortcut,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Colors.purpleAccent, blurRadius: 12)],
                    ),
                    child: const Icon(Icons.sports_esports, size: 48, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("3D Neon Super Hub Badge",
                            style: GoogleFonts.outfit(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("Format: PNG 32-bit with Alpha\nResolution: 512px x 512px (Max 1024KB)",
                            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Feature Graphic & Screenshots Preview
            _buildAssetSection(
              title: "2. Feature Graphic & Screenshots (1024x500 Banner)",
              icon: Icons.photo_library,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade900, Colors.purple.shade900, Colors.pink.shade900],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("SUPER GAME HUB",
                              style: GoogleFonts.outfit(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                          Text("50+ Retro & AI Games in One App!",
                              style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniScreenshot("AI Pathfinder", Colors.orangeAccent),
                      _buildMiniScreenshot("Analytics Dash", Colors.greenAccent),
                      _buildMiniScreenshot("Arcade Store", Colors.purpleAccent),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Store Metadata & Descriptions
            _buildAssetSection(
              title: "3. Store Listing Metadata & Description",
              icon: Icons.description,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("App Title:",
                      style: GoogleFonts.outfit(
                          color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("Super Game Hub: AI Arcade & Puzzle Collection",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("Short Description (80 chars max):",
                      style: GoogleFonts.outfit(
                          color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("Play 50+ offline arcade, puzzle, & smart AI games with live analytics!",
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text("Full Description Snippet:",
                      style: GoogleFonts.outfit(
                          color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(
                      "Super Game Hub brings you an incredible collection of 50+ instant games powered by smart AI pathfinding, real-time analytics, smooth 60 FPS performance, and exciting customizeable skins!",
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.outfit(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMiniScreenshot(String label, Color color) {
    return Container(
      width: 90,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_android, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
