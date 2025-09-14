import 'package:flutter/material.dart';
import '../data/db/database_helper.dart';
import '../data/model/restaurant.dart';

enum FavoritesState { loading, loaded, error }

class FavoritesProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Restaurant> _favorites = [];
  FavoritesState _state = FavoritesState.loading;
  String _message = '';

  final Map<String, bool> _favoriteStatus = {};

  List<Restaurant> get favorites => _favorites;
  FavoritesState get state => _state;
  String get message => _message;

  bool isFavoriteSync(String restaurantId) {
    return _favoriteStatus[restaurantId] ?? false;
  }

  Future<void> loadFavorites() async {
    try {
      _state = FavoritesState.loading;
      notifyListeners();

      _favorites = await _databaseHelper.getAllFavorites();

      _favoriteStatus.clear();
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

  Future<void> addToFavorites(Restaurant restaurant) async {
    try {
      await _databaseHelper.insertFavorite(restaurant);
      _favoriteStatus[restaurant.id] = true;
      await loadFavorites();
    } catch (e) {
      _state = FavoritesState.error;
      _message = 'Gagal menambahkan ke favorit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(String restaurantId) async {
    try {
      await _databaseHelper.deleteFavorite(restaurantId);
      _favoriteStatus[restaurantId] = false;
      await loadFavorites();
    } catch (e) {
      _state = FavoritesState.error;
      _message = 'Gagal menghapus dari favorit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String restaurantId) async {
    try {
      final result = await _databaseHelper.isFavorite(restaurantId);
      _favoriteStatus[restaurantId] = result;
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    final currentStatus = _favoriteStatus[restaurant.id] ?? false;

    if (currentStatus) {
      await removeFromFavorites(restaurant.id);
    } else {
      await addToFavorites(restaurant);
    }
  }

  Future<void> checkFavoriteStatus(String restaurantId) async {
    if (!_favoriteStatus.containsKey(restaurantId)) {
      final result = await _databaseHelper.isFavorite(restaurantId);
      _favoriteStatus[restaurantId] = result;
      notifyListeners();
    }
  }
}
