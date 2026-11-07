import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String playerName;
  final int score;
  final String date;

  LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'score': score,
    'date': date,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    playerName: json['playerName'] as String? ?? 'Player',
    score: json['score'] as int? ?? 0,
    date: json['date'] as String? ?? '',
  );
}

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Record app launch session
    await incrementSessionCount();
  }

  static Future<void> saveHighScore(String gameId, int score, {String playerName = 'Player 1'}) async {
    int currentHighScore = getHighScore(gameId);
    if (score > currentHighScore) {
      await _prefs.setInt('highscore_$gameId', score);
    }
    // Record to persistent leaderboard history
    await recordLeaderboardEntry(gameId, score, playerName: playerName);
  }

  static int getHighScore(String gameId) {
    return _prefs.getInt('highscore_$gameId') ?? 0;
  }

  static Future<void> recordLeaderboardEntry(String gameId, int score, {String playerName = 'Player 1'}) async {
    List<LeaderboardEntry> list = getLeaderboard(gameId);
    list.add(LeaderboardEntry(
      playerName: playerName,
      score: score,
      date: DateTime.now().toIso8601String().split('T')[0],
    ));
    list.sort((a, b) => b.score.compareTo(a.score));
    if (list.length > 10) {
      list = list.sublist(0, 10);
    }
    final raw = list.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList('leaderboard_$gameId', raw);
  }

  static List<LeaderboardEntry> getLeaderboard(String gameId) {
    final raw = _prefs.getStringList('leaderboard_$gameId');
    if (raw == null || raw.isEmpty) {
      final high = getHighScore(gameId);
      if (high > 0) {
        return [LeaderboardEntry(playerName: 'Best Record', score: high, date: 'Recent')];
      }
      return [];
    }
    try {
      return raw.map((item) => LeaderboardEntry.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool('is_dark_mode', isDark);
  }

  static bool isDarkMode() {
    return _prefs.getBool('is_dark_mode') ?? true;
  }

  static Future<void> incrementGamePlayed(String gameId) async {
    int count = _prefs.getInt('played_$gameId') ?? 0;
    await _prefs.setInt('played_$gameId', count + 1);
  }

  static int getGamePlayedCount(String gameId) {
    return _prefs.getInt('played_$gameId') ?? 0;
  }

  // --- Assignment Requirement 4: Game Analytics Storage ---
  static Future<void> incrementSessionCount() async {
    int sessions = getSessionCount();
    await _prefs.setInt('total_sessions', sessions + 1);
    await _prefs.setString('last_session_time', DateTime.now().toIso8601String());
  }

  static int getSessionCount() {
    return _prefs.getInt('total_sessions') ?? 1;
  }

  static Future<void> addPlayTime(int seconds) async {
    int current = getTotalPlayTimeSeconds();
    await _prefs.setInt('total_play_time_seconds', current + seconds);
  }

  static int getTotalPlayTimeSeconds() {
    return _prefs.getInt('total_play_time_seconds') ?? 1450; // Initial default for demonstration analytics
  }

  static String getLastSessionTime() {
    return _prefs.getString('last_session_time') ?? DateTime.now().toString().split('.')[0];
  }

  // --- Assignment Requirement 5: Monetization & Store Wallet ---
  static int getCoins() {
    return _prefs.getInt('user_coins') ?? 500;
  }

  static Future<bool> spendCoins(int amount) async {
    int current = getCoins();
    if (current >= amount) {
      await _prefs.setInt('user_coins', current - amount);
      return true;
    }
    return false;
  }

  static Future<void> addCoins(int amount) async {
    int current = getCoins();
    await _prefs.setInt('user_coins', current + amount);
  }

  static bool isItemPurchased(String itemId) {
    return _prefs.getBool('purchased_$itemId') ?? false;
  }

  static Future<void> setItemPurchased(String itemId) async {
    await _prefs.setBool('purchased_$itemId', true);
  }
}
