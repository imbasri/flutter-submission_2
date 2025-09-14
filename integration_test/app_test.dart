import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_pemula/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Restaurant App Integration Tests - Cross Platform', () {
    // Helper functions
    bool isWeb() => kIsWeb;
    bool isMobile() => !kIsWeb;

    Duration getWaitDuration(int seconds) {
      return Duration(seconds: isWeb() ? seconds + 2 : seconds);
    }

    Future<void> initializeApp(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(getWaitDuration(5));
      
      // Stability check
      int retries = 3;
      while (retries > 0 && find.byType(MaterialApp).evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 500));
        retries--;
      }
      
      if (isWeb()) {
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pumpAndSettle();
      }
    }

    Future<void> navigateBack(WidgetTester tester) async {
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle(getWaitDuration(2));
      }
    }

    testWidgets('app initialization and basic UI', (WidgetTester tester) async {
      await initializeApp(tester);

      // Verify core app structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      debugPrint('✅ ${isWeb() ? "Web" : "Mobile"} - Basic UI verified');
    });

    testWidgets('navigation flow test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Test favorites navigation
      final favoriteIcon = find.byIcon(Icons.favorite);
      if (favoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcon);
        await tester.pumpAndSettle(getWaitDuration(3));
        expect(find.byType(Scaffold), findsWidgets);
        await navigateBack(tester);
      }

      // Test search navigation
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pumpAndSettle(getWaitDuration(3));
        expect(find.byType(Scaffold), findsWidgets);
        await navigateBack(tester);
      }

      debugPrint('✅ ${isWeb() ? "Web" : "Mobile"} - Navigation flow completed');
    });

    testWidgets('responsive layout and drawer', (WidgetTester tester) async {
      await initializeApp(tester);

      final view = tester.view;
      final size = view.physicalSize / view.devicePixelRatio;
      debugPrint('📱 Screen: ${size.width.toInt()}x${size.height.toInt()}');

      // Test drawer on mobile or small screens
      if (isMobile() || (isWeb() && size.width < 800)) {
        final menuIcon = find.byIcon(Icons.menu);
        if (menuIcon.evaluate().isNotEmpty) {
          await tester.tap(menuIcon);
          await tester.pumpAndSettle(getWaitDuration(2));
          
          // Close drawer
          await tester.tapAt(const Offset(400, 300));
          await tester.pumpAndSettle(getWaitDuration(1));
        }
      }

      debugPrint('✅ ${isWeb() ? "Web" : "Mobile"} - Responsive layout verified');
    });

    testWidgets('app stability test', (WidgetTester tester) async {
      await initializeApp(tester);

      // Rapid navigation test
      for (int i = 0; i < 3; i++) {
        final searchIcon = find.byIcon(Icons.search);
        if (searchIcon.evaluate().isNotEmpty) {
          await tester.tap(searchIcon);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await navigateBack(tester);
        }
      }

      // Verify stability
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);

      debugPrint('✅ ${isWeb() ? "Web" : "Mobile"} - Stability test passed');
    });
  });
}
