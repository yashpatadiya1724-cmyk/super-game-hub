import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/game_wrapper.dart';
import '../services/storage_service.dart';

enum NPCState { idle, patrol, chase, attack }

class PathNode {
  final int x;
  final int y;
  PathNode(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathNode && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Projectile {
  bool active = false;
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;

  void spawn(double startX, double startY, double targetX, double targetY) {
    active = true;
    x = startX;
    y = startY;
    double dx = targetX - startX;
    double dy = targetY - startY;
    double len = sqrt(dx * dx + dy * dy);
    if (len > 0) {
      vx = (dx / len) * 7.0;
      vy = (dy / len) * 7.0;
    }
  }

  void update() {
    if (!active) return;
    x += vx;
    y += vy;
  }
}

/// Object Pooling Pattern Implementation (Assignment Requirement 3)
class ProjectilePool {
  final List<Projectile> _pool = List.generate(30, (_) => Projectile());

  Projectile? obtain(double startX, double startY, double targetX, double targetY) {
    for (var p in _pool) {
      if (!p.active) {
        p.spawn(startX, startY, targetX, targetY);
        return p;
      }
    }
    return null; // Pool capacity reached
  }

  List<Projectile> get activeProjectiles => _pool.where((p) => p.active).toList();

  int get activeCount => _pool.where((p) => p.active).length;
  int get totalCapacity => _pool.length;
}

class SmartAIGame extends StatefulWidget {
  const SmartAIGame({super.key});

  @override
  State<SmartAIGame> createState() => _SmartAIGameState();
}

class _SmartAIGameState extends State<SmartAIGame> {
  static const int gridSize = 12;
  late List<List<bool>> obstacles;

  // Player position in grid units
  int playerX = 10;
  int playerY = 10;
  int playerHealth = 100;
  int score = 0;

  // NPC AI state
  double npcPx = 1.0;
  double npcPy = 1.0;
  NPCState npcState = NPCState.idle;
  List<PathNode> currentPath = [];
  int patrolIndex = 0;
  final List<PathNode> patrolWaypoints = [
    PathNode(1, 1),
    PathNode(1, 10),
    PathNode(10, 1),
    PathNode(5, 5),
  ];

  // Object pool for projectiles
  final ProjectilePool bulletPool = ProjectilePool();

  Timer? gameLoopTimer;
  DateTime lastStateChange = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initGrid();
    _startGameLoop();
  }

  void _initGrid() {
    obstacles = List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));
    // Set fixed obstacles for pathfinding demonstration
    obstacles[3][3] = true;
    obstacles[3][4] = true;
    obstacles[3][5] = true;
    obstacles[7][6] = true;
    obstacles[7][7] = true;
    obstacles[7][8] = true;
    obstacles[4][8] = true;
    obstacles[5][8] = true;
  }

  void _startGameLoop() {
    gameLoopTimer?.cancel();
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 33), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _updateAI();
      _updateProjectiles();
      setState(() {});
    });
  }

  void _updateAI() {
    if (playerHealth <= 0) return;

    int npcGx = npcPx.round().clamp(0, gridSize - 1);
    int npcGy = npcPy.round().clamp(0, gridSize - 1);

    double distToPlayer = sqrt(pow(npcGx - playerX, 2) + pow(npcGy - playerY, 2));

    // --- 1. AI FSM State Machine ---
    if (distToPlayer <= 1.5) {
      npcState = NPCState.attack;
    } else if (distToPlayer <= 5.0) {
      npcState = NPCState.chase;
    } else if (distToPlayer <= 8.0) {
      npcState = NPCState.patrol;
    } else {
      npcState = NPCState.idle;
    }

    // --- 2. Pathfinding & Movement ---
    if (npcState == NPCState.chase) {
      // Calculate A* / Grid Path to player
      currentPath = _findPath(PathNode(npcGx, npcGy), PathNode(playerX, playerY));
      if (currentPath.length > 1) {
        PathNode nextStep = currentPath[1];
        _moveTowards(nextStep.x.toDouble(), nextStep.y.toDouble(), 0.08);
      }
    } else if (npcState == NPCState.patrol) {
      PathNode targetWP = patrolWaypoints[patrolIndex];
      double distWP = sqrt(pow(npcGx - targetWP.x, 2) + pow(npcGy - targetWP.y, 2));
      if (distWP < 0.8) {
        patrolIndex = (patrolIndex + 1) % patrolWaypoints.length;
      }
      currentPath = _findPath(PathNode(npcGx, npcGy), targetWP);
      if (currentPath.length > 1) {
        PathNode nextStep = currentPath[1];
        _moveTowards(nextStep.x.toDouble(), nextStep.y.toDouble(), 0.05);
      }
    } else if (npcState == NPCState.attack) {
      playerHealth = (playerHealth - 1).clamp(0, 100);
      currentPath = [];
    } else {
      currentPath = [];
    }
  }

  void _moveTowards(double tx, double ty, double speed) {
    double dx = tx - npcPx;
    double dy = ty - npcPy;
    double len = sqrt(dx * dx + dy * dy);
    if (len > 0.01) {
      npcPx += (dx / len) * speed;
      npcPy += (dy / len) * speed;
    }
  }

  // Grid A* / BFS Pathfinding (Assignment Requirement 2)
  List<PathNode> _findPath(PathNode start, PathNode target) {
    Queue<List<PathNode>> queue = Queue();
    Set<PathNode> visited = {};

    queue.add([start]);
    visited.add(start);

    List<PathNode> directions = [
      PathNode(0, 1),
      PathNode(0, -1),
      PathNode(1, 0),
      PathNode(-1, 0),
    ];

    while (queue.isNotEmpty) {
      List<PathNode> path = queue.removeFirst();
      PathNode current = path.last;

      if (current.x == target.x && current.y == target.y) {
        return path;
      }

      for (var dir in directions) {
        int nx = current.x + dir.x;
        int ny = current.y + dir.y;

        if (nx >= 0 && nx < gridSize && ny >= 0 && ny < gridSize && !obstacles[nx][ny]) {
          PathNode neighbor = PathNode(nx, ny);
          if (!visited.contains(neighbor)) {
            visited.add(neighbor);
            List<PathNode> newPath = List.from(path)..add(neighbor);
            queue.add(newPath);
          }
        }
      }
    }

    return [start];
  }

  void _updateProjectiles() {
    for (var b in bulletPool.activeProjectiles) {
      b.update();
      // Check collision with NPC
      double dx = b.x - (npcPx * 30 + 15);
      double dy = b.y - (npcPy * 30 + 15);
      if (sqrt(dx * dx + dy * dy) < 20) {
        b.active = false;
        score += 15;
        StorageService.saveHighScore('smart_ai', score);
        // Teleport NPC back to patrol starting point
        npcPx = 1.0;
        npcPy = 1.0;
      } else if (b.x < 0 || b.x > 360 || b.y < 0 || b.y > 360) {
        b.active = false; // Return to pool automatically
      }
    }
  }

  void _shootAt(double targetPx, double targetPy) {
    double startX = playerX * 30.0 + 15.0;
    double startY = playerY * 30.0 + 15.0;
    bulletPool.obtain(startX, startY, targetPx, targetPy);
  }

  void _movePlayer(int dx, int dy) {
    int nx = (playerX + dx).clamp(0, gridSize - 1);
    int ny = (playerY + dy).clamp(0, gridSize - 1);
    if (!obstacles[nx][ny]) {
      setState(() {
        playerX = nx;
        playerY = ny;
      });
    }
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  Color _getStateColor() {
    switch (npcState) {
      case NPCState.idle:
        return Colors.blueAccent;
      case NPCState.patrol:
        return Colors.amberAccent;
      case NPCState.chase:
        return Colors.orangeAccent;
      case NPCState.attack:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Smart AI & Pathfinding",
      onReset: () {
        setState(() {
          playerHealth = 100;
          score = 0;
          npcPx = 1.0;
          npcPy = 1.0;
          npcState = NPCState.idle;
        });
      },
      gameContent: Column(
        children: [
          // HUD Analytics & FSM Debug Bar
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStateColor(), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AI STATE: ${npcState.name.toUpperCase()}",
                        style: GoogleFonts.outfit(
                            color: _getStateColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                        "Pathfinding: A* Grid | Active Bullets: ${bulletPool.activeCount}/${bulletPool.totalCapacity}",
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("SCORE: $score",
                        style: GoogleFonts.outfit(
                            color: Colors.yellowAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text("HP: $playerHealth%",
                        style: GoogleFonts.outfit(
                            color: playerHealth > 30
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // 2D Grid Canvas
          Center(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                children: [
                  // Grid tiles & obstacles
                  ...List.generate(gridSize * gridSize, (index) {
                    int x = index % gridSize;
                    int y = index ~/ gridSize;
                    bool isObs = obstacles[x][y];
                    bool isPathNode = currentPath.any((p) => p.x == x && p.y == y);
                    return Positioned(
                      left: x * 30.0,
                      top: y * 30.0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isObs
                              ? Colors.purple.shade900
                              : isPathNode
                                  ? _getStateColor().withValues(alpha: 0.25)
                                  : Colors.transparent,
                          border: Border.all(color: Colors.white10, width: 0.5),
                        ),
                      ),
                    );
                  }),

                  // Path visualization lines/dots
                  ...currentPath.map((p) => Positioned(
                        left: p.x * 30.0 + 12,
                        top: p.y * 30.0 + 12,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getStateColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),

                  // Active Bullets (from Object Pool)
                  ...bulletPool.activeProjectiles.map((b) => Positioned(
                        left: b.x - 4,
                        top: b.y - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.cyanAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),

                  // Player Entity
                  Positioned(
                    left: playerX * 30.0 + 3,
                    top: playerY * 30.0 + 3,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.greenAccent, blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.person, size: 16, color: Colors.black),
                    ),
                  ),

                  // NPC AI Entity
                  Positioned(
                    left: npcPx * 30.0 + 3,
                    top: npcPy * 30.0 + 3,
                    child: GestureDetector(
                      onTap: () => _shootAt(npcPx * 30 + 15, npcPy * 30 + 15),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getStateColor(),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: _getStateColor(), blurRadius: 10)
                          ],
                        ),
                        child: const Icon(Icons.smart_toy,
                            size: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Player Controls & Shooting Pad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // D-Pad
                Column(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 36),
                        onPressed: () => _movePlayer(0, -1)),
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.arrow_left, color: Colors.white, size: 36),
                            onPressed: () => _movePlayer(-1, 0)),
                        const SizedBox(width: 20),
                        IconButton(
                            icon: const Icon(Icons.arrow_right, color: Colors.white, size: 36),
                            onPressed: () => _movePlayer(1, 0)),
                      ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 36),
                        onPressed: () => _movePlayer(0, 1)),
                  ],
                ),

                // Shoot Button (Triggers Object Pool Allocation)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: () => _shootAt(npcPx * 30 + 15, npcPy * 30 + 15),
                  icon: const Icon(Icons.center_focus_strong),
                  label: Text("SHOOT (POOL)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
