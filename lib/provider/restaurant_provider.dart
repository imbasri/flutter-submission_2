import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant.dart';
import '../utils/result_state.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';


class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Result<List<Restaurant>> _restaurantResult = Result.loading();
  
  Result<List<Restaurant>> get result => _restaurantResult;

  Future<void> fetchRestaurants() async {
    try {
      // Set loading state
      _restaurantResult = Result.loading();
      notifyListeners();
      
      // Buat operasi menggunakan sealed class
      const operation = GetAllRestaurants();
      
      // Panggil API dengan sealed class
      final apiResult = await _apiService.callApi<RestaurantListResponse>(operation);
      
      _restaurantResult = switch (apiResult) {
        // Kalau masih loading
        ApiLoading<RestaurantListResponse>() => Result.loading(),
        
        // Kalau berhasil dapat data
        ApiSuccess<RestaurantListResponse>(:final data) => 
          data.restaurants.isEmpty 
            ? Result.noData(message: 'Tidak ada restaurant ditemukan')
            : Result.hasData(data.restaurants),
            
        // Kalau ada error/gagal
        ApiFailure<RestaurantListResponse>(:final message) => 
          Result.error(message: message),
          
        // Kalau data kosong
        ApiEmpty<RestaurantListResponse>(:final message) => 
          Result.noData(message: message),
      };
      
    } catch (e) {
      // Handle exception
      _restaurantResult = Result.error(message: 'Error: ${e.toString()}');
    }
    
    // Beritahu listener bahwa state sudah berubah
    notifyListeners();
  }

  Future<void> searchRestaurants(String query) async {
    try {
      _restaurantResult = Result.loading();
      notifyListeners();
      
      // Buat operasi search dengan sealed class
      final operation = SearchRestaurants(query);
      
      // Panggil API
      final apiResult = await _apiService.callApi<RestaurantListResponse>(operation);
      
      // Handle hasil dengan pattern matching
      _restaurantResult = switch (apiResult) {
        ApiLoading() => Result.loading(),
        ApiSuccess(:final data) => 
          data.restaurants.isEmpty 
            ? Result.noData(message: 'Tidak ada hasil untuk "$query"')
            : Result.hasData(data.restaurants),
        ApiFailure(:final message) => Result.error(message: message),
        ApiEmpty(:final message) => Result.noData(message: message),
      };
      
    } catch (e) {
      _restaurantResult = Result.error(message: 'Error pencarian: ${e.toString()}');
    }
    
    notifyListeners();
  }
}
