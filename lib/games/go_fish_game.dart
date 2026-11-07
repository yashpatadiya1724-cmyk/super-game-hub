import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class GoFishGame extends StatefulWidget {
  const GoFishGame({super.key});

  @override
  State<GoFishGame> createState() => _GoFishGameState();
}

class _GoFishGameState extends State<GoFishGame> {
  late List<int> deck;
  late List<int> hand1;
  late List<int> hand2;
  int score1 = 0;
  int score2 = 0;
  bool isP1Turn = true;
  String log = "P1 START!";

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    deck = [];
    for (int i = 1; i <= 13; i++) {
      for (int j = 0; j < 4; j++) deck.add(i);
    }
    deck.shuffle();

    hand1 = deck.skip(0).take(7).toList();
    hand2 = deck.skip(7).take(7).toList();
    deck = deck.skip(14).toList();
    score1 = 0;
    score2 = 0;
    isP1Turn = true;
    log = "DEALT 7 CARDS EACH.";
    setState(() {});
  }

  void _onAsk(int rank) {
    if ((isP1Turn && hand1.isEmpty) || (!isP1Turn && hand2.isEmpty)) return;
    
    setState(() {
      if (isP1Turn) {
        if (hand2.contains(rank)) {
          var found = hand2.where((c) => c == rank).toList();
          hand2.removeWhere((c) => c == rank);
          hand1.addAll(found);
          log = "P1 TOOK ${found.length} x $rank FROM P2!";
          _checkBooks(hand1, true);
        } else {
          log = "P2: GO FISH!";
          if (deck.isNotEmpty) {
            int draw = deck.removeLast();
            hand1.add(draw);
            _checkBooks(hand1, true);
            if (draw == rank) {
              log = "P1 FISHED A $rank! EXTRA TURN.";
              return;
            }
          }
          isP1Turn = false;
        }
      } else {
        if (hand1.contains(rank)) {
          var found = hand1.where((c) => c == rank).toList();
          hand1.removeWhere((c) => c == rank);
          hand2.addAll(found);
          log = "P2 TOOK ${found.length} x $rank FROM P1!";
          _checkBooks(hand2, false);
        } else {
          log = "P1: GO FISH!";
          if (deck.isNotEmpty) {
            int draw = deck.removeLast();
            hand2.add(draw);
            _checkBooks(hand2, false);
            if (draw == rank) {
              log = "P2 FISHED A $rank! EXTRA TURN.";
              return;
            }
          }
          isP1Turn = true;
        }
      }
    });
  }

  void _checkBooks(List<int> hand, bool isP1) {
    Map<int, int> counts = {};
    for (var r in hand) counts[r] = (counts[r] ?? 0) + 1;
    for (var rank in counts.keys) {
      if (counts[rank] == 4) {
        hand.removeWhere((c) => c == rank);
        if (isP1) score1++; else score2++;
        log = (isP1 ? "P1" : "P2") + " COMPLETED A BOOK OF $rank!";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Go Fish",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("P1: $score1", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("P2: $score2", style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(height: 2, color: Colors.white10),
          Expanded(
            child: Column(
              children: [
                // P2 Hand (Simplified, only rank choices)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (hand2.toSet().toList()..sort()).map((rank) => _buildCardButton(rank, false)).toList(),
                      ),
                    ),
                  ),
                ),
                // Game Log
                Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                   child: Text(log, style: GoogleFonts.outfit(color: Colors.yellowAccent, fontSize: 16), textAlign: TextAlign.center),
                ),
                // P1 Hand
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (hand1.toSet().toList()..sort()).map((rank) => _buildCardButton(rank, true)).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text("${deck.length} CARDS IN DECK", style: const TextStyle(color: Colors.white24)),
          )
        ],
      ),
    );
  }

  Widget _buildCardButton(int rank, bool isP1) {
    bool isMyTurn = isP1Turn == isP1;
    String label = rank == 1 ? 'A' : rank == 11 ? 'J' : rank == 12 ? 'Q' : rank == 13 ? 'K' : rank.toString();
    return GestureDetector(
      onTap: isMyTurn ? () => _onAsk(rank) : null,
      child: Container(
        width: 45, height: 65,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isMyTurn ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isMyTurn ? Colors.yellowAccent : Colors.transparent, width: 2),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.outfit(color: isMyTurn ? Colors.black : Colors.white24, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }
}
