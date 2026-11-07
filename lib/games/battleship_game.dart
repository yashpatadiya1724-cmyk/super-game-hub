import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class BattleshipGame extends StatefulWidget {
  const BattleshipGame({super.key});
  @override
  State<BattleshipGame> createState() => _BattleshipState();
}

class _BattleshipState extends State<BattleshipGame> {
  // Phases: 0=P1 place ships, 1=P2 place ships, 2=P1 attack, 3=P2 attack
  int phase = 0;
  final rng = Random();
  // 0=empty, 1=ship, 2=hit, 3=miss
  List<List<int>> p1Board = List.generate(8, (_) => List.filled(8, 0));
  List<List<int>> p2Board = List.generate(8, (_) => List.filled(8, 0));
  int p1Ships = 0, p2Ships = 0;
  final shipSizes = [4, 3, 3, 2, 2];
  int shipIdx = 0;
  bool horizontal = true;
  String message = 'Player 1: Place your ships! Tap to place.';

  void _autoPlace(List<List<int>> board) {
    for (final size in shipSizes) {
      bool placed = false;
      while (!placed) {
        final horiz = rng.nextBool();
        final r = rng.nextInt(horiz ? 8 : 8 - size + 1);
        final c = rng.nextInt(horiz ? 8 - size + 1 : 8);
        bool ok = true;
        for (int i = 0; i < size; i++) {
          if (board[horiz ? r : r + i][horiz ? c + i : c] != 0) { ok = false; break; }
        }
        if (ok) {
          for (int i = 0; i < size; i++) board[horiz ? r : r + i][horiz ? c + i : c] = 1;
          placed = true;
        }
      }
    }
  }

  void _placeShip(int r, int c) {
    if (phase > 1) return;
    final board = phase == 0 ? p1Board : p2Board;
    final size = shipSizes[shipIdx];
    final positions = <List<int>>[];
    bool ok = true;
    for (int i = 0; i < size; i++) {
      final nr = horizontal ? r : r + i;
      final nc = horizontal ? c + i : c;
      if (nr >= 8 || nc >= 8 || board[nr][nc] != 0) { ok = false; break; }
      positions.add([nr, nc]);
    }
    if (!ok) { setState(() => message = 'Cannot place here! Try again.'); return; }
    setState(() {
      for (final p in positions) board[p[0]][p[1]] = 1;
      shipIdx++;
      if (shipIdx >= shipSizes.length) {
        if (phase == 0) { phase = 1; shipIdx = 0; message = 'Player 2: Place your ships!'; }
        else { phase = 2; message = 'Player 1: Attack Player 2\'s grid!'; }
      } else {
        message = 'Place ship of size ${shipSizes[shipIdx]}';
      }
    });
  }

  void _attack(int r, int c) {
    final target = phase == 2 ? p2Board : p1Board;
    if (target[r][c] == 2 || target[r][c] == 3) return;
    setState(() {
      final hit = target[r][c] == 1;
      target[r][c] = hit ? 2 : 3;
      if (hit) {
        if (phase == 2) { p2Ships++; message = '💥 Hit! P1 fires again!'; }
        else { p1Ships++; message = '💥 Hit! P2 fires again!'; }
      } else {
        if (phase == 2) { phase = 3; message = 'Player 2: Attack Player 1\'s grid!'; }
        else { phase = 2; message = 'Player 1: Attack Player 2\'s grid!'; }
      }
    });
  }

  bool _pWins(List<List<int>> board) {
    int ships = 0;
    for (final row in board) { for (final c in row) { if (c == 1) ships++; } }
    return ships == 0;
  }

  @override
  Widget build(BuildContext context) {
    final p2Won = _pWins(p2Board) && phase >= 2;
    final p1Won = _pWins(p1Board) && phase >= 2;
    final cellSize = (MediaQuery.of(context).size.width - 64) / 8;
    final showBoard = phase <= 1 ? (phase == 0 ? p1Board : p2Board) : (phase == 2 ? p2Board : p1Board);
    final hideShips = phase >= 2;

    return GameWrapper(
      title: 'Battleship',
      onReset: () => setState(() { phase = 0; shipIdx = 0; horizontal = true; p1Board = List.generate(8, (_) => List.filled(8, 0)); p2Board = List.generate(8, (_) => List.filled(8, 0)); p1Ships = 0; p2Ships = 0; message = 'Player 1: Place your ships!'; }),
      gameContent: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        if (p1Won || p2Won)
          Text(p2Won ? '🔴 Player 1 Wins!' : '🔵 Player 2 Wins!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellowAccent))
        else
          Text(message, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        if (phase <= 1) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Direction: ', style: GoogleFonts.outfit(color: Colors.white70)),
            GestureDetector(
              onTap: () => setState(() => horizontal = !horizontal),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueAccent)),
                child: Text(horizontal ? '→ Horizontal' : '↓ Vertical', style: GoogleFonts.outfit(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          ElevatedButton(onPressed: () {
            setState(() {
              _autoPlace(phase == 0 ? p1Board : p2Board);
              if (phase == 0) { phase = 1; shipIdx = 0; message = 'Player 2: Place your ships!'; }
              else { phase = 2; message = 'Player 1: Attack Player 2\'s grid!'; }
              shipIdx = shipSizes.length;
            });
          }, child: Text('Auto Place', style: GoogleFonts.outfit(color: Colors.white))),
        ],
        const SizedBox(height: 8),
        // Grid
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), width: 2), borderRadius: BorderRadius.circular(8)),
          child: Column(children: List.generate(8, (r) => Row(children: List.generate(8, (c) {
            final cell = showBoard[r][c];
            Color bg = const Color(0xFF0A1628);
            Widget? child;
            if (cell == 1 && !hideShips) bg = Colors.blueGrey.shade700;
            if (cell == 2) { bg = Colors.redAccent.withValues(alpha: 0.6); child = const Center(child: Text('💥', style: TextStyle(fontSize: 14))); }
            if (cell == 3) { bg = Colors.white10; child = const Center(child: Text('○', style: TextStyle(color: Colors.white38, fontSize: 16))); }
            return GestureDetector(
              onTap: () => phase <= 1 ? _placeShip(r, c) : (!p1Won && !p2Won ? _attack(r, c) : null),
              child: Container(
                width: cellSize, height: cellSize,
                decoration: BoxDecoration(color: bg, border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2), width: 0.5)),
                child: child,
              ),
            );
          })))),
        ),
      ]))),
    );
  }
}
