import 'package:flutter/material.dart';

enum GameCategory {
  puzzle,
  arcade,
  brain,
  classic,
  casual,
}

enum GameMode {
  singlePlayer,
  multiPlayer,
}

class Game {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final GameCategory category;
  final GameMode mode;
  final WidgetBuilder screenBuilder;
  final Color themeColor;
  final String? imagePath;
  final Widget Function(BuildContext)? logoBuilder;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.mode = GameMode.singlePlayer,
    required this.screenBuilder,
    required this.themeColor,
    this.imagePath,
    this.logoBuilder,
  });
}
