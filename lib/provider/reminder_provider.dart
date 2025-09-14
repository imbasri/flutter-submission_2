import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _reminderKey = 'daily_reminder_enabled';
  static const String _reminderTimeKey = 'daily_reminder_time';
  bool _isReminderEnabled = false;
  bool _isInitialized = false;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: 11,
    minute: 0,
  ); // Default 11:00

  bool get isReminderEnabled => _isReminderEnabled;
  bool get isInitialized => _isInitialized;
  TimeOfDay get reminderTime => _reminderTime;

  final NotificationService _notificationService = NotificationService();

  ReminderProvider() {
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isReminderEnabled = prefs.getBool(_reminderKey) ?? false;

      // Load reminder time
      final reminderTimeString = prefs.getString(_reminderTimeKey);
      if (reminderTimeString != null) {
        final timeParts = reminderTimeString.split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }

      // Set time in notification service
      NotificationService.setReminderTime(_reminderTime);

      _isInitialized = true;

      // If reminder was enabled, ensure it's still scheduled
      if (_isReminderEnabled) {
        final hasScheduled = await _notificationService
            .hasScheduledNotifications();
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

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    NotificationService.setReminderTime(
      time,
    ); // Set time in notification service
    await _saveReminderSettings();

    // If reminder is enabled, reschedule with new time
    if (_isReminderEnabled) {
      await _notificationService.cancelDailyReminder();
      await _notificationService.scheduleDailyReminder();
    }

    notifyListeners();
  }

  Future<void> toggleReminder() async {
    await setReminderEnabled(!_isReminderEnabled);
  }

  Future<void> _saveReminderSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderKey, _isReminderEnabled);
      await prefs.setString(
        _reminderTimeKey,
        '${_reminderTime.hour}:${_reminderTime.minute}',
      );
    } catch (e) {
      // Error saving reminder settings: setting not persisted
    }
  }

  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  String get reminderStatusText => _isReminderEnabled
      ? 'Aktif - Notifikasi setiap hari pukul ${_formatTime(_reminderTime)}'
      : 'Tidak Aktif';

  String get nextReminderText {
    if (!_isReminderEnabled) return 'Reminder tidak aktif';

    final now = DateTime.now();
    final todayAtTime = DateTime(
      now.year,
      now.month,
      now.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );
    final nextReminder = todayAtTime.isAfter(now)
        ? todayAtTime
        : todayAtTime.add(const Duration(days: 1));

    if (nextReminder.day == now.day) {
      return 'Hari ini pukul ${_formatTime(_reminderTime)}';
    } else {
      return 'Besok pukul ${_formatTime(_reminderTime)}';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get reminderTimeText => _formatTime(_reminderTime);
}
