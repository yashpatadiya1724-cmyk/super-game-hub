import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Record app launch session
    await incrementSessionCount();
  }

  static Future<void> saveHighScore(String gameId, int score) async {
    int currentHighScore = getHighScore(gameId);
    if (score > currentHighScore) {
      await _prefs.setInt('highscore_$gameId', score);
    }
  }

  static int getHighScore(String gameId) {
    return _prefs.getInt('highscore_$gameId') ?? 0;
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
