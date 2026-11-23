import 'package:flutter_test/flutter_test.dart';
import 'package:super_game_hub/models/game_model.dart';
import 'package:super_game_hub/registry/game_registry.dart';

void main() {
  group('GameRegistry & Game Model Verification Suite', () {
    final games = GameRegistry.getGames();

    test('GameRegistry returns comprehensive game suite (40+ games)', () {
      expect(games.length, greaterThanOrEqualTo(40));
    });

    test('Every game has valid non-empty identifiers and metadata', () {
      for (final game in games) {
        expect(game.id.isNotEmpty, isTrue, reason: 'Game ID must not be empty');
        expect(game.title.isNotEmpty, isTrue, reason: 'Game title must not be empty');
        expect(game.description.isNotEmpty, isTrue, reason: 'Game description must not be empty');
        expect(game.themeColor, isNotNull, reason: 'Game themeColor must not be null');
      }
    });

    test('All game IDs are strictly unique without collisions', () {
      final idSet = <String>{};
      for (final game in games) {
        final added = idSet.add(game.id);
        expect(added, isTrue, reason: 'Duplicate game ID detected: ${game.id}');
      }
      expect(idSet.length, equals(games.length));
    });

    test('Core game categories are well-represented', () {
      final categories = games.map((g) => g.category).toSet();
      expect(categories.contains(GameCategory.arcade), isTrue);
      expect(categories.contains(GameCategory.classic), isTrue);
      expect(categories.contains(GameCategory.puzzle), isTrue);
    });
  });
}
