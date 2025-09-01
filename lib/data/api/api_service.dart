import 'dart:convert';
import 'dart:io';
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
        GetAllRestaurants() => _getAllRestaurants(),
        SearchRestaurants(:final query) => _searchRestaurants(query),
        GetRestaurantDetail(:final restaurantId) => _getRestaurantDetail(
          restaurantId,
        ),
        AddReview(:final restaurantId, :final name, :final review) =>
          _addReview(restaurantId, name, review),
      };

      return result as ApiResult<T>;
    } on SocketException {
      return ApiFailure<T>(
        message:
            'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet dan coba lagi.',
      );
    } on HttpException {
      return ApiFailure<T>(
        message: 'Terjadi masalah dengan server. Silakan coba lagi nanti.',
      );
    } on FormatException {
      return ApiFailure<T>(
        message: 'Data yang diterima tidak valid. Silakan coba lagi.',
      );
    } catch (e) {
      return ApiFailure<T>(
        message:
            'Terjadi kesalahan yang tidak terduga. Silakan coba lagi nanti.',
      );
    }
  }

  Future<ApiResult<RestaurantListResponse>> _getAllRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final restaurants = RestaurantListResponse.fromJson(data);

        if (restaurants.restaurants.isEmpty) {
          return const ApiEmpty(message: 'Tidak ada restaurant yang ditemukan');
        }

        return ApiSuccess(data: restaurants);
      } else {
        return ApiFailure(
          message: 'Gagal mengambil data restaurant. Silakan coba lagi.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return const ApiFailure(
        message:
            'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet.',
      );
    } catch (e) {
      return const ApiFailure(
        message:
            'Terjadi kesalahan saat mengambil data restaurant. Silakan coba lagi.',
      );
    }
  }

  Future<ApiResult<RestaurantListResponse>> _searchRestaurants(
    String query,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final restaurants = RestaurantListResponse.fromJson(data);

        if (restaurants.restaurants.isEmpty) {
          return ApiEmpty(
            message: 'Tidak ada restaurant dengan kata kunci "$query"',
          );
        }

        return ApiSuccess(data: restaurants);
      } else {
        return ApiFailure(
          message: 'Gagal mencari restaurant. Silakan coba lagi.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return const ApiFailure(
        message:
            'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet.',
      );
    } catch (e) {
      return const ApiFailure(
        message:
            'Terjadi kesalahan saat mencari restaurant. Silakan coba lagi.',
      );
    }
  }

  Future<ApiResult<RestaurantDetailResponse>> _getRestaurantDetail(
    String restaurantId,
  ) async {
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
          message: 'Gagal mengambil detail restaurant. Silakan coba lagi.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return const ApiFailure(
        message:
            'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet.',
      );
    } catch (e) {
      return const ApiFailure(
        message:
            'Terjadi kesalahan saat mengambil detail restaurant. Silakan coba lagi.',
      );
    }
  }

  Future<ApiResult<ReviewResponse>> _addReview(
    String restaurantId,
    String name,
    String review,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': restaurantId, 'name': name, 'review': review}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final reviewResponse = ReviewResponse.fromJson(data);

        return ApiSuccess(data: reviewResponse);
      } else {
        return ApiFailure(
          message: 'Gagal menambahkan review. Silakan coba lagi.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return const ApiFailure(
        message:
            'Tidak ada koneksi internet. Pastikan perangkat Anda terhubung ke internet.',
      );
    } catch (e) {
      return const ApiFailure(
        message:
            'Terjadi kesalahan saat menambahkan review. Silakan coba lagi.',
      );
    }
  }
}
