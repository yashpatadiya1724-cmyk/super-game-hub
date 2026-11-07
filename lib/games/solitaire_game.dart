import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class SolitaireGame extends StatefulWidget {
  const SolitaireGame({super.key});

  @override
  State<SolitaireGame> createState() => _SolitaireGameState();
}

class CardModel {
  final int value; // 1-13
  final String suit; // H, D, C, S
  bool isFaceUp;
  CardModel(this.value, this.suit, {this.isFaceUp = false});
  
  Color get color => (suit == 'H' || suit == 'D') ? Colors.red : Colors.black;
  String get label {
    if (value == 1) return 'A';
    if (value == 11) return 'J';
    if (value == 12) return 'Q';
    if (value == 13) return 'K';
    return value.toString();
  }
}

class _SolitaireGameState extends State<SolitaireGame> {
  late List<List<CardModel>> stacks;
  late List<CardModel> drawStack;
  late List<CardModel> discardStack;
  
  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    List<CardModel> deck = [];
    for (var suit in ['H', 'D', 'C', 'S']) {
      for (int i = 1; i <= 13; i++) {
        deck.add(CardModel(i, suit));
      }
    }
    deck.shuffle();

    stacks = List.generate(7, (index) {
      List<CardModel> stack = [];
      for (int i = 0; i <= index; i++) {
        var card = deck.removeLast();
        if (i == index) card.isFaceUp = true;
        stack.add(card);
      }
      return stack;
    });

    drawStack = deck;
    discardStack = [];
    setState(() {});
  }

  void _onDraw() {
    setState(() {
      if (drawStack.isEmpty) {
        drawStack = discardStack.reversed.map((c) => c..isFaceUp = false).toList();
        discardStack = [];
      } else {
        var card = drawStack.removeLast();
        card.isFaceUp = true;
        discardStack.add(card);
      }
    });
  }

  void _onMove(int fromStackIndex, int cardIndex, int toStackIndex) {
    // Basic logic: allow any move for simplified mini-game or add rules
    setState(() {
      var moving = stacks[fromStackIndex].sublist(cardIndex);
      stacks[fromStackIndex].removeRange(cardIndex, stacks[fromStackIndex].length);
      if (stacks[fromStackIndex].isNotEmpty) stacks[fromStackIndex].last.isFaceUp = true;
      stacks[toStackIndex].addAll(moving);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Solitaire",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          // Draw Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _onDraw,
                  child: _buildCardBack(drawStack.length),
                ),
                if (discardStack.isNotEmpty) _buildCard(discardStack.last),
                const SizedBox(width: 40), // Space for foundation (simplified)
                Icon(Icons.auto_awesome, color: Colors.yellowAccent.withValues(alpha: 0.3), size: 50),
              ],
            ),
          ),
          // Play Area
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (index) => _buildStack(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(CardModel card) {
    return Container(
      width: 45,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(card.label, style: GoogleFonts.outfit(color: card.color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(card.suit, style: TextStyle(color: card.color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(int count) {
    return Container(
      width: 45,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: Center(child: Text(count.toString(), style: const TextStyle(color: Colors.white))),
    );
  }

  Widget _buildStack(int stackIndex) {
    return SizedBox(
      width: 50,
      child: Stack(
        children: List.generate(stacks[stackIndex].length, (index) {
          var card = stacks[stackIndex][index];
          return Positioned(
            top: index * 20.0,
            child: GestureDetector(
              onTap: () {
                // Simplified move logic: find a different stack to move to
                int nextStack = (stackIndex + 1) % 7;
                if (card.isFaceUp) _onMove(stackIndex, index, nextStack);
              },
              child: card.isFaceUp ? _buildCard(card) : _buildCardBack(0),
            ),
          );
        }),
      ),
    );
  }
}
