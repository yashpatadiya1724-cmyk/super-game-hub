import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_game_hub/services/screen_juice_service.dart';
import 'package:super_game_hub/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppTheme Palette & Decoration Unit Tests', () {
    test('AppTheme constants define required blocky aesthetic palette', () {
      expect(AppTheme.background, const Color(0xFF121212));
      expect(AppTheme.surface, const Color(0xFF232527));
      expect(AppTheme.accentArcade, const Color(0xFFE52521));
      expect(AppTheme.accentPuzzle, const Color(0xFF45F3DC));
      expect(AppTheme.accentBrain, const Color(0xFF5CA038));
      expect(AppTheme.accentClassic, const Color(0xFFF9A03F));
      expect(AppTheme.accentCasual, const Color(0xFF8B4513));
    });

    test('AppTheme.blocky decoration creates solid borders and offset shadow', () {
      final decor = AppTheme.blocky(color: Colors.red);
      expect(decor.borderRadius, equals(BorderRadius.circular(12)));
      expect(decor.border, isNotNull);
      expect(decor.boxShadow, isNotNull);
      expect(decor.boxShadow!.length, 1);
      expect(decor.boxShadow![0].offset, const Offset(4, 4));
    });

    test('AppTheme.blocky defaults to surface color and opacity', () {
      final decor = AppTheme.blocky();
      expect(decor.borderRadius, equals(BorderRadius.circular(12)));
      expect(decor.color, equals(AppTheme.surface.withValues(alpha: 0.9)));
    });

    test('AppTheme.categoryGradient generates linear two-stop gradient', () {
      final gradient = AppTheme.categoryGradient(Colors.amber) as LinearGradient;
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
      expect(gradient.colors.length, 2);
    });
  });

  group('ShakeWidget Screen Juice Tests', () {
    testWidgets('ShakeWidget renders child text correctly and triggers shake animation', (tester) async {
      final shakeKey = GlobalKey<ShakeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShakeWidget(
              key: shakeKey,
              duration: const Duration(milliseconds: 200),
              shakeOffset: 6.0,
              child: const Text('Punchy Game Text'),
            ),
          ),
        ),
      );

      expect(find.text('Punchy Game Text'), findsOneWidget);

      // Trigger shake animation
      shakeKey.currentState?.shake();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Punchy Game Text'), findsOneWidget);

      // Finish animation duration
      await tester.pumpAndSettle();
      expect(find.text('Punchy Game Text'), findsOneWidget);
    });
  });
}
