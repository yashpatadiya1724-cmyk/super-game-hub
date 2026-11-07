import 'dart:math' show Random;
import 'package:flutter/material.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class BlockPuzzleGame extends StatefulWidget {
  const BlockPuzzleGame({super.key});

  @override
  State<BlockPuzzleGame> createState() => _BlockPuzzleGameState();
}

class _BlockPuzzleGameState extends State<BlockPuzzleGame> {
  static const int gridSize = 8;
  List<List<bool>> grid = List.generate(gridSize, (_) => List.filled(gridSize, false));
  int score = 0;

  // Simple blocks (represented by relative coordinates)
  final List<List<Offset>> blocks = [
    [const Offset(0, 0), const Offset(1, 0), const Offset(0, 1), const Offset(1, 1)], // Square
    [const Offset(0, 0), const Offset(1, 0), const Offset(2, 0)], // Line
    [const Offset(0, 0), const Offset(0, 1), const Offset(0, 2)], // Vertical Line
    [const Offset(0, 0), const Offset(1, 0), const Offset(1, 1)], // L shape
  ];

  late List<int> availableBlocks;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      grid = List.generate(gridSize, (_) => List.filled(gridSize, false));
      score = 0;
      _refreshBlocks();
    });
  }

  void _refreshBlocks() {
    availableBlocks = [
      Random().nextInt(blocks.length),
      Random().nextInt(blocks.length),
      Random().nextInt(blocks.length),
    ];
  }

  bool _canPlace(int blockIdx, int r, int c) {
    for (var offset in blocks[blockIdx]) {
      int nr = r + offset.dy.toInt();
      int nc = c + offset.dx.toInt();
      if (nr < 0 || nr >= gridSize || nc < 0 || nc >= gridSize || grid[nr][nc]) {
        return false;
      }
    }
    return true;
  }

  void _placeBlock(int blockIdx, int r, int c, int listIdx) {
    setState(() {
      for (var offset in blocks[blockIdx]) {
        grid[r + offset.dy.toInt()][c + offset.dx.toInt()] = true;
      }
      score += blocks[blockIdx].length * 10;
      availableBlocks[listIdx] = -1;

      _checkLines();

      if (availableBlocks.every((idx) => idx == -1)) {
        _refreshBlocks();
      }

      if (_checkGameOver()) {
        _showGameOver();
      }
    });
  }

  void _checkLines() {
    List<int> rowsToClear = [];
    List<int> colsToClear = [];

    for (int i = 0; i < gridSize; i++) {
      if (grid[i].every((cell) => cell)) rowsToClear.add(i);
      bool colFull = true;
      for (int j = 0; j < gridSize; j++) {
        if (!grid[j][i]) {
          colFull = false;
          break;
        }
      }
      if (colFull) colsToClear.add(i);
    }

    for (var r in rowsToClear) {
      grid[r] = List.filled(gridSize, false);
      score += 100;
    }
    for (var c in colsToClear) {
      for (int i = 0; i < gridSize; i++) {
        grid[i][c] = false;
      }
      score += 100;
    }
  }

  bool _checkGameOver() {
    // Very simplified: check if any available block can fit anywhere
    for (int i = 0; i < availableBlocks.length; i++) {
      int blockIdx = availableBlocks[i];
      if (blockIdx == -1) continue;
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (_canPlace(blockIdx, r, c)) return false;
        }
      }
    }
    return true;
  }

  void _showGameOver() {
    StorageService.saveHighScore('block_puzzle', score);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score: $score"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Block Puzzle",
      onReset: _resetGame,
      gameContent: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Score: $score", style: const TextStyle(fontSize: 24, color: Colors.white)),
          ),
          // Grid
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
                itemCount: gridSize * gridSize,
                itemBuilder: (context, index) {
                  int r = index ~/ gridSize;
                  int c = index % gridSize;
                  return DragTarget<int>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        color: grid[r][c] ? Colors.orangeAccent : Colors.white12,
                      );
                    },
                    onWillAcceptWithDetails: (details) => _canPlace(availableBlocks[details.data], r, c),
                    onAcceptWithDetails: (details) => _placeBlock(availableBlocks[details.data], r, c, details.data),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Blocks to drag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              if (availableBlocks[i] == -1) return const SizedBox(width: 80, height: 80);
              return Draggable<int>(
                data: i,
                feedback: _buildBlockPreview(availableBlocks[i], scale: 1.2),
                childWhenDragging: Opacity(opacity: 0.3, child: _buildBlockPreview(availableBlocks[i])),
                child: _buildBlockPreview(availableBlocks[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockPreview(int blockIdx, {double scale = 1.0}) {
    List<Offset> pts = blocks[blockIdx];
    return SizedBox(
      width: 80 * scale,
      height: 80 * scale,
      child: Stack(
        children: pts.map((p) => Positioned(
          left: p.dx * 20 * scale,
          top: p.dy * 20 * scale,
          child: Container(width: 18 * scale, height: 18 * scale, color: Colors.orangeAccent),
        )).toList(),
      ),
    );
  }
}
