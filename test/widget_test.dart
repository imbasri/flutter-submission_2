// Restaurant App Widget Tests
//
// Basic widget tests for the Restaurant App to ensure
// main components render correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pemula/main.dart';

void main() {
  testWidgets('Restaurant App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Basic pump to trigger build
    await tester.pump();

    // Verify that the app builds successfully with MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should have basic widget structure', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Multiple pumps to allow for loading states
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify basic structure exists - should have MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
