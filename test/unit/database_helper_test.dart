import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_pemula/data/db/database_helper.dart';
import 'package:flutter_pemula/data/model/restaurant.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Unit Tests', () {
    late DatabaseHelper databaseHelper;
    late Restaurant testRestaurant;

    setUp(() async {
      databaseHelper = DatabaseHelper.instance;
      testRestaurant = Restaurant(
        id: 'test_id_1',
        name: 'Test Restaurant',
        description: 'A test restaurant description',
        pictureId: 'test_picture',
        city: 'Test City',
        rating: 4.5,
      );
      
      // Clear the database before each test
      final favorites = await databaseHelper.getAllFavorites();
      for (final restaurant in favorites) {
        await databaseHelper.deleteFavorite(restaurant.id);
      }
    });

    tearDown(() async {
      // Clear all favorites after each test
      final favorites = await databaseHelper.getAllFavorites();
      for (final restaurant in favorites) {
        await databaseHelper.deleteFavorite(restaurant.id);
      }
    });

    test('should insert and retrieve favorite restaurant', () async {
      // Arrange & Act
      await databaseHelper.insertFavorite(testRestaurant);
      final favorites = await databaseHelper.getAllFavorites();
      
      // Assert
      expect(favorites, isNotEmpty);
      expect(favorites.first.id, equals(testRestaurant.id));
      expect(favorites.first.name, equals(testRestaurant.name));
    });

    test('should check if restaurant is favorite', () async {
      // Arrange
      await databaseHelper.insertFavorite(testRestaurant);
      
      // Act
      final isFavorite = await databaseHelper.isFavorite(testRestaurant.id);
      final isNotFavorite = await databaseHelper.isFavorite('non_existent_id');
      
      // Assert
      expect(isFavorite, isTrue);
      expect(isNotFavorite, isFalse);
    });

    test('should delete favorite restaurant', () async {
      // Arrange
      await databaseHelper.insertFavorite(testRestaurant);
      
      // Act
      await databaseHelper.deleteFavorite(testRestaurant.id);
      final isFavorite = await databaseHelper.isFavorite(testRestaurant.id);
      
      // Assert
      expect(isFavorite, isFalse);
    });

    test('should handle multiple favorites correctly', () async {
      // Arrange
      final restaurant2 = Restaurant(
        id: 'test_id_2',
        name: 'Test Restaurant 2',
        description: 'Second test restaurant',
        pictureId: 'test_picture_2',
        city: 'Test City 2',
        rating: 3.8,
      );

      // Act
      await databaseHelper.insertFavorite(testRestaurant);
      await databaseHelper.insertFavorite(restaurant2);
      final favorites = await databaseHelper.getAllFavorites();
      
      // Assert
      expect(favorites.length, equals(2));
      expect(favorites.map((r) => r.id), contains(testRestaurant.id));
      expect(favorites.map((r) => r.id), contains(restaurant2.id));
    });

    test('should not duplicate favorites when inserting same restaurant', () async {
      // Arrange & Act
      await databaseHelper.insertFavorite(testRestaurant);
      await databaseHelper.insertFavorite(testRestaurant); // Insert same restaurant
      final favorites = await databaseHelper.getAllFavorites();
      
      // Assert
      expect(favorites.length, equals(1));
    });
  });
}
