import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _reminderKey = 'daily_reminder_enabled';
  bool _isReminderEnabled = false;
  bool _isInitialized = false;

  bool get isReminderEnabled => _isReminderEnabled;
  bool get isInitialized => _isInitialized;

  final NotificationService _notificationService = NotificationService();

  ReminderProvider() {
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isReminderEnabled = prefs.getBool(_reminderKey) ?? false;
      _isInitialized = true;
      
      // If reminder was enabled, ensure it's still scheduled
      if (_isReminderEnabled) {
        final hasScheduled = await _notificationService.hasScheduledNotifications();
        if (!hasScheduled) {
          await _notificationService.scheduleDailyReminder();
        }
      }
      
      notifyListeners();
    } catch (e) {
      // Error loading reminder settings: using default (disabled)
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setReminderEnabled(bool enabled) async {
    if (_isReminderEnabled != enabled) {
      _isReminderEnabled = enabled;
      await _saveReminderSettings();
      
      if (enabled) {
        await _notificationService.scheduleDailyReminder();
      } else {
        await _notificationService.cancelDailyReminder();
      }
      
      notifyListeners();
    }
  }

  Future<void> toggleReminder() async {
    await setReminderEnabled(!_isReminderEnabled);
  }

  Future<void> _saveReminderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderKey, _isReminderEnabled);
    } catch (e) {
      // Error saving reminder settings: setting not persisted
    }
  }

  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  String get reminderStatusText => _isReminderEnabled 
      ? 'Aktif - Notifikasi setiap hari pukul 11:00' 
      : 'Tidak Aktif';

  String get nextReminderText {
    if (!_isReminderEnabled) return 'Reminder tidak aktif';
    
    final now = DateTime.now();
    final today11AM = DateTime(now.year, now.month, now.day, 11, 0);
    final nextReminder = today11AM.isAfter(now) 
        ? today11AM 
        : today11AM.add(const Duration(days: 1));
    
    if (nextReminder.day == now.day) {
      return 'Hari ini pukul 11:00';
    } else {
      return 'Besok pukul 11:00';
    }
  }
}
