import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import '../data/model/restaurant.dart';

// Callback dispatcher untuk Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'dailyReminderTask':
          await _executeNotificationTask();
          break;
      }
      return Future.value(true);
    } catch (error) {
      debugPrint('Error executing background task: $error');
      return Future.value(false);
    }
  });
}

// Eksekusi tugas latar belakang
Future<void> _executeNotificationTask() async {
  final service = NotificationService();
  await service._initializeForBackground();
  await NotificationService.showRandomRestaurantNotification();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Reminder';
  static const String _channelDescription =
      'Daily lunch reminder notifications';
  static const int _notificationId = 0;
  static const String dailyReminderTask = 'dailyReminderTask';

  // Store reminder time for scheduling
  static TimeOfDay _reminderTime = const TimeOfDay(hour: 11, minute: 0);

  Future<void> initialize() async {
    // Inisialisasi data timezone
    tz.initializeTimeZones();

    // Inisialisasi Workmanager untuk tugas latar belakang
    if (!kIsWeb) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    }

    // Pengaturan inisialisasi Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Pengaturan inisialisasi iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Inisialisasi plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Minta izin untuk Android 13+
    if (!kIsWeb) {
      await _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Tangani ketukan notifikasi
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Inisialisasi latar belakang untuk tugas Workmanager
  Future<void> _initializeForBackground() async {
    if (kIsWeb) {
      return;
    }

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyReminder() async {
    if (kIsWeb) {
      // Web tidak mendukung notifikasi lokal
      debugPrint('Local notifications not supported on web');
      return;
    }

    // Batalkan tugas yang sudah ada
    await cancelDailyReminder();

    // Jadwalkan dengan Workmanager untuk eksekusi latar belakang
    await Workmanager().registerPeriodicTask(
      dailyReminderTask,
      dailyReminderTask,
      frequency: const Duration(hours: 24),
      initialDelay: _getInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint(
      'Daily reminder scheduled with Workmanager for ${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}',
    );
  }

  static void setReminderTime(TimeOfDay time) {
    _reminderTime = time;
  }

  Duration _getInitialDelay() {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _reminderTime.hour,
      _reminderTime.minute,
      0,
    );

    if (scheduledTime.isBefore(now)) {
      // If scheduled time has passed today, schedule for tomorrow
      return scheduledTime.add(const Duration(days: 1)).difference(now);
    } else {
      // Schedule for today at the set time
      return scheduledTime.difference(now);
    }
  }

  static Future<void> showRandomRestaurantNotification() async {
    try {
      final restaurant = await _fetchRandomRestaurant();
      if (restaurant != null) {
        await _showNotificationWithRestaurant(restaurant);
      } else {
        await _showGenericNotification();
      }
    } catch (e) {
      debugPrint('Error in notification: $e');
      await _showGenericNotification();
    }
  }

  static Future<Restaurant?> _fetchRandomRestaurant() async {
    try {
      final response = await http.get(
        Uri.parse('https://restaurant-api.dicoding.dev/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final restaurants = RestaurantListResponse.fromJson(data);

        if (restaurants.restaurants.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(restaurants.restaurants.length);
          return restaurants.restaurants[randomIndex];
        }
      }
    } catch (e) {
      debugPrint('Error fetching restaurant: $e');
    }
    return null;
  }

  static Future<void> _showNotificationWithRestaurant(
    Restaurant restaurant,
  ) async {
    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    final String notificationBody =
        '${restaurant.name} di ${restaurant.city} - Rating: ${restaurant.rating}⭐';

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily restaurant recommendation',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: const Color(0xFF1976D2),
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          notificationBody,
          contentTitle: 'Rekomendasi Restoran Hari Ini 🍽️',
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        subtitle: 'Restaurant App Recommendation',
      ),
    );

    await notifications.show(
      0,
      'Rekomendasi Restoran Hari Ini 🍽️',
      notificationBody,
      notificationDetails,
      payload: restaurant.id,
    );
  }

  static Future<void> _showGenericNotification() async {
    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();

    await notifications.show(
      0,
      'Waktu Makan Siang! 🍽️',
      'Jangan lupa makan siang hari ini. Cari restoran favorit Anda di Restaurant App!',
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
    );
  }

  Future<void> cancelDailyReminder() async {
    if (kIsWeb) {
      return;
    }

    await Workmanager().cancelByUniqueName(dailyReminderTask);
    await _flutterLocalNotificationsPlugin.cancel(_notificationId);
    debugPrint('Daily reminder cancelled');
  }

  Future<bool> hasScheduledNotifications() async {
    if (kIsWeb) {
      return false;
    }

    final List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    return pendingNotifications.any(
      (notification) => notification.id == _notificationId,
    );
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
