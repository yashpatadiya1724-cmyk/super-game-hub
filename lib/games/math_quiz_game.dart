import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class MathQuizGame extends StatefulWidget {
  const MathQuizGame({super.key});

  @override
  State<MathQuizGame> createState() => _MathQuizGameState();
}

class _MathQuizGameState extends State<MathQuizGame> {
  late int num1;
  late int num2;
  String operator = '+';
  late int correctAnswer;
  late List<int> options;
  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      num1 = Random().nextInt(20) + 1;
      num2 = Random().nextInt(20) + 1;
      List<String> ops = ['+', '-', '*'];
      operator = ops[Random().nextInt(operator == '*' ? 2 : 3)]; // Limit multiplications slightly

      switch (operator) {
        case '+': correctAnswer = num1 + num2; break;
        case '-': correctAnswer = num1 - num2; break;
        case '*': correctAnswer = num1 * num2; break;
      }

      options = [correctAnswer];
      while (options.length < 4) {
        int off = Random().nextInt(10) - 5;
        int opt = correctAnswer + off;
        if (opt != correctAnswer && !options.contains(opt)) options.add(opt);
      }
      options.shuffle();
    });
  }

  void _checkAnswer(int answer) {
    if (answer == correctAnswer) {
      setState(() {
        score++;
        _generateQuestion();
      });
    } else {
      setState(() {
        isGameOver = true;
        StorageService.saveHighScore('mathquiz', score);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Math Quiz",
      onReset: () {
        setState(() {
          score = 0;
          isGameOver = false;
        });
        _generateQuestion();
      },
      gameContent: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Score: $score", style: GoogleFonts.outfit(fontSize: 24, color: Colors.blueAccent)),
            const SizedBox(height: 50),
            if (!isGameOver)
              Text("$num1 $operator $num2 = ?", style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            if (isGameOver)
              Text("GAME OVER!", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 50),
            if (!isGameOver)
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: options.map((opt) => ElevatedButton(
                  onPressed: () => _checkAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    minimumSize: const Size(120, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('$opt', style: GoogleFonts.outfit(fontSize: 24, color: Colors.white)),
                )).toList(),
              ),
            if (isGameOver)
              ElevatedButton(
                onPressed: () => setState(() { score = 0; isGameOver = false; _generateQuestion(); }),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text("Try Again"),
              ),
          ],
        ),
      ),
    );
  }
}
