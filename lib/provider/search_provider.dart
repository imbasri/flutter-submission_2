import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';

class SearchProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ApiResult<List<Restaurant>> _searchResult = const ApiEmpty(message: '');
  String _query = '';

  ApiResult<List<Restaurant>> get result => _searchResult;
  String get query => _query;
  Future<void> searchRestaurants(String query) async {
    try {
      _query = query;

      if (query.isEmpty) {
        _searchResult = const ApiEmpty(
          message: 'Masukkan nama restaurant untuk mencari',
        );
        notifyListeners();
        return;
      }
      _searchResult = const ApiLoading();
      notifyListeners();

      final operation = SearchRestaurants(query);

      final apiResult = await _apiService.callApi<RestaurantListResponse>(
        operation,
      );

      _searchResult = switch (apiResult) {
        ApiLoading<RestaurantListResponse>() => const ApiLoading(),

        ApiSuccess<RestaurantListResponse>(:final data) =>
          data.restaurants.isEmpty
              ? ApiEmpty(
                  message: 'Tidak ada restaurant dengan kata kunci "$query"',
                )
              : ApiSuccess(data: data.restaurants),

        ApiFailure<RestaurantListResponse>(:final message) => ApiFailure(
          message: message,
        ),

        ApiEmpty<RestaurantListResponse>(:final message) => ApiEmpty(
          message: message,
        ),
      };
    } catch (e) {
      _searchResult = const ApiFailure(
        message:
            'Terjadi kesalahan saat mencari restaurant. Silakan coba lagi.',
      );
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchResult = const ApiEmpty(message: '');
    _query = '';
    notifyListeners();
  }

  bool get hasResults => _searchResult.isSuccess;

  int get resultCount => hasResults ? _searchResult.dataOrNull!.length : 0;
}
