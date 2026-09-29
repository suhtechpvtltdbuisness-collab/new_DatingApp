import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// Local notifications for new chat messages while the app is open/background.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool messagesEnabled = true;
  bool pushEnabled = true;

  static const _channelId = 'vellora_messages';
  static const _channelName = 'Messages';

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
    }

    final prefs = await SharedPreferences.getInstance();
    pushEnabled = prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
    messagesEnabled = prefs.getBool(StorageKeys.messageNotifications) ?? true;

    _initialized = true;
  }

  Future<void> setPushEnabled(bool enabled) async {
    pushEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.notificationsEnabled, enabled);
  }

  Future<void> setMessagesEnabled(bool enabled) async {
    messagesEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.messageNotifications, enabled);
  }

  Future<void> showMessageNotification({
    required String conversationId,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;
    if (!pushEnabled || !messagesEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'New chat messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final id = conversationId.hashCode & 0x7fffffff;
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
