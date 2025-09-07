import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Reminder';
  static const String _channelDescription = 'Daily lunch reminder notifications';
  static const int _notificationId = 0;

  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (!kIsWeb) {
      await _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleDailyReminder() async {
    if (kIsWeb) {
      // Web doesn't support local notifications
      debugPrint('Local notifications not supported on web');
      return;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId,
      'Waktu Makan Siang! 🍽️',
      'Jangan lupa makan siang hari ini. Cari restoran favorit Anda di Restaurant App!',
      _nextInstanceOf11AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          color: Color(0xFF1976D2),
          enableVibration: true,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            'Jangan lupa makan siang hari ini. Cari restoran favorit Anda di Restaurant App!',
            contentTitle: 'Waktu Makan Siang! 🍽️',
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          subtitle: 'Restaurant App Reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Daily reminder scheduled for 11:00 AM');
  }

  tz.TZDateTime _nextInstanceOf11AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 11, 0);

    // If 11 AM has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    if (kIsWeb) {
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(_notificationId);
    debugPrint('Daily reminder cancelled');
  }

  Future<bool> hasScheduledNotifications() async {
    if (kIsWeb) {
      return false;
    }

    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    
    return pendingNotifications.any((notification) => 
        notification.id == _notificationId);
  }

  Future<void> showTestNotification() async {
    if (kIsWeb) {
      debugPrint('Test notification not supported on web');
      return;
    }

    await _flutterLocalNotificationsPlugin.show(
      999,
      'Test Notification 🧪',
      'Ini adalah test notifikasi untuk memastikan fitur reminder berfungsi!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF1976D2),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
