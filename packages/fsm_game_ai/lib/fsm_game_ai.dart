import 'dart:math';

/// Generic Finite State Machine for Game Entities
class StateMachine<TState, TContext> {
  TState _currentState;
  final TContext context;
  final Map<TState, StateConfig<TState, TContext>> _states = {};

  StateMachine({
    required TState initialState,
    required this.context,
  }) : _currentState = initialState;

  TState get currentState => _currentState;

  /// Register state behavior
  void addState({
    required TState state,
    void Function(TContext context)? onEnter,
    void Function(TContext context, double dt)? onUpdate,
    void Function(TContext context)? onExit,
  }) {
    _states[state] = StateConfig<TState, TContext>(
      onEnter: onEnter,
      onUpdate: onUpdate,
      onExit: onExit,
    );
  }

  /// Transition to new state
  void transitionTo(TState newState) {
    if (newState == _currentState) return;
    _states[_currentState]?.onExit?.call(context);
    _currentState = newState;
    _states[_currentState]?.onEnter?.call(context);
  }

  /// Update loop per tick
  void update(double dt) {
    _states[_currentState]?.onUpdate?.call(context, dt);
  }
}

class StateConfig<TState, TContext> {
  final void Function(TContext context)? onEnter;
  final void Function(TContext context, double dt)? onUpdate;
  final void Function(TContext context)? onExit;

  const StateConfig({this.onEnter, this.onUpdate, this.onExit});
}

/// 2D Grid Coordinate Node
class GridNode {
  final int x;
  final int y;
  double gCost = 0;
  double hCost = 0;
  GridNode? parent;

  GridNode(this.x, this.y);

  double get fCost => gCost + hCost;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridNode && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// High-performance A* (A-Star) Pathfinding Algorithm on a 2D Grid
class AStarPathfinder {
  final int width;
  final int height;
  final Set<Point<int>> obstacles;
  final bool allowDiagonals;

  AStarPathfinder({
    required this.width,
    required this.height,
    required this.obstacles,
    this.allowDiagonals = false,
  });

  /// Finds optimal shortest path from start to target. Returns empty list if no path exists.
  List<Point<int>> findPath(Point<int> start, Point<int> target) {
    if (obstacles.contains(target) || !isWalkable(start.x, start.y)) {
      return [];
    }

    final openSet = <GridNode>[];
    final closedSet = <Point<int>>{};
    final nodeMap = <Point<int>, GridNode>{};

    GridNode getNode(Point<int> p) {
      return nodeMap.putIfAbsent(p, () => GridNode(p.x, p.y));
    }

    final startNode = getNode(start);
    startNode.gCost = 0;
    startNode.hCost = _heuristic(start, target);
    openSet.add(startNode);

    while (openSet.isNotEmpty) {
      // Find node with lowest fCost
      openSet.sort((a, b) => a.fCost.compareTo(b.fCost));
      final current = openSet.removeAt(0);
      final currentPoint = Point(current.x, current.y);

      if (currentPoint == target) {
        return _reconstructPath(current);
      }

      closedSet.add(currentPoint);

      for (final neighborPoint in _getNeighbors(currentPoint)) {
        if (closedSet.contains(neighborPoint)) continue;

        double tentativeGCost = current.gCost + (allowDiagonals ? _distance(currentPoint, neighborPoint) : 1.0);
        final neighbor = getNode(neighborPoint);

        if (!openSet.contains(neighbor) || tentativeGCost < neighbor.gCost) {
          neighbor.parent = current;
          neighbor.gCost = tentativeGCost;
          neighbor.hCost = _heuristic(neighborPoint, target);

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return []; // No path found
  }

  bool isWalkable(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height && !obstacles.contains(Point(x, y));
  }

  List<Point<int>> _getNeighbors(Point<int> p) {
    final neighbors = <Point<int>>[];
    final dirs = [
      const Point(0, -1), // Up
      const Point(0, 1),  // Down
      const Point(-1, 0), // Left
      const Point(1, 0),  // Right
      if (allowDiagonals) ...[
        const Point(-1, -1),
        const Point(1, -1),
        const Point(-1, 1),
        const Point(1, 1),
      ],
    ];

    for (final d in dirs) {
      final nx = p.x + d.x;
      final ny = p.y + d.y;
      if (isWalkable(nx, ny)) {
        neighbors.add(Point(nx, ny));
      }
    }
    return neighbors;
  }

  double _heuristic(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs().toDouble();
  }

  double _distance(Point<int> a, Point<int> b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }

  List<Point<int>> _reconstructPath(GridNode endNode) {
    final path = <Point<int>>[];
    GridNode? current = endNode;
    while (current != null) {
      path.add(Point(current.x, current.y));
      current = current.parent;
    }
    return path.reversed.toList();
  }
}
