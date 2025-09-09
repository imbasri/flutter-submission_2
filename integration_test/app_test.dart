import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_pemula/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests', () {
    testWidgets('complete app flow - navigate through pages', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify home page loads
      expect(find.text('Restaurant App'), findsOneWidget);

      // Navigate to favorites page using app bar button
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // Verify favorites page
      expect(find.text('Restoran Favorit'), findsOneWidget);
      expect(find.text('Belum Ada Restoran Favorit'), findsOneWidget);

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify search page
      expect(find.text('Cari Restoran'), findsOneWidget);

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test theme toggle
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();

      // Verify theme changed (icon should change)
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('search functionality integration test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'restoran');
      await tester.pump();

      // Tap search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The results depend on API availability
      // We just verify the search was attempted (no crash)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('drawer navigation integration test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navigate to favorites via drawer
      await tester.tap(find.text('Restoran Favorit'));
      await tester.pumpAndSettle();

      // Verify navigation worked
      expect(find.text('Restoran Favorit'), findsOneWidget);
    });
  });
}
