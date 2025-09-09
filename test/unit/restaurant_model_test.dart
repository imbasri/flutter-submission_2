import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pemula/data/model/restaurant.dart';

void main() {
  group('Restaurant Model Unit Tests', () {
    test('should create Restaurant from JSON correctly', () {
      // Arrange
      final json = {
        'id': 'test_id',
        'name': 'Test Restaurant',
        'description': 'A great restaurant',
        'pictureId': 'test_picture',
        'city': 'Test City',
        'rating': 4.5,
      };

      // Act
      final restaurant = Restaurant.fromJson(json);

      // Assert
      expect(restaurant.id, equals('test_id'));
      expect(restaurant.name, equals('Test Restaurant'));
      expect(restaurant.description, equals('A great restaurant'));
      expect(restaurant.pictureId, equals('test_picture'));
      expect(restaurant.city, equals('Test City'));
      expect(restaurant.rating, equals(4.5));
    });

    test('should convert Restaurant to JSON correctly', () {
      // Arrange
      final restaurant = Restaurant(
        id: 'test_id',
        name: 'Test Restaurant',
        description: 'A great restaurant',
        pictureId: 'test_picture',
        city: 'Test City',
        rating: 4.5,
      );

      // Act
      final json = restaurant.toJson();

      // Assert
      expect(json['id'], equals('test_id'));
      expect(json['name'], equals('Test Restaurant'));
      expect(json['description'], equals('A great restaurant'));
      expect(json['pictureId'], equals('test_picture'));
      expect(json['city'], equals('Test City'));
      expect(json['rating'], equals(4.5));
    });

    test('should handle missing JSON fields gracefully', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final restaurant = Restaurant.fromJson(json);

      // Assert
      expect(restaurant.id, equals(''));
      expect(restaurant.name, equals(''));
      expect(restaurant.description, equals(''));
      expect(restaurant.pictureId, equals(''));
      expect(restaurant.city, equals(''));
      expect(restaurant.rating, equals(0.0));
    });

    test('should generate correct picture URL', () {
      // Arrange
      final restaurant = Restaurant(
        id: 'test_id',
        name: 'Test Restaurant',
        description: 'A great restaurant',
        pictureId: 'test_picture',
        city: 'Test City',
        rating: 4.5,
      );

      // Act
      final pictureUrl = restaurant.pictureUrl;

      // Assert
      expect(pictureUrl, contains('test_picture'));
      expect(pictureUrl, startsWith('https://'));
    });

    test('should handle non-integer rating values', () {
      // Arrange
      final json = {
        'id': 'test_id',
        'name': 'Test Restaurant',
        'description': 'A great restaurant',
        'pictureId': 'test_picture',
        'city': 'Test City',
        'rating': 4, // Integer instead of double
      };

      // Act
      final restaurant = Restaurant.fromJson(json);

      // Assert
      expect(restaurant.rating, equals(4.0));
      expect(restaurant.rating, isA<double>());
    });
  });

  group('RestaurantListResponse Unit Tests', () {
    test('should create RestaurantListResponse from JSON correctly', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'count': 2,
        'restaurants': [
          {
            'id': 'test_id_1',
            'name': 'Test Restaurant 1',
            'description': 'First restaurant',
            'pictureId': 'test_picture_1',
            'city': 'Test City 1',
            'rating': 4.5,
          },
          {
            'id': 'test_id_2',
            'name': 'Test Restaurant 2',
            'description': 'Second restaurant',
            'pictureId': 'test_picture_2',
            'city': 'Test City 2',
            'rating': 4.0,
          }
        ],
      };

      // Act
      final response = RestaurantListResponse.fromJson(json);

      // Assert
      expect(response.error, isFalse);
      expect(response.message, equals('success'));
      expect(response.count, equals(2));
      expect(response.restaurants.length, equals(2));
      expect(response.restaurants[0].name, equals('Test Restaurant 1'));
      expect(response.restaurants[1].name, equals('Test Restaurant 2'));
    });

    test('should handle empty restaurant list', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'count': 0,
        'restaurants': <Map<String, dynamic>>[],
      };

      // Act
      final response = RestaurantListResponse.fromJson(json);

      // Assert
      expect(response.error, isFalse);
      expect(response.message, equals('success'));
      expect(response.count, equals(0));
      expect(response.restaurants, isEmpty);
    });
  });
}
