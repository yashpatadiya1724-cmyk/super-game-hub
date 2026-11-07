import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const int gridSize = 8;
  late List<List<String>> grid;
  late List<String> wordsToFind;
  Set<String> foundWords = {};
  List<Offset> selectedOffsets = [];
  
  final List<String> dictionary = [
    'BLOCKY', 'GAMER', 'PUZZLE', 'NEON', 'ROBOT', 
    'SPACE', 'SNAKE', 'BIRD', 'RETRO', 'FLUTTER'
  ];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => _randomLetter()));
    wordsToFind = (dictionary.toList()..shuffle()).take(4).toList();
    foundWords = {};
    selectedOffsets = [];
    
    // Simplistic word placement (horizontal only)
    for (int i = 0; i < wordsToFind.length; i++) {
       String word = wordsToFind[i];
       int row = i * 2;
       int startCol = Random().nextInt(gridSize - word.length + 1);
       for (int j = 0; j < word.length; j++) {
         grid[row][startCol + j] = word[j];
       }
    }
    setState(() {});
  }

  String _randomLetter() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return chars[Random().nextInt(chars.length)];
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
     double cellWidth = constraints.maxWidth / gridSize;
     double cellHeight = constraints.maxHeight / gridSize;
     
     int col = (details.localPosition.dx / cellWidth).floor();
     int row = (details.localPosition.dy / cellHeight).floor();
     
     if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
       Offset off = Offset(row.toDouble(), col.toDouble());
       if (selectedOffsets.isEmpty || selectedOffsets.last != off) {
         setState(() => selectedOffsets.add(off));
       }
     }
  }

  void _onPanEnd(DragEndDetails details) {
    String selectedWord = selectedOffsets.map((o) => grid[o.dx.toInt()][o.dy.toInt()]).join();
    if (wordsToFind.contains(selectedWord) && !foundWords.contains(selectedWord)) {
      setState(() => foundWords.add(selectedWord));
    }
    setState(() => selectedOffsets = []);
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Word Search",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
               spacing: 10,
               children: wordsToFind.map((w) => Text(w, style: GoogleFonts.outfit(
                 color: foundWords.contains(w) ? Colors.greenAccent : Colors.white60,
                 decoration: foundWords.contains(w) ? TextDecoration.lineThrough : null,
                 fontSize: 16, fontWeight: FontWeight.bold
               ))).toList(),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                   onPanUpdate: (d) => _onPanUpdate(d, constraints),
                   onPanEnd: _onPanEnd,
                   child: Container(
                     decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
                     child: GridView.builder(
                        itemCount: gridSize * gridSize,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
                        itemBuilder: (context, index) {
                           int row = index ~/ gridSize;
                           int col = index % gridSize;
                           bool isSelected = selectedOffsets.any((o) => o.dx == row && o.dy == col);
                           return Container(
                             color: isSelected ? Colors.yellowAccent.withOpacity(0.3) : Colors.transparent,
                             child: Center(
                               child: Text(grid[row][col], style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                             ),
                           );
                        },
                     ),
                   ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
