import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

// Generic Placeholder for games still under construction
class MiniGamePlaceholder extends StatelessWidget {
  final String title;
  const MiniGamePlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: title,
      onReset: () {},
      gameContent: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.white54),
            const SizedBox(height: 20),
            Text("$title\nComing Soon!", style: GoogleFonts.outfit(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text("Check back for updates.", style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// Still placeholder - complex games
class SolitaireGame extends StatelessWidget { const SolitaireGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Solitaire"); }
class JigsawPuzzleGame extends StatelessWidget { const JigsawPuzzleGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Jigsaw Puzzle"); }
class TowerDefenderGame extends StatelessWidget { const TowerDefenderGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Tower Defender"); }
class PinballGame extends StatelessWidget { const PinballGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Pinball"); }
class WordSearchGame extends StatelessWidget { const WordSearchGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Word Search"); }
class AirHockeyGame extends StatelessWidget { const AirHockeyGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Air Hockey"); }
class ChessGame extends StatelessWidget { const ChessGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Chess"); }
class TankWarsGame extends StatelessWidget { const TankWarsGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Tank Wars"); }
class ThumbFighterGame extends StatelessWidget { const ThumbFighterGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Thumb Fighter"); }
class RacingBlocksGame extends StatelessWidget { const RacingBlocksGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Racing Blocks"); }
class OthelloGame extends StatelessWidget { const OthelloGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Othello"); }
class GoFishGame extends StatelessWidget { const GoFishGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Go Fish"); }
class TicTacToe3DGame extends StatelessWidget { const TicTacToe3DGame({super.key}); @override Widget build(BuildContext context) => const MiniGamePlaceholder(title: "Tic Tac Toe 3D"); }
