import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_pemula/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple Integration Test', () {
    testWidgets('app starts without crashing', (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for the app to settle with longer timeout
      await tester.pumpAndSettle(const Duration(seconds: 15));
      
      // Additional stability check
      int retries = 5;
      while (retries > 0 && find.byType(MaterialApp).evaluate().isEmpty) {
        await tester.pump(const Duration(seconds: 1));
        retries--;
      }
      
      // Just verify the app doesn't crash
      expect(find.byType(MaterialApp), findsOneWidget);
      
      debugPrint('✅ App started successfully - no crash detected');
    });
  });
}