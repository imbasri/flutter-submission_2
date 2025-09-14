import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService;
  ApiResult<List<Restaurant>> _restaurantResult = const ApiLoading();

  // Constructor with optional injected ApiService for testing
  RestaurantProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  ApiResult<List<Restaurant>> get result => _restaurantResult;
  Future<void> fetchRestaurants() async {
    try {
      _restaurantResult = const ApiLoading();
      notifyListeners();

      const operation = GetAllRestaurants();

      final apiResult = await _apiService.callApi<RestaurantListResponse>(
        operation,
      );

      _restaurantResult = switch (apiResult) {
        ApiLoading<RestaurantListResponse>() => const ApiLoading(),

        ApiSuccess<RestaurantListResponse>(:final data) =>
          data.restaurants.isEmpty
              ? const ApiEmpty(message: 'Tidak ada restaurant ditemukan')
              : ApiSuccess(data: data.restaurants),

        ApiFailure<RestaurantListResponse>(:final message) => ApiFailure(
          message: message,
        ),

        ApiEmpty<RestaurantListResponse>(:final message) => ApiEmpty(
          message: message,
        ),
      };
    } catch (e) {
      _restaurantResult = const ApiFailure(
        message:
            'Terjadi kesalahan saat mengambil data restaurant. Silakan coba lagi.',
      );
    }

    notifyListeners();
  }

  Future<void> searchRestaurants(String query) async {
    try {
      _restaurantResult = const ApiLoading();
      notifyListeners();

      final operation = SearchRestaurants(query);

      final apiResult = await _apiService.callApi<RestaurantListResponse>(
        operation,
      );

      _restaurantResult = switch (apiResult) {
        ApiLoading() => const ApiLoading(),
        ApiSuccess(:final data) =>
          data.restaurants.isEmpty
              ? ApiEmpty(message: 'Tidak ada hasil untuk "$query"')
              : ApiSuccess(data: data.restaurants),
        ApiFailure(:final message) => ApiFailure(message: message),
        ApiEmpty(:final message) => ApiEmpty(message: message),
      };
    } catch (e) {
      _restaurantResult = const ApiFailure(
        message:
            'Terjadi kesalahan saat mencari restaurant. Silakan coba lagi.',
      );
    }

    notifyListeners();
  }
}
