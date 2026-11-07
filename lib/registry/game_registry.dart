import 'package:flutter/material.dart';
import '../widgets/game_logos.dart';
import '../models/game_model.dart';
import '../games/tictactoe_game.dart';
import '../games/snake_game.dart';
import '../games/game_2048.dart';
import '../games/sudoku_game.dart';
import '../games/minesweeper_game.dart';
import '../games/memory_match_game.dart';
import '../games/word_scramble_game.dart';
import '../games/reaction_game.dart';
import '../games/math_quiz_game.dart';
import '../games/bird_game.dart';
import '../games/brick_breaker.dart';
import '../games/space_shooter.dart';
import '../games/block_puzzle.dart';
import '../games/connect_four.dart';
import '../games/dots_and_boxes_game.dart';
import '../games/classic_ludo_game.dart';
import '../games/air_hockey_game.dart';
import '../games/chess_game.dart';
import '../games/pinball_game.dart';
import '../games/solitaire_game.dart';
import '../games/word_search_game.dart';
import '../games/jigsaw_puzzle_game.dart';
import '../games/tower_defender_game.dart';
import '../games/tank_wars_game.dart';
import '../games/thumb_fighter_game.dart';
import '../games/racing_blocks_game.dart';
import '../games/othello_game.dart';
import '../games/go_fish_game.dart';
import '../games/tic_tac_toe_3d_game.dart';

import '../games/rock_paper_scissors_game.dart';
import '../games/tug_of_war_game.dart';
import '../games/spin_the_wheel_game.dart';
import '../games/dice_roller_game.dart';
import '../games/number_guesser_game.dart';
import '../games/truth_or_dare_game.dart';
import '../games/hangman_game.dart';
import '../games/finger_battle_game.dart';
import '../games/tap_the_color_game.dart';
import '../games/pong_game.dart';
import '../games/typing_tutor_game.dart';
import '../games/checkers_game.dart';
import '../games/battleship_game.dart';
import '../games/endless_runner_game.dart';
import '../games/match3_game.dart';
import '../games/fruit_slasher_game.dart';
import '../games/maze_solver_game.dart';
import '../games/smart_ai_game.dart';

class GameRegistry {
  static List<Game> getGames() {
    return [
      Game(
        id: 'smart_ai',
        title: 'Smart AI & Pathfinding',
        description: 'Demonstrates FSM states (Idle, Patrol, Chase, Attack) & A* Grid Pathfinding.',
        icon: Icons.smart_toy,
        category: GameCategory.arcade,
        mode: GameMode.singlePlayer,
        themeColor: Colors.orangeAccent,
        screenBuilder: (context) => const SmartAIGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'smart_ai', themeColor: Colors.orangeAccent),
      ),
      Game(
        id: 'tictactoe',
        title: 'Tic Tac Toe',
        description: 'Classic 3x3 strategy game for two players.',
        icon: Icons.grid_3x3,
        category: GameCategory.classic,
        mode: GameMode.multiPlayer,
        themeColor: Colors.blueAccent,
        screenBuilder: (context) => const TicTacToeGame(),
        imagePath: 'assets/logos/tictactoe_logo_1774899883582.png',
        logoBuilder: (context) => const GameLogo(gameId: 'tictactoe', themeColor: Colors.blueAccent),
      ),
      Game(
        id: 'snake',
        title: 'Snake',
        description: 'Eat the food and grow longer without hitting walls or yourself.',
        icon: Icons.gesture,
        category: GameCategory.arcade,
        themeColor: Colors.greenAccent,
        screenBuilder: (context) => const SnakeGame(),
        imagePath: 'assets/logos/snake_logo_1774899899333.png',
        logoBuilder: (context) => const GameLogo(gameId: 'snake', themeColor: Colors.greenAccent),
      ),
      Game(
        id: '2048',
        title: '2048',
        description: 'Swipe to combine numeric tiles and reach 2048!',
        icon: Icons.grid_on,
        category: GameCategory.puzzle,
        themeColor: Colors.orangeAccent,
        screenBuilder: (context) => const Game2048(),
        imagePath: 'assets/logos/game_2048_logo_1774899942173.png',
        logoBuilder: (context) => const GameLogo(gameId: '2048', themeColor: Colors.orangeAccent),
      ),
      Game(
        id: 'sudoku',
        title: 'Sudoku',
        description: 'Classic number placing logic puzzle.',
        icon: Icons.apps,
        category: GameCategory.puzzle,
        themeColor: Colors.purpleAccent,
        screenBuilder: (context) => const SudokuGame(),
        imagePath: 'assets/logos/sudoku_logo_1774899961455.png',
        logoBuilder: (context) => const GameLogo(gameId: 'sudoku', themeColor: Colors.purpleAccent),
      ),
      Game(
        id: 'minesweeper',
        title: 'Minesweeper',
        description: 'Find all hidden mines without setting them off.',
        icon: Icons.dangerous,
        category: GameCategory.puzzle,
        themeColor: Colors.redAccent,
        screenBuilder: (context) => const MinesweeperGame(),
        imagePath: 'assets/logos/minesweeper_logo_1774900091532.png',
        logoBuilder: (context) => const GameLogo(gameId: 'minesweeper', themeColor: Colors.redAccent),
      ),
      Game(
        id: 'memorymatch',
        title: 'Memory Match',
        description: 'Test your memory by finding matching pairs.',
        icon: Icons.memory,
        category: GameCategory.brain,
        themeColor: Colors.cyanAccent,
        screenBuilder: (context) => const MemoryMatchGame(),
        imagePath: 'assets/logos/memorymatch_logo_1774900106964.png',
        logoBuilder: (context) => const GameLogo(gameId: 'memorymatch', themeColor: Colors.cyanAccent),
      ),
      Game(
        id: 'bird',
        title: 'Flappy Bird',
        description: 'Tap to fly and avoid the green pipes.',
        icon: Icons.flutter_dash,
        category: GameCategory.arcade,
        themeColor: Colors.yellowAccent,
        screenBuilder: (context) => const BirdGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'bird', themeColor: Colors.yellowAccent),
      ),
      Game(
        id: 'brick_breaker',
        title: 'Brick Breaker',
        description: 'Destroy all the bricks with your ball and paddle.',
        icon: Icons.border_all,
        category: GameCategory.arcade,
        themeColor: Colors.purpleAccent,
        screenBuilder: (context) => const BrickBreakerGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'brick_breaker', themeColor: Colors.purpleAccent),
      ),
      Game(
        id: 'space_shooter',
        title: 'Space Shooter',
        description: 'Defend the galaxy from waves of invaders.',
        icon: Icons.rocket_launch,
        category: GameCategory.arcade,
        themeColor: Colors.blueAccent,
        screenBuilder: (context) => const SpaceShooterGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'space_shooter', themeColor: Colors.blueAccent),
      ),
      Game(
        id: 'block_puzzle',
        title: 'Block Puzzle',
        description: 'Drag and drop blocks to clear lines.',
        icon: Icons.extension,
        category: GameCategory.puzzle,
        themeColor: Colors.orangeAccent,
        screenBuilder: (context) => const BlockPuzzleGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'block_puzzle', themeColor: Colors.orangeAccent),
      ),
      Game(
        id: 'connect_four',
        title: 'Connect Four',
        description: 'Get four pieces in a row to win.',
        icon: Icons.radio_button_checked,
        category: GameCategory.classic,
        mode: GameMode.multiPlayer,
        themeColor: Colors.redAccent,
        screenBuilder: (context) => const ConnectFourGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'connect_four', themeColor: Colors.redAccent),
      ),
      Game(
        id: 'wordscramble',
        title: 'Word Scramble',
        description: 'Unscramble the letters to find the word.',
        icon: Icons.spellcheck,
        category: GameCategory.brain,
        themeColor: Colors.indigoAccent,
        screenBuilder: (context) => const WordScrambleGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'wordscramble', themeColor: Colors.indigoAccent),
      ),
      Game(
        id: 'reaction',
        title: 'Reaction Test',
        description: 'How fast can you tap when it turns green?',
        icon: Icons.timer,
        category: GameCategory.brain,
        themeColor: Colors.limeAccent,
        screenBuilder: (context) => const ReactionGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'reaction', themeColor: Colors.limeAccent),
      ),
      Game(
        id: 'mathquiz',
        title: 'Math Quiz',
        description: 'Solve fast math problems to score high.',
        icon: Icons.calculate,
        category: GameCategory.brain,
        themeColor: Colors.tealAccent,
        screenBuilder: (context) => const MathQuizGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'mathquiz', themeColor: Colors.tealAccent),
      ),
      Game(
        id: 'dots_and_boxes',
        title: 'Dots & Boxes',
        description: 'Connect dots to capture boxes.',
        icon: Icons.border_outer,
        category: GameCategory.puzzle,
        mode: GameMode.multiPlayer,
        themeColor: Colors.deepPurpleAccent,
        screenBuilder: (context) => const DotsAndBoxesGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'dots_and_boxes', themeColor: Colors.deepPurpleAccent),
      ),
      Game(
        id: 'classic_ludo',
        title: 'Classic Ludo',
        description: 'Authentic 4-Player Ludo Board.',
        icon: Icons.casino,
        category: GameCategory.classic,
        mode: GameMode.multiPlayer,
        themeColor: Colors.redAccent,
        screenBuilder: (context) => const ClassicLudoGame(),
        logoBuilder: (context) => const GameLogo(gameId: 'classic_ludo', themeColor: Colors.redAccent),
      ),
      // --- 11 New Single Player Games ---
      Game(id: 'solitaire', title: 'Solitaire', description: 'Classic card game.', icon: Icons.style, category: GameCategory.casual, mode: GameMode.singlePlayer, themeColor: Colors.teal, screenBuilder: (c) => const SolitaireGame(), logoBuilder: (c) => const GameLogo(gameId: 'solitaire', themeColor: Colors.teal)),
      Game(id: 'tap_color', title: 'Tap The Color', description: 'Tap the correct color fast.', icon: Icons.touch_app, category: GameCategory.brain, mode: GameMode.singlePlayer, themeColor: Colors.purpleAccent, screenBuilder: (c) => const TapTheColorGame(), logoBuilder: (c) => const GameLogo(gameId: 'tap_color', themeColor: Colors.purpleAccent)),
      Game(id: 'word_search', title: 'Word Search', description: 'Find hidden words.', icon: Icons.search, category: GameCategory.brain, mode: GameMode.singlePlayer, themeColor: Colors.orange, screenBuilder: (c) => const WordSearchGame(), logoBuilder: (c) => const GameLogo(gameId: 'word_search', themeColor: Colors.orange)),
      Game(id: 'jigsaw_puzzle', title: 'Jigsaw Puzzle', description: 'Solve the picture puzzle.', icon: Icons.extension, category: GameCategory.puzzle, mode: GameMode.singlePlayer, themeColor: Colors.blueGrey, screenBuilder: (c) => const JigsawPuzzleGame(), logoBuilder: (c) => const GameLogo(gameId: 'jigsaw_puzzle', themeColor: Colors.blueGrey)),
      Game(id: 'tower_defender', title: 'Tower Defender', description: 'Defend your base.', icon: Icons.security, category: GameCategory.arcade, mode: GameMode.singlePlayer, themeColor: Colors.red, screenBuilder: (c) => const TowerDefenderGame(), logoBuilder: (c) => const GameLogo(gameId: 'tower_defender', themeColor: Colors.red)),
      Game(id: 'typing_tutor', title: 'Typing Tutor', description: 'Type words quickly.', icon: Icons.keyboard, category: GameCategory.brain, mode: GameMode.singlePlayer, themeColor: Colors.lightBlue, screenBuilder: (c) => const TypingTutorGame(), logoBuilder: (c) => const GameLogo(gameId: 'typing_tutor', themeColor: Colors.lightBlue)),
      Game(id: 'match_3', title: 'Match 3', description: 'Match 3 similar items.', icon: Icons.dashboard, category: GameCategory.puzzle, mode: GameMode.singlePlayer, themeColor: Colors.pinkAccent, screenBuilder: (c) => const Match3Game(), logoBuilder: (c) => const GameLogo(gameId: 'match_3', themeColor: Colors.pinkAccent)),
      Game(id: 'pinball', title: 'Pinball', description: 'Keep the ball bouncing.', icon: Icons.sports_baseball, category: GameCategory.arcade, mode: GameMode.singlePlayer, themeColor: Colors.yellow, screenBuilder: (c) => const PinballGame(), logoBuilder: (c) => const GameLogo(gameId: 'pinball', themeColor: Colors.yellow)),
      Game(id: 'endless_runner', title: 'Endless Runner', description: 'Run as far as you can.', icon: Icons.directions_run, category: GameCategory.arcade, mode: GameMode.singlePlayer, themeColor: Colors.green, screenBuilder: (c) => const EndlessRunnerGame(), logoBuilder: (c) => const GameLogo(gameId: 'endless_runner', themeColor: Colors.green)),
      Game(id: 'maze_solver', title: 'Maze Solver', description: 'Find your way out.', icon: Icons.timeline, category: GameCategory.puzzle, mode: GameMode.singlePlayer, themeColor: Colors.indigo, screenBuilder: (c) => const MazeSolverGame(), logoBuilder: (c) => const GameLogo(gameId: 'maze_solver', themeColor: Colors.indigo)),
      Game(id: 'fruit_slasher', title: 'Fruit Slasher', description: 'Slice flying fruits.', icon: Icons.restaurant, category: GameCategory.arcade, mode: GameMode.singlePlayer, themeColor: Colors.deepOrange, screenBuilder: (c) => const FruitSlasherGame(), logoBuilder: (c) => const GameLogo(gameId: 'fruit_slasher', themeColor: Colors.deepOrange)),
      
      // --- 19 New Multi Player Games ---
      Game(id: 'pong', title: 'Pong', description: 'Classic table tennis game.', icon: Icons.sports_tennis, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.lightGreen, screenBuilder: (c) => const PongGame(), logoBuilder: (c) => const GameLogo(gameId: 'pong', themeColor: Colors.lightGreen)),
      Game(id: 'air_hockey', title: 'Air Hockey', description: 'Defend your goal.', icon: Icons.sports_hockey, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.blue.shade300, screenBuilder: (c) => const AirHockeyGame(), logoBuilder: (c) => GameLogo(gameId: 'air_hockey', themeColor: Colors.blue.shade300)),
      Game(id: 'rps', title: 'Rock Paper Scissors', description: 'Test your luck and mind reading.', icon: Icons.back_hand, category: GameCategory.casual, mode: GameMode.multiPlayer, themeColor: Colors.deepPurple, screenBuilder: (c) => const RockPaperScissorsGame(), logoBuilder: (c) => const GameLogo(gameId: 'rps', themeColor: Colors.deepPurple)),
      Game(id: 'tug_of_war', title: 'Tug of War', description: 'Tap as fast as you can.', icon: Icons.compare_arrows, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.redAccent, screenBuilder: (c) => const TugOfWarGame(), logoBuilder: (c) => const GameLogo(gameId: 'tug_of_war', themeColor: Colors.redAccent)),
      Game(id: 'spin_the_wheel', title: 'Spin The Wheel', description: 'Leave it to chance.', icon: Icons.autorenew, category: GameCategory.casual, mode: GameMode.multiPlayer, themeColor: Colors.amber, screenBuilder: (c) => const SpinTheWheelGame(), logoBuilder: (c) => const GameLogo(gameId: 'spin_the_wheel', themeColor: Colors.amber)),
      Game(id: 'dice_roller', title: 'Dice Roller', description: 'Higher roll wins.', icon: Icons.casino, category: GameCategory.casual, mode: GameMode.multiPlayer, themeColor: Colors.grey, screenBuilder: (c) => const DiceRollerGame(), logoBuilder: (c) => const GameLogo(gameId: 'dice_roller', themeColor: Colors.grey)),
      Game(id: 'checkers', title: 'Checkers', description: 'Classic board game.', icon: Icons.grid_on, category: GameCategory.classic, mode: GameMode.multiPlayer, themeColor: Colors.brown, screenBuilder: (c) => const CheckersGame(), logoBuilder: (c) => const GameLogo(gameId: 'checkers', themeColor: Colors.brown)),
      Game(id: 'chess', title: 'Chess', description: 'Ultimate strategy game.', icon: Icons.sports_score, category: GameCategory.classic, mode: GameMode.multiPlayer, themeColor: Colors.black54, screenBuilder: (c) => const ChessGame(), logoBuilder: (c) => const GameLogo(gameId: 'chess', themeColor: Colors.black54)),
      Game(id: 'battleship', title: 'Battleship', description: 'Sink enemy ships.', icon: Icons.directions_boat, category: GameCategory.classic, mode: GameMode.multiPlayer, themeColor: Colors.blueGrey.shade700, screenBuilder: (c) => const BattleshipGame(), logoBuilder: (c) => GameLogo(gameId: 'battleship', themeColor: Colors.blueGrey.shade700)),
      Game(id: 'truth_or_dare', title: 'Truth or Dare', description: 'Fun party game.', icon: Icons.help_outline, category: GameCategory.casual, mode: GameMode.multiPlayer, themeColor: Colors.pink, screenBuilder: (c) => const TruthOrDareGame(), logoBuilder: (c) => const GameLogo(gameId: 'truth_or_dare', themeColor: Colors.pink)),
      Game(id: 'hangman', title: 'Hangman', description: 'Guess the word together.', icon: Icons.sentiment_dissatisfied, category: GameCategory.brain, mode: GameMode.multiPlayer, themeColor: Colors.cyan, screenBuilder: (c) => const HangmanGame(), logoBuilder: (c) => const GameLogo(gameId: 'hangman', themeColor: Colors.cyan)),
      Game(id: 'number_guesser', title: 'Number Guesser', description: 'Guess the hidden number.', icon: Icons.format_list_numbered, category: GameCategory.brain, mode: GameMode.multiPlayer, themeColor: Colors.tealAccent, screenBuilder: (c) => const NumberGuesserGame(), logoBuilder: (c) => const GameLogo(gameId: 'number_guesser', themeColor: Colors.tealAccent)),
      Game(id: 'finger_battle', title: 'Finger Battle', description: 'Push your side to victory.', icon: Icons.touch_app, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.orangeAccent, screenBuilder: (c) => const FingerBattleGame(), logoBuilder: (c) => const GameLogo(gameId: 'finger_battle', themeColor: Colors.orangeAccent)),
      Game(id: 'tank_wars', title: 'Tank Wars', description: 'Destroy the enemy tank.', icon: Icons.military_tech, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.green.shade800, screenBuilder: (c) => const TankWarsGame(), logoBuilder: (c) => GameLogo(gameId: 'tank_wars', themeColor: Colors.green.shade800)),
      Game(id: 'thumb_fighter', title: 'Thumb Fighter', description: 'Pin their thumb down.', icon: Icons.thumb_up, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.red.shade300, screenBuilder: (c) => const ThumbFighterGame(), logoBuilder: (c) => GameLogo(gameId: 'thumb_fighter', themeColor: Colors.red.shade300)),
      Game(id: 'racing_blocks', title: 'Racing Blocks', description: 'First to the finish line.', icon: Icons.sports_score, category: GameCategory.arcade, mode: GameMode.multiPlayer, themeColor: Colors.amberAccent, screenBuilder: (c) => const RacingBlocksGame(), logoBuilder: (c) => const GameLogo(gameId: 'racing_blocks', themeColor: Colors.amberAccent)),
      Game(id: 'othello', title: 'Othello', description: 'Flip the chips.', icon: Icons.radio_button_checked, category: GameCategory.classic, mode: GameMode.multiPlayer, themeColor: Colors.lightGreenAccent, screenBuilder: (c) => const OthelloGame(), logoBuilder: (c) => const GameLogo(gameId: 'othello', themeColor: Colors.lightGreenAccent)),
      Game(id: 'go_fish', title: 'Go Fish', description: 'Collect 4 of a kind.', icon: Icons.catching_pokemon, category: GameCategory.casual, mode: GameMode.multiPlayer, themeColor: Colors.deepPurple, screenBuilder: (c) => const GoFishGame(), logoBuilder: (c) => const GameLogo(gameId: 'go_fish', themeColor: Colors.deepPurple)),
      Game(id: 'tic_tac_toe_3d', title: 'Tic Tac Toe 3D', description: '3D Version of Tic Tac Toe.', icon: Icons.view_in_ar, category: GameCategory.classic, mode: GameMode.multiPlayer, themeColor: Colors.blueAccent.shade700, screenBuilder: (c) => const TicTacToe3DGame(), logoBuilder: (c) => GameLogo(gameId: 'tic_tac_toe_3d', themeColor: Colors.blueAccent.shade700)),
    ];
  }
}

