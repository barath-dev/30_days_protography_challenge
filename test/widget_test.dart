import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_guide/main.dart';
import 'package:photography_guide/services/user_preferences.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Initialize services
    await UserPreferences.init();
    // We might need to mock LessonManager too if it does file I/O,
    // but let's try without it first or just init it if it's safe.
    // LessonManager.init() loads JSON from assets, which might fail in test environment
    // without proper setup. For now, let's skip LessonManager.init() if possible,
    // but PhotographyGuideApp doesn't seem to depend on it directly for the first frame
    // (except maybe for content loading which happens later).

    // Build our app and trigger a frame.
    await tester.pumpWidget(const PhotographyGuideApp());

    // Verify that the app title or loading screen is present
    // The app starts with AppInitializer which shows a loading screen or error
    expect(find.byType(MaterialApp), findsOneWidget);

    // Allow animations to settle
    await tester.pumpAndSettle();

    // Should be at least one of these screens
    // 1. Loading Screen
    // 2. Difficulty Selection Screen
    // 3. Home Screen
    // 4. Error Screen

    // Just checking if it didn't crash is a good start.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
