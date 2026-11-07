# fsm_game_ai 🤖

A type-safe Finite State Machine (FSM) and A* 2D Grid Pathfinding library for Flutter and Dart games.

## Features
- **Generic StateMachine<TState, TContext>**: Clean state management with `onEnter`, `onUpdate`, and `onExit` lifecycle callbacks.
- **AStarPathfinder**: High-performance A* shortest path search algorithm for obstacle grids, supporting both 4-directional and 8-directional diagonal movement.

## Quick Start

```dart
import 'package:fsm_game_ai/fsm_game_ai.dart';

// A* Grid Pathfinding
final pathfinder = AStarPathfinder(
  width: 20,
  height: 20,
  obstacles: {Point(5, 5), Point(5, 6)},
);

final path = pathfinder.findPath(Point(0, 0), Point(10, 10));
```
