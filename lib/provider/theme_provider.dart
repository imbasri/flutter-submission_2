import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider untuk mengatur tema aplikasi (terang/gelap)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = false;
  bool _isInitialized = false;

  // Getter untuk status tema gelap
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadTheme();
  }

  // Muat pengaturan tema dari penyimpanan lokal
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Error saat memuat tema: gunakan tema terang default
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Ganti tema (terang ke gelap atau sebaliknya)
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme();
    notifyListeners();
  }

  // Set tema gelap secara langsung
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      await _saveTheme();
      notifyListeners();
    }
  }

  // Simpan pengaturan tema ke penyimpanan lokal
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      // Error saat menyimpan tema: preferensi tema tidak tersimpan
    }
  }

  // Nama tema saat ini
  String get currentThemeName => _isDarkMode ? 'Gelap' : 'Terang';
}
