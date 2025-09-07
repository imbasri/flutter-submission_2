import 'package:flutter/material.dart';
import '../data/db/database_helper.dart';
import '../data/model/restaurant.dart';

enum FavoritesState {
  loading,
  loaded,
  error,
}

class FavoritesProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<Restaurant> _favorites = [];
  FavoritesState _state = FavoritesState.loading;
  String _message = '';
  
  // Track favorite status for each restaurant
  final Map<String, bool> _favoriteStatus = {};

  List<Restaurant> get favorites => _favorites;
  FavoritesState get state => _state;
  String get message => _message;

  // Get favorite status for a specific restaurant
  bool isFavoriteSync(String restaurantId) {
    return _favoriteStatus[restaurantId] ?? false;
  }

  // Load all favorites from database
  Future<void> loadFavorites() async {
    try {
      _state = FavoritesState.loading;
      notifyListeners();

      _favorites = await _databaseHelper.getAllFavorites();
      
      // Update favorite status map
      _favoriteStatus.clear();
      for (final restaurant in _favorites) {
        _favoriteStatus[restaurant.id] = true;
      }
      
      _state = FavoritesState.loaded;
      _message = _favorites.isEmpty ? 'Tidak ada restoran favorit' : '';
    } catch (e) {
      _state = FavoritesState.error;
      _message = 'Terjadi kesalahan: ${e.toString()}';
    }
    notifyListeners();
  }

  // Add restaurant to favorites
  Future<void> addToFavorites(Restaurant restaurant) async {
    try {
      await _databaseHelper.insertFavorite(restaurant);
      _favoriteStatus[restaurant.id] = true;
      await loadFavorites(); // Reload to update UI
    } catch (e) {
      _state = FavoritesState.error;
      _message = 'Gagal menambahkan ke favorit: ${e.toString()}';
      notifyListeners();
    }
  }

  // Remove restaurant from favorites
  Future<void> removeFromFavorites(String restaurantId) async {
    try {
      await _databaseHelper.deleteFavorite(restaurantId);
      _favoriteStatus[restaurantId] = false;
      await loadFavorites(); // Reload to update UI
    } catch (e) {
      _state = FavoritesState.error;
      _message = 'Gagal menghapus dari favorit: ${e.toString()}';
      notifyListeners();
    }
  }

  // Check if restaurant is in favorites (async)
  Future<bool> isFavorite(String restaurantId) async {
    try {
      final result = await _databaseHelper.isFavorite(restaurantId);
      _favoriteStatus[restaurantId] = result;
      return result;
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Restaurant restaurant) async {
    final currentStatus = _favoriteStatus[restaurant.id] ?? false;
    
    if (currentStatus) {
      await removeFromFavorites(restaurant.id);
    } else {
      await addToFavorites(restaurant);
    }
  }

  // Initialize favorite status for a restaurant
  Future<void> checkFavoriteStatus(String restaurantId) async {
    if (!_favoriteStatus.containsKey(restaurantId)) {
      final result = await _databaseHelper.isFavorite(restaurantId);
      _favoriteStatus[restaurantId] = result;
      notifyListeners();
    }
  }
}
