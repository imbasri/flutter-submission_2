import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant.dart';
import '../utils/result_state.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';
class SearchProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Result<List<Restaurant>> _searchResult = Result.noData();
  String _query = '';
  
  Result<List<Restaurant>> get result => _searchResult;
  String get query => _query;
  Future<void> searchRestaurants(String query) async {
    try {
      _query = query;
      
      if (query.isEmpty) {
        _searchResult = Result.noData(message: 'Masukkan nama restaurant untuk mencari');
        notifyListeners();
        return;
      }
      _searchResult = Result.loading();
      notifyListeners();
      
      final operation = SearchRestaurants(query);
      
      final apiResult = await _apiService.callApi<RestaurantListResponse>(operation);
      
      _searchResult = switch (apiResult) {
        ApiLoading<RestaurantListResponse>() => Result.loading(),
        
        ApiSuccess<RestaurantListResponse>(:final data) => 
          data.restaurants.isEmpty 
            ? Result.noData(message: 'Tidak ada restaurant dengan kata kunci "$query"')
            : Result.hasData(data.restaurants),
            
        ApiFailure<RestaurantListResponse>(:final message) => 
          Result.error(message: message),
          
        ApiEmpty<RestaurantListResponse>(:final message) => 
          Result.noData(message: message),
      };
      
    } catch (e) {
      _searchResult = Result.error(message: 'Error pencarian: ${e.toString()}');
    }
    
    notifyListeners();
  }
  void clearSearch() {
    _searchResult = Result.noData();
    _query = '';
    notifyListeners();
  }
  bool get hasResults => _searchResult.state == ResultState.hasData;
  
  int get resultCount => hasResults ? _searchResult.data!.length : 0;
}
