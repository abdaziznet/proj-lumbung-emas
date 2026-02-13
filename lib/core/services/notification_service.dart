import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lumbungemas/core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _priceReminderNotificationId = 10001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  DateTime? _lastShownAt;

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

    // Avoid duplicate notifications from multiple login callbacks
    // firing almost at the same time.
    final now = DateTime.now();
    if (_lastShownAt != null &&
        now.difference(_lastShownAt!).inSeconds < 10) {
      return;
    }

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

    _lastShownAt = now;
  }
}
