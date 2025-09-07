import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/restaurant.dart';

class DatabaseHelper {
  static const String _favoritesKey = 'favorite_restaurants';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Insert a favorite restaurant
  Future<void> insertFavorite(Restaurant restaurant) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getAllFavorites();
    
    // Check if restaurant is already in favorites
    final existingIndex = favorites.indexWhere((r) => r.id == restaurant.id);
    if (existingIndex == -1) {
      favorites.add(restaurant);
      final favoritesJson = favorites.map((r) => r.toJson()).toList();
      await prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
    }
  }

  // Delete a favorite restaurant
  Future<void> deleteFavorite(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getAllFavorites();
    
    favorites.removeWhere((r) => r.id == restaurantId);
    final favoritesJson = favorites.map((r) => r.toJson()).toList();
    await prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
  }

  // Get all favorite restaurants
  Future<List<Restaurant>> getAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString(_favoritesKey);
    
    if (favoritesString == null) return [];
    
    try {
      final List<dynamic> favoritesJson = jsonDecode(favoritesString);
      return favoritesJson.map((json) => Restaurant.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if a restaurant is favorite
  Future<bool> isFavorite(String restaurantId) async {
    final favorites = await getAllFavorites();
    return favorites.any((r) => r.id == restaurantId);
  }

  // Get favorite restaurant by id
  Future<Restaurant?> getFavoriteById(String restaurantId) async {
    final favorites = await getAllFavorites();
    try {
      return favorites.firstWhere((r) => r.id == restaurantId);
    } catch (e) {
      return null;
    }
  }
}
