import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pemula/provider/favorites_provider.dart';
import 'package:flutter_pemula/provider/theme_provider.dart';
import 'package:flutter_pemula/ui/page/favorites_page.dart';
import 'package:flutter_pemula/data/model/restaurant.dart';

// Fake implementations for testing
class FakeFavoritesProvider extends FavoritesProvider {
  List<Restaurant> _testFavorites = [];
  FavoritesState _testState = FavoritesState.loaded;

  void setTestFavorites(List<Restaurant> favorites) {
    _testFavorites = favorites;
  }

  void setTestState(FavoritesState state) {
    _testState = state;
  }

  @override
  List<Restaurant> get favorites => _testFavorites;

  @override
  FavoritesState get state => _testState;

  @override
  String get message => '';

  @override
  Future<void> loadFavorites() async {
    // Do nothing for tests
  }
}

class FakeThemeProvider extends ThemeProvider {
  bool _testIsDarkMode = false;
  final bool _testIsInitialized = true;

  void setTestDarkMode(bool isDark) {
    _testIsDarkMode = isDark;
  }

  @override
  bool get isDarkMode => _testIsDarkMode;

  @override
  bool get isInitialized => _testIsInitialized;

  @override
  Future<void> toggleTheme() async {
    _testIsDarkMode = !_testIsDarkMode;
    notifyListeners();
  }
}

void main() {
  group('FavoritesPage Widget Tests', () {
    late FakeFavoritesProvider fakeFavoritesProvider;
    late FakeThemeProvider fakeThemeProvider;

    setUp(() {
      fakeFavoritesProvider = FakeFavoritesProvider();
      fakeThemeProvider = FakeThemeProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoritesProvider>.value(
            value: fakeFavoritesProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(value: fakeThemeProvider),
        ],
        child: const MaterialApp(home: FavoritesPage()),
      );
    }

    testWidgets('should display empty state when no favorites', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Belum Ada Restoran Favorit'), findsOneWidget);
      expect(
        find.text('Tambahkan restoran ke favorit untuk melihatnya di sini'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display app bar with title and theme toggle', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Restoran Favorit'), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('should toggle theme when theme button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final initialIsDark = fakeThemeProvider.isDarkMode;

      // Act
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      // Assert
      expect(fakeThemeProvider.isDarkMode, !initialIsDark);
    });

    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Arrange
      fakeFavoritesProvider.setTestState(FavoritesState.loading);
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should build without errors', (WidgetTester tester) async {
      // Act & Assert
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(FavoritesPage), findsOneWidget);
    });
  });
}
