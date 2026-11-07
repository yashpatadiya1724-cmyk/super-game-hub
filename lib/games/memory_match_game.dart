import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  static const List<IconData> icons = [
    Icons.favorite, Icons.star, Icons.cake, Icons.pets,
    Icons.wb_sunny, Icons.beach_access, Icons.anchor, Icons.cloud,
  ];

  late List<IconData> boardIcons;
  late List<bool> cardFlipped;
  late List<bool> cardMatched;
  int? firstSelectedIndex;
  bool isBusy = false;
  int moves = 0;
  int matches = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      boardIcons = [...icons, ...icons]..shuffle();
      cardFlipped = List.filled(16, false);
      cardMatched = List.filled(16, false);
      firstSelectedIndex = null;
      isBusy = false;
      moves = 0;
      matches = 0;
    });
  }

  void _onCardTap(int index) {
    if (isBusy || cardFlipped[index] || cardMatched[index]) return;

    setState(() {
      cardFlipped[index] = true;
      if (firstSelectedIndex == null) {
        firstSelectedIndex = index;
      } else {
        moves++;
        isBusy = true;
        if (boardIcons[firstSelectedIndex!] == boardIcons[index]) {
          cardMatched[firstSelectedIndex!] = true;
          cardMatched[index] = true;
          matches++;
          isBusy = false;
          firstSelectedIndex = null;
          if (matches == icons.length) {
            StorageService.saveHighScore('memorymatch', moves);
          }
        } else {
          Timer(const Duration(milliseconds: 1000), () {
            setState(() {
              cardFlipped[firstSelectedIndex!] = false;
              cardFlipped[index] = false;
              firstSelectedIndex = null;
              isBusy = false;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Memory Match",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Moves: $moves", style: GoogleFonts.outfit(fontSize: 24, color: Colors.white)),
                Text("Best: ${StorageService.getHighScore('memorymatch')}", style: GoogleFonts.outfit(fontSize: 18, color: Colors.white60)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                bool isVisible = cardFlipped[index] || cardMatched[index];
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isVisible ? Colors.blueAccent : Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        isVisible ? boardIcons[index] : Icons.question_mark,
                        color: isVisible ? Colors.white : Colors.white24,
                        size: 32,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (matches == icons.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Text("WELL DONE!", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            ),
        ],
      ),
    );
  }
}
