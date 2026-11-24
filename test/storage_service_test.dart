import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_game_hub/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LeaderboardEntry Model Unit Tests', () {
    test('serializes to JSON format correctly', () {
      final entry = LeaderboardEntry(
        playerName: 'RetroChampion',
        score: 15400,
        date: '2026-11-24',
      );

      final json = entry.toJson();
      expect(json['playerName'], equals('RetroChampion'));
      expect(json['score'], equals(15400));
      expect(json['date'], equals('2026-11-24'));
    });

    test('deserializes from JSON format correctly', () {
      final json = {
        'playerName': 'CyberPlayer',
        'score': 8920,
        'date': '2026-11-20',
      };

      final entry = LeaderboardEntry.fromJson(json);
      expect(entry.playerName, equals('CyberPlayer'));
      expect(entry.score, equals(8920));
      expect(entry.date, equals('2026-11-20'));
    });

    test('handles fallback defaults on empty JSON map', () {
      final entry = LeaderboardEntry.fromJson({});
      expect(entry.playerName, equals('Player'));
      expect(entry.score, equals(0));
      expect(entry.date, equals(''));
    });
  });

  group('StorageService Persistence Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    test('saves and retrieves high score correctly', () async {
      expect(StorageService.getHighScore('pacman'), equals(0));

      await StorageService.saveHighScore('pacman', 500);
      expect(StorageService.getHighScore('pacman'), equals(500));

      // Attempt lower score should not overwrite high score
      await StorageService.saveHighScore('pacman', 300);
      expect(StorageService.getHighScore('pacman'), equals(500));

      // Higher score overwrites
      await StorageService.saveHighScore('pacman', 1200);
      expect(StorageService.getHighScore('pacman'), equals(1200));
    });

    test('records and sorts leaderboard entries by score descending', () async {
      await StorageService.recordLeaderboardEntry('snake', 200, playerName: 'Alice');
      await StorageService.recordLeaderboardEntry('snake', 500, playerName: 'Bob');
      await StorageService.recordLeaderboardEntry('snake', 350, playerName: 'Charlie');

      final leaderboard = StorageService.getLeaderboard('snake');
      expect(leaderboard.length, equals(3));
      expect(leaderboard[0].playerName, equals('Bob'));
      expect(leaderboard[0].score, equals(500));
      expect(leaderboard[1].playerName, equals('Charlie'));
      expect(leaderboard[1].score, equals(350));
      expect(leaderboard[2].playerName, equals('Alice'));
      expect(leaderboard[2].score, equals(200));
    });

    test('caps leaderboard entries to top 10', () async {
      for (int i = 1; i <= 15; i++) {
        await StorageService.recordLeaderboardEntry('tetris', i * 100, playerName: 'Player $i');
      }

      final leaderboard = StorageService.getLeaderboard('tetris');
      expect(leaderboard.length, equals(10));
      expect(leaderboard.first.score, equals(1500));
      expect(leaderboard.last.score, equals(600));
    });
  });
}
