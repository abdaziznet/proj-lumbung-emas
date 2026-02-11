import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _priceReminderLastShownKey =
      'price_reminder_last_shown_date';
  static const int _priceReminderNotificationId = 10001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.priceAlertChannelId,
        AppConstants.priceAlertChannelName,
        description: 'Pengingat update harga jual harian',
        importance: Importance.high,
      ),
    );

    final iosImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macosImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    await macosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  Future<void> showPriceUpdateReminderIfNeeded() async {
    await initialize();

    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastShown = prefs.getString(_priceReminderLastShownKey);
    if (lastShown == today) return;

    await _plugin.show(
      _priceReminderNotificationId,
      'Perbarui Harga Jual Hari Ini',
      'Silakan update harga jual (buyback) hari ini agar nilai aset Anda tetap akurat dan terpantau dengan baik.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.priceAlertChannelId,
          AppConstants.priceAlertChannelName,
          channelDescription: 'Pengingat update harga jual harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    await prefs.setString(_priceReminderLastShownKey, today);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
