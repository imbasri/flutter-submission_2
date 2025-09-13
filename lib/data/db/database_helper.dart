import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/restaurant.dart';

// Helper class untuk mengelola database SQLite restoran favorit
class DatabaseHelper {
  static const String _databaseName = 'restaurant_database.db';
  static const int _databaseVersion = 1;
  static const String _favoritesKey = 'favorite_restaurants';
  
  // Definisi tabel dan kolom
  static const String tableFavorites = 'favorites';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnPictureId = 'pictureId';
  static const String columnCity = 'city';
  static const String columnRating = 'rating';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) {
      // For web, we'll use SharedPreferences instead
      return null;
    }
    
    if (_database != null) return _database!;
    
    // Initialize sqflite_ffi for desktop platforms
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFavorites (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnPictureId TEXT NOT NULL,
        $columnCity TEXT NOT NULL,
        $columnRating REAL NOT NULL
      )
    ''');
  }

  // Insert a favorite restaurant
  Future<void> insertFavorite(Restaurant restaurant) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getAllFavorites();
      
      // Check if restaurant is already in favorites
      final existingIndex = favorites.indexWhere((r) => r.id == restaurant.id);
      if (existingIndex == -1) {
        favorites.add(restaurant);
        final favoritesJson = favorites.map((r) => r.toJson()).toList();
        await prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
      }
    } else {
      // Use SQLite for mobile/desktop
      Database? db = await database;
      if (db != null) {
        await db.insert(
          tableFavorites,
          restaurant.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  // Delete a favorite restaurant
  Future<void> deleteFavorite(String restaurantId) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getAllFavorites();
      
      favorites.removeWhere((r) => r.id == restaurantId);
      final favoritesJson = favorites.map((r) => r.toJson()).toList();
      await prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
    } else {
      // Use SQLite for mobile/desktop
      Database? db = await database;
      if (db != null) {
        await db.delete(
          tableFavorites,
          where: '$columnId = ?',
          whereArgs: [restaurantId],
        );
      }
    }
  }

  // Get all favorite restaurants
  Future<List<Restaurant>> getAllFavorites() async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);
      
      if (favoritesString == null) return [];
      
      try {
        final List<dynamic> favoritesJson = jsonDecode(favoritesString);
        return favoritesJson.map((json) => Restaurant.fromJson(json)).toList();
      } catch (e) {
        return [];
      }
    } else {
      // Use SQLite for mobile/desktop
      Database? db = await database;
      if (db == null) return [];
      
      final List<Map<String, dynamic>> maps = await db.query(tableFavorites);
      
      return List.generate(maps.length, (i) {
        return Restaurant.fromJson(maps[i]);
      });
    }
  }

  // Check if a restaurant is favorite
  Future<bool> isFavorite(String restaurantId) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final favorites = await getAllFavorites();
      return favorites.any((r) => r.id == restaurantId);
    } else {
      // Use SQLite for mobile/desktop
      Database? db = await database;
      if (db == null) return false;
      
      final List<Map<String, dynamic>> maps = await db.query(
        tableFavorites,
        where: '$columnId = ?',
        whereArgs: [restaurantId],
      );
      return maps.isNotEmpty;
    }
  }

  // Get favorite restaurant by id
  Future<Restaurant?> getFavoriteById(String restaurantId) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final favorites = await getAllFavorites();
      try {
        return favorites.firstWhere((r) => r.id == restaurantId);
      } catch (e) {
        return null;
      }
    } else {
      // Use SQLite for mobile/desktop
      Database? db = await database;
      if (db == null) return null;
      
      final List<Map<String, dynamic>> maps = await db.query(
        tableFavorites,
        where: '$columnId = ?',
        whereArgs: [restaurantId],
      );
      
      if (maps.isNotEmpty) {
        return Restaurant.fromJson(maps.first);
      }
      return null;
    }
  }
}
