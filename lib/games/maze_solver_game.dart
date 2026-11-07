import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';

class MazeSolverGame extends StatefulWidget {
  const MazeSolverGame({super.key});
  @override
  State<MazeSolverGame> createState() => _MazeState();
}

class _MazeState extends State<MazeSolverGame> {
  static const int size = 11;
  late List<List<bool>> hWalls, vWalls; // horizontal and vertical walls
  int px = 0, py = 0;
  bool won = false;
  final rng = Random();

  @override
  void initState() { super.initState(); _generateMaze(); }

  void _generateMaze() {
    hWalls = List.generate(size + 1, (_) => List.filled(size, true));
    vWalls = List.generate(size, (_) => List.filled(size + 1, true));
    final visited = List.generate(size, (_) => List.filled(size, false));
    _carveDFS(0, 0, visited);
    setState(() { px = 0; py = 0; won = false; });
  }

  void _carveDFS(int r, int c, List<List<bool>> visited) {
    visited[r][c] = true;
    final dirs = [[0,1],[0,-1],[1,0],[-1,0]]..shuffle(rng);
    for (final d in dirs) {
      final nr = r + d[0], nc = c + d[1];
      if (nr >= 0 && nr < size && nc >= 0 && nc < size && !visited[nr][nc]) {
        // Remove wall between (r,c) and (nr,nc)
        if (d[0] == 0) { // horizontal move
          vWalls[r][min(c, nc) + 1] = false;
        } else { // vertical move
          hWalls[min(r, nr) + 1][c] = false;
        }
        _carveDFS(nr, nc, visited);
      }
    }
  }

  bool _canMove(int r, int c, int dr, int dc) {
    if (r + dr < 0 || r + dr >= size || c + dc < 0 || c + dc >= size) return false;
    if (dr == 0) return !vWalls[r][min(c, c + dc) + 1];
    return !hWalls[min(r, r + dr) + 1][c];
  }

  void _move(int dr, int dc) {
    if (won) return;
    if (_canMove(py, px, dr, dc)) {
      setState(() {
        py += dr; px += dc;
        if (py == size - 1 && px == size - 1) won = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width - 40) / size;
    return GameWrapper(
      title: 'Maze Solver',
      onReset: _generateMaze,
      gameContent: Column(children: [
        const SizedBox(height: 10),
        if (won) Text('🎉 You Solved It!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.yellowAccent))
        else Text('Find the exit! 🏁', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70)),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.indigoAccent, width: 3), borderRadius: BorderRadius.circular(8), color: const Color(0xFF0A0A1A)),
          child: CustomPaint(
            size: Size(cellSize * size, cellSize * size),
            painter: _MazePainter(hWalls, vWalls, px, py, cellSize, size),
          ),
        ),
        const SizedBox(height: 20),
        // D-Pad controls
        Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _dBtn(Icons.arrow_upward, () => _move(-1, 0)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _dBtn(Icons.arrow_back, () => _move(0, -1)),
            const SizedBox(width: 50),
            _dBtn(Icons.arrow_forward, () => _move(0, 1)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _dBtn(Icons.arrow_downward, () => _move(1, 0)),
          ]),
        ]),
        if (won) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _generateMaze, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent), child: Text('New Maze', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ]),
    );
  }

  Widget _dBtn(IconData icon, VoidCallback fn) => Material(
    color: Colors.indigo.withValues(alpha: 0.3),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(onTap: fn, borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon, color: Colors.white, size: 28))),
  );
}

class _MazePainter extends CustomPainter {
  final List<List<bool>> hWalls, vWalls;
  final int px, py, size;
  final double cellSize;
  _MazePainter(this.hWalls, this.vWalls, this.px, this.py, this.cellSize, this.size);

  @override
  void paint(Canvas canvas, Size sz) {
    final wallPaint = Paint()..color = Colors.indigoAccent..strokeWidth = 2..style = PaintingStyle.stroke;
    // Draw h-walls
    for (int r = 0; r <= size; r++) {
      for (int c = 0; c < size; c++) {
        if (hWalls[r][c]) canvas.drawLine(Offset(c * cellSize, r * cellSize), Offset((c + 1) * cellSize, r * cellSize), wallPaint);
      }
    }
    // Draw v-walls
    for (int r = 0; r < size; r++) {
      for (int c = 0; c <= size; c++) {
        if (vWalls[r][c]) canvas.drawLine(Offset(c * cellSize, r * cellSize), Offset(c * cellSize, (r + 1) * cellSize), wallPaint);
      }
    }
    // Exit
    canvas.drawRect(Rect.fromLTWH((size - 1) * cellSize + 2, (size - 1) * cellSize + 2, cellSize - 4, cellSize - 4), Paint()..color = Colors.greenAccent.withValues(alpha: 0.3));
    // Player
    canvas.drawCircle(Offset((px + 0.5) * cellSize, (py + 0.5) * cellSize), cellSize * 0.3, Paint()..color = Colors.yellowAccent
      ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset((px + 0.5) * cellSize, (py + 0.5) * cellSize), cellSize * 0.3, Paint()..color = Colors.yellowAccent..style = PaintingStyle.fill..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  @override
  bool shouldRepaint(covariant _MazePainter o) => o.px != px || o.py != py;
}
