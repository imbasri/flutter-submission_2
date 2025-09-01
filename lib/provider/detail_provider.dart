import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant_detail.dart';
import '../data/model/review.dart';
import '../utils/result_state.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';

class DetailProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Result<RestaurantDetail> _restaurantDetailResult = Result.loading();

  Result<RestaurantDetail> get result => _restaurantDetailResult;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      // Set loading state
      _restaurantDetailResult = Result.loading();
      notifyListeners();

      // Buat operasi dengan sealed class
      final operation = GetRestaurantDetail(id);

      // Panggil API dengan sealed class
      final apiResult = await _apiService.callApi<RestaurantDetailResponse>(operation);

      _restaurantDetailResult = switch (apiResult) {
        // Kalau masih loading
        ApiLoading<RestaurantDetailResponse>() => Result.loading(),
        
        // Kalau berhasil dapat data
        ApiSuccess<RestaurantDetailResponse>(:final data) => 
          data.error ? Result.error(message: data.message) : Result.hasData(data.restaurant),
          
        // Kalau ada error/gagal
        ApiFailure<RestaurantDetailResponse>(:final message) => 
          Result.error(message: message),
          
        // Kalau data kosong
        ApiEmpty<RestaurantDetailResponse>(:final message) => 
          Result.error(message: message),
      };
      
    } catch (e) {
      // Handle exception
      _restaurantDetailResult = Result.error(message: 'Error: ${e.toString()}');
    }
    
    // Beritahu listener bahwa state sudah berubah
    notifyListeners();
  }

  void updateReviewsLocally(List<CustomerReview> newReviews) {
    // Cek apakah state saat ini punya data
    if (_restaurantDetailResult.state == ResultState.hasData) {
      final currentRestaurant = _restaurantDetailResult.data!;
      
      // Buat restaurant baru dengan review yang sudah diupdate
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
      
      // Update state dengan data baru
      _restaurantDetailResult = Result.hasData(updatedRestaurant);
      notifyListeners();
    }
  }

  // Force refresh dengan delay untuk memastikan server sudah terupdate
  Future<void> forceRefreshWithDelay(String id) async {
    // Tunggu sebentar agar server memproses
    await Future.delayed(const Duration(milliseconds: 1500));
    await fetchRestaurantDetail(id);
  }
}
