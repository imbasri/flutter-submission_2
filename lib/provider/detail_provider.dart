import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant_detail.dart';
import '../data/model/review.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';

class DetailProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ApiResult<RestaurantDetail> _restaurantDetailResult = const ApiLoading();
  ApiResult<RestaurantDetail> get result => _restaurantDetailResult;
  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _restaurantDetailResult = const ApiLoading();
      notifyListeners();
      final operation = GetRestaurantDetail(id);
      final apiResult = await _apiService.callApi<RestaurantDetailResponse>(
        operation,
      );
      _restaurantDetailResult = switch (apiResult) {
        ApiLoading<RestaurantDetailResponse>() => const ApiLoading(),

        ApiSuccess<RestaurantDetailResponse>(:final data) =>
          data.error
              ? ApiFailure(message: data.message)
              : ApiSuccess(data: data.restaurant),

        ApiFailure<RestaurantDetailResponse>(:final message) => ApiFailure(
          message: message,
        ),

        ApiEmpty<RestaurantDetailResponse>(:final message) => ApiFailure(
          message: message,
        ),
      };
    } catch (e) {
      _restaurantDetailResult = const ApiFailure(
        message:
            'Terjadi kesalahan saat mengambil detail restaurant. Silakan coba lagi.',
      );
    }

    notifyListeners();
  }

  void updateReviewsLocally(List<CustomerReview> newReviews) {
    if (_restaurantDetailResult.isSuccess) {
      final currentRestaurant = _restaurantDetailResult.dataOrNull!;

      final updatedRestaurant = RestaurantDetail(
        id: currentRestaurant.id,
        name: currentRestaurant.name,
        description: currentRestaurant.description,
        pictureId: currentRestaurant.pictureId,
        city: currentRestaurant.city,
        address: currentRestaurant.address,
        rating: currentRestaurant.rating,
        categories: currentRestaurant.categories,
        menus: currentRestaurant.menus,
        customerReviews: newReviews,
      );

      _restaurantDetailResult = ApiSuccess(data: updatedRestaurant);
      notifyListeners();
    }
  }

  Future<void> forceRefreshWithDelay(String id) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    await fetchRestaurantDetail(id);
  }
}
