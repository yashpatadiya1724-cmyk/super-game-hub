import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Minecraft & Roblox Palette
  static const Color background = Color(0xFF121212); // Deep dark grey (Roblox dark mode)
  static const Color surface = Color(0xFF232527); // Slightly lighter grey
  static const Color accentArcade = Color(0xFFE52521); // Roblox Red / Lava
  static const Color accentPuzzle = Color(0xFF45F3DC); // Minecraft Diamond
  static const Color accentBrain = Color(0xFF5CA038); // Minecraft Grass
  static const Color accentClassic = Color(0xFFF9A03F); // Blocky Gold
  static const Color accentCasual = Color(0xFF8B4513); // Dirt Brown

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentArcade,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentArcade,
        brightness: Brightness.dark,
        surface: surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        surfaceTintColor: Colors.transparent,
        color: surface,
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Blockier borders
          side: const BorderSide(color: Colors.white12, width: 2),
        ),
      ),
    );
  }

  static BoxDecoration blocky({Color? color}) {
    return BoxDecoration(
      color: (color ?? surface).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black.withValues(alpha: 0.8), width: 3),
      boxShadow: [
        BoxShadow(
          color: (color ?? Colors.white).withValues(alpha: 0.3),
          offset: const Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  static Gradient categoryGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
    );
  }
}
