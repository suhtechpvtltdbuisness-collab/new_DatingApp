import 'dart:async';
import 'dart:convert';

import 'package:dating_app/models/notification_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:dating_app/services/notification_service.dart';
import 'package:dating_app/services/realtime_socket_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Firebase Cloud Messaging: notifications that reach the phone while the
/// app is closed or in the background.
///
/// Android reads its Firebase config from `android/app/google-services.json`.
/// iOS reads it from the `FIREBASE_*` values in the env file. With no config
/// the app runs as before and relies on the socket alone.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final Logger _logger = Logger();
  final ApiClient _api = ApiClient();

  bool _available = false;
  bool _listening = false;
  bool _registered = false;
  String? _token;
  Timer? _syncDebounce;
  StreamSubscription<String>? _refreshSub;

  /// True once this device's token is saved on the server. Banners for
  /// background events then come from the push, not from the socket.
  bool get isActive => _available && _registered;

  /// Call once from main(), before runApp.
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      if (Firebase.apps.isEmpty) {
        final options = _optionsFromEnv();
        if (defaultTargetPlatform == TargetPlatform.iOS && options == null) {
          _logger.i('Push off: no FIREBASE_* values for iOS');
          return;
        }
        await Firebase.initializeApp(options: options);
      }
      _available = true;
    } catch (e) {
      // Android without google-services.json lands here.
      _logger.i('Push off: Firebase is not configured ($e)');
      return;
    }

    // Tap on a push that started the app from closed.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _deliverTap(initial);
    FirebaseMessaging.onMessageOpenedApp.listen(_deliverTap);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    NotificationService.instance.onSettingsChanged = _scheduleSync;
  }

  FirebaseOptions? _optionsFromEnv() {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    if (!dotenv.isInitialized) return null;
    String value(String key) => (dotenv.env[key] ?? '').trim();
    final apiKey = value('FIREBASE_IOS_API_KEY');
    final appId = value('FIREBASE_IOS_APP_ID');
    final senderId = value('FIREBASE_MESSAGING_SENDER_ID');
    final projectId = value('FIREBASE_PROJECT_ID');
    if ([apiKey, appId, senderId, projectId].any((v) => v.isEmpty)) {
      return null;
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
      iosBundleId: value('FIREBASE_IOS_BUNDLE_ID').isEmpty
          ? null
          : value('FIREBASE_IOS_BUNDLE_ID'),
    );
  }

  /// After sign-in: ask permission, get the token and save it on the server.
  Future<void> register() async {
    if (!_available || !_api.hasSession) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _logger.i('Push permission denied');
        return;
      }
      _token = await messaging.getToken();
      if (!_listening) {
        _listening = true;
        _refreshSub = messaging.onTokenRefresh.listen((token) {
          _token = token;
          _sendToken();
        });
      }
      await _sendToken();
    } catch (e) {
      // iOS returns no token until APNs answers; onTokenRefresh retries.
      _logger.w('Push registration failed: $e');
    }
  }

  /// Before logout, while the session is still valid.
  Future<void> unregister() async {
    _syncDebounce?.cancel();
    final token = _token;
    _registered = false;
    if (!_available || token == null) return;
    try {
      if (_api.hasSession) {
        await _api.delete<void>(
          ApiEndpoints.notificationDevices,
          data: {'token': token},
        );
      }
      // A fresh token next time, so the old one can't reach this phone.
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      _logger.w('Push unregister failed: $e');
    } finally {
      _token = null;
      await _refreshSub?.cancel();
      _refreshSub = null;
      _listening = false;
    }
  }

  /// Session expired without a logout: the server can't be told, so the
  /// token itself is deleted; the server drops it on its next send.
  Future<void> dropLocalToken() async {
    _syncDebounce?.cancel();
    _registered = false;
    _token = null;
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      _logger.w('Deleting push token failed: $e');
    }
  }

  void _scheduleSync() {
    if (!_registered) return;
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 1), _sendToken);
  }

  Future<void> _sendToken() async {
    final token = _token;
    if (token == null || token.isEmpty || !_api.hasSession) return;
    final notifications = NotificationService.instance;
    final response = await _api.post<dynamic>(
      ApiEndpoints.notificationDevices,
      data: {
        'token': token,
        'platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'preferences': notifications.settings,
        'mutedConversations': notifications.mutedConversations,
      },
    );
    _registered = response.success;
    if (!response.success) {
      _logger.w('Saving push token failed: ${response.message}');
    }
  }

  /// In the foreground the socket shows banners. A push only gets shown here
  /// if the socket happens to be down.
  void _onForegroundMessage(RemoteMessage message) {
    if (RealtimeSocketService().isConnected) return;
    final notification = _toAppNotification(message);
    if (notification != null) NotificationService.instance.show(notification);
  }

  void _deliverTap(RemoteMessage message) {
    final data = message.data;
    NotificationService.instance.deliverTap({
      'id': data['notificationId'] ?? '',
      'type': data['type'] ?? '',
      'metadata': _metadata(data),
    });
  }

  Map<String, dynamic> _metadata(Map<String, dynamic> data) {
    try {
      final decoded = jsonDecode(data['metadata']?.toString() ?? '{}');
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  AppNotification? _toAppNotification(RemoteMessage message) {
    final type = message.data['type']?.toString() ?? '';
    if (type.isEmpty) return null;
    return AppNotification.fromJson({
      'id': message.data['notificationId'] ?? '',
      'type': type,
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'metadata': _metadata(message.data),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
