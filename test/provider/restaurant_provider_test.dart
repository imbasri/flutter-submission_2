import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_pemula/provider/restaurant_provider.dart';
import 'package:flutter_pemula/data/api/api_service.dart';
import 'package:flutter_pemula/data/model/restaurant.dart';
import 'package:flutter_pemula/utils/api_result.dart';

// Generate mock classes
@GenerateMocks([ApiService])
import 'restaurant_provider_test.mocks.dart';

void main() {
  // Provide dummy values for Mockito
  provideDummy<ApiResult<RestaurantListResponse>>(
    const ApiLoading<RestaurantListResponse>(),
  );
  group('RestaurantProvider Tests', () {
    late RestaurantProvider restaurantProvider;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      restaurantProvider = RestaurantProvider(apiService: mockApiService);
    });

    group('Initial State Tests', () {
      test('should have initial state as ApiLoading', () {
        // Arrange & Act
        final result = restaurantProvider.result;

        // Assert
        expect(result, isA<ApiLoading<List<Restaurant>>>());
      });
    });

    group('Successful API Fetch Tests', () {
      test(
        'should return restaurant list when API call is successful',
        () async {
          // Arrange
          final mockRestaurants = [
            Restaurant(
              id: '1',
              name: 'Test Restaurant 1',
              description: 'Test Description 1',
              pictureId: 'test1',
              city: 'Test City 1',
              rating: 4.5,
            ),
            Restaurant(
              id: '2',
              name: 'Test Restaurant 2',
              description: 'Test Description 2',
              pictureId: 'test2',
              city: 'Test City 2',
              rating: 4.0,
            ),
          ];

          final mockResponse = RestaurantListResponse(
            error: false,
            message: 'success',
            count: 2,
            restaurants: mockRestaurants,
          );

          when(
            mockApiService.callApi<RestaurantListResponse>(any),
          ).thenAnswer((_) async => ApiSuccess(data: mockResponse));

          // Act
          await restaurantProvider.fetchRestaurants();

          // Assert
          expect(
            restaurantProvider.result,
            isA<ApiSuccess<List<Restaurant>>>(),
          );
          final result =
              restaurantProvider.result as ApiSuccess<List<Restaurant>>;
          expect(result.data, equals(mockRestaurants));
          expect(result.data.length, equals(2));
        },
      );

      test('should return ApiEmpty when restaurant list is empty', () async {
        // Arrange
        final mockResponse = RestaurantListResponse(
          error: false,
          message: 'success',
          count: 0,
          restaurants: [],
        );

        when(
          mockApiService.callApi<RestaurantListResponse>(any),
        ).thenAnswer((_) async => ApiSuccess(data: mockResponse));

        // Act
        await restaurantProvider.fetchRestaurants();

        // Assert
        expect(restaurantProvider.result, isA<ApiEmpty<List<Restaurant>>>());
        final result = restaurantProvider.result as ApiEmpty<List<Restaurant>>;
        expect(result.message, equals('Tidak ada restaurant ditemukan'));
      });
    });

    group('Failed API Fetch Tests', () {
      test('should return ApiFailure when API call fails', () async {
        // Arrange
        const errorMessage = 'Network error occurred';
        when(
          mockApiService.callApi<RestaurantListResponse>(any),
        ).thenAnswer((_) async => const ApiFailure(message: errorMessage));

        // Act
        await restaurantProvider.fetchRestaurants();

        // Assert
        expect(restaurantProvider.result, isA<ApiFailure<List<Restaurant>>>());
        final result =
            restaurantProvider.result as ApiFailure<List<Restaurant>>;
        expect(result.message, equals(errorMessage));
      });

      test(
        'should return generic error message when exception is thrown',
        () async {
          // Arrange
          when(
            mockApiService.callApi<RestaurantListResponse>(any),
          ).thenThrow(Exception('Unexpected error'));

          // Act
          await restaurantProvider.fetchRestaurants();

          // Assert
          expect(
            restaurantProvider.result,
            isA<ApiFailure<List<Restaurant>>>(),
          );
          final result =
              restaurantProvider.result as ApiFailure<List<Restaurant>>;
          expect(
            result.message,
            equals(
              'Terjadi kesalahan saat mengambil data restaurant. Silakan coba lagi.',
            ),
          );
        },
      );

      test('should handle SocketException and return connection error', () async {
        // Arrange
        when(mockApiService.callApi<RestaurantListResponse>(any)).thenAnswer(
          (_) async => const ApiFailure(
            message:
                'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet dan coba lagi.',
          ),
        );

        // Act
        await restaurantProvider.fetchRestaurants();

        // Assert
        expect(restaurantProvider.result, isA<ApiFailure<List<Restaurant>>>());
        final result =
            restaurantProvider.result as ApiFailure<List<Restaurant>>;
        expect(result.message, contains('koneksi internet'));
      });
    });

    group('Provider State Changes Tests', () {
      test('should notify listeners when fetching data', () async {
        // Arrange
        var notificationCount = 0;
        restaurantProvider.addListener(() {
          notificationCount++;
        });

        final mockResponse = RestaurantListResponse(
          error: false,
          message: 'success',
          count: 1,
          restaurants: [
            Restaurant(
              id: '1',
              name: 'Test Restaurant',
              description: 'Test Description',
              pictureId: 'test',
              city: 'Test City',
              rating: 4.5,
            ),
          ],
        );

        when(
          mockApiService.callApi<RestaurantListResponse>(any),
        ).thenAnswer((_) async => ApiSuccess(data: mockResponse));

        // Act
        await restaurantProvider.fetchRestaurants();

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should set loading state before making API call', () async {
        // Arrange
        var states = <ApiResult<List<Restaurant>>>[];
        restaurantProvider.addListener(() {
          states.add(restaurantProvider.result);
        });

        final mockResponse = RestaurantListResponse(
          error: false,
          message: 'success',
          count: 0,
          restaurants: [],
        );

        when(mockApiService.callApi<RestaurantListResponse>(any)).thenAnswer((
          _,
        ) async {
          // Add delay to simulate network call
          await Future.delayed(const Duration(milliseconds: 10));
          return ApiSuccess(data: mockResponse);
        });

        // Act
        await restaurantProvider.fetchRestaurants();

        // Assert
        expect(states.first, isA<ApiLoading<List<Restaurant>>>());
        expect(states.last, isA<ApiEmpty<List<Restaurant>>>());
      });
    });
  });
}
