import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screens/game_wrapper.dart';
import '../../services/storage_service.dart';

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({super.key});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  static const List<String> words = [
    'FLUTTER', 'DART', 'WIDGET', 'PROGRAMMING', 'DEVELOPER',
    'ANDROID', 'GAMEHUB', 'PUZZLE', 'ARCADE', 'MOBILE',
    'INTERFACE', 'ALGORITHM', 'COMPUTER', 'INTERNET', 'TECHNOLOGY'
  ];

  late String currentWord;
  late String scrambledWord;
  String userGuess = '';
  int score = 0;
  String feedback = '';

  @override
  void initState() {
    super.initState();
    _nextWord();
  }

  void _nextWord() {
    setState(() {
      currentWord = words[Random().nextInt(words.length)];
      List<String> chars = currentWord.split('')..shuffle();
      scrambledWord = chars.join('');
      if (scrambledWord == currentWord) _nextWord(); // Ensure it is actually scrambled
      userGuess = '';
      feedback = '';
    });
  }

  void _checkGuess() {
    setState(() {
      if (userGuess.toUpperCase() == currentWord) {
        score += 10;
        feedback = "Correct! +10 Points";
        StorageService.saveHighScore('wordscramble', score);
        Future.delayed(const Duration(seconds: 1), _nextWord);
      } else {
        feedback = "Try again!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameWrapper(
      title: "Word Scramble",
      onReset: () {
        setState(() => score = 0);
        _nextWord();
      },
      gameContent: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Score: $score", style: GoogleFonts.outfit(fontSize: 24, color: Colors.blueAccent)),
              const SizedBox(height: 40),
              Text("Unscramble this word:", style: GoogleFonts.outfit(fontSize: 18, color: Colors.white54)),
              const SizedBox(height: 10),
              Text(
                scrambledWord,
                style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white),
              ),
              const SizedBox(height: 40),
              TextField(
                onChanged: (val) => userGuess = val,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 32, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter word...",
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 20),
              Text(feedback, style: GoogleFonts.outfit(color: feedback.contains('Correct') ? Colors.greenAccent : Colors.redAccent)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _checkGuess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Check Guess"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
