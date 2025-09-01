import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/restaurant.dart';
import '../model/restaurant_detail.dart';
import '../model/review.dart';
import '../../utils/api_result.dart';
import '../../utils/api_operations.dart';


class ApiService {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';
  

  Future<ApiResult<T>> callApi<T>(ApiOperation operation) async {
    try {
  
      final result = await switch (operation) {
        // Untuk mendapatkan semua restaurant
        GetAllRestaurants() => _getAllRestaurants(),
        
        // Untuk mencari restaurant berdasarkan query
        SearchRestaurants(:final query) => _searchRestaurants(query),
        
        // Untuk mendapatkan detail restaurant
        GetRestaurantDetail(:final restaurantId) => _getRestaurantDetail(restaurantId),
        
        // Untuk menambahkan review
        AddReview(:final restaurantId, :final name, :final review) => 
          _addReview(restaurantId, name, review),
      };
      
      return result as ApiResult<T>;
      
    } catch (e) {
      // Handle error dengan ApiFailure
      return ApiFailure<T>(
        message: 'Terjadi kesalahan: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
  
  // Method untuk get semua restaurant
  Future<ApiResult<RestaurantListResponse>> _getAllRestaurants() async {
    try {
      // Panggil API
      final response = await http.get(
        Uri.parse('$baseUrl/list'),
        headers: {'Content-Type': 'application/json'},
      );
      
      // Cek status code
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final restaurants = RestaurantListResponse.fromJson(data);
        
        // Cek apakah ada data
        if (restaurants.restaurants.isEmpty) {
          return const ApiEmpty(message: 'Tidak ada restaurant yang ditemukan');
        }
        
        return ApiSuccess(data: restaurants);
      } else {
        return ApiFailure(
          message: 'Gagal mengambil data restaurant',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiFailure(
        message: 'Error saat mengambil restaurant: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
  
  // Method untuk search restaurant
  Future<ApiResult<RestaurantListResponse>> _searchRestaurants(String query) async {
    try {
      // Panggil API search
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final restaurants = RestaurantListResponse.fromJson(data);
        
        if (restaurants.restaurants.isEmpty) {
          return ApiEmpty(message: 'Tidak ada restaurant dengan kata kunci "$query"');
        }
        
        return ApiSuccess(data: restaurants);
      } else {
        return ApiFailure(
          message: 'Gagal mencari restaurant',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiFailure(
        message: 'Error saat mencari restaurant: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
  
  // Method untuk get detail restaurant
  Future<ApiResult<RestaurantDetailResponse>> _getRestaurantDetail(String restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detail/$restaurantId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final restaurant = RestaurantDetailResponse.fromJson(data);
        
        return ApiSuccess(data: restaurant);
      } else {
        return ApiFailure(
          message: 'Gagal mengambil detail restaurant',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiFailure(
        message: 'Error saat mengambil detail: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
  
  // Method untuk add review
  Future<ApiResult<ReviewResponse>> _addReview(String restaurantId, String name, String review) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': restaurantId,
          'name': name,
          'review': review,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final reviewResponse = ReviewResponse.fromJson(data);
        
        return ApiSuccess(data: reviewResponse);
      } else {
        return ApiFailure(
          message: 'Gagal menambahkan review',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiFailure(
        message: 'Error saat menambahkan review: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

class ApiHelper {
  static final ApiService _apiService = ApiService();
  
  static Future<ApiResult<RestaurantListResponse>> getAllRestaurants() {
    // Buat operasi menggunakan sealed class
    const operation = GetAllRestaurants();
    
    // Panggil API
    return _apiService.callApi<RestaurantListResponse>(operation);
  }
  
  static Future<ApiResult<RestaurantListResponse>> searchRestaurants(String query) {
    // Buat operasi search
    final operation = SearchRestaurants(query);
    
    // Panggil API
    return _apiService.callApi<RestaurantListResponse>(operation);
  }
  
  // Contoh 3: Get detail restaurant
  static Future<ApiResult<RestaurantDetailResponse>> getRestaurantDetail(String id) {
    // Buat operasi detail
    final operation = GetRestaurantDetail(id);
    
    // Panggil API
    return _apiService.callApi<RestaurantDetailResponse>(operation);
  }
  
  // Contoh 4: Add review
  static Future<ApiResult<ReviewResponse>> addReview({
    required String restaurantId,
    required String name,
    required String review,
  }) {
    // Buat operasi review
    final operation = AddReview(
      restaurantId: restaurantId,
      name: name,
      review: review,
    );
    
    // Panggil API
    return _apiService.callApi<ReviewResponse>(operation);
  }
}
