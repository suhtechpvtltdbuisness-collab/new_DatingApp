import 'dart:convert';

import 'package:dating_app/models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

typedef NotificationTapHandler = void Function(Map<String, dynamic> payload);

/// System-tray notifications for realtime events (messages, matches, likes,
/// account updates), the user's per-category settings, and per-chat mutes.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool pushEnabled = true;
  bool messagesEnabled = true;
  bool matchesEnabled = true;
  bool likesEnabled = true;
  bool accountEnabled = true;
  Set<String> _mutedConversations = <String>{};

  NotificationTapHandler? _tapHandler;
  Map<String, dynamic>? _pendingTap;

  /// Called after any setting or mute changes, so the server's copy (used
  /// for push notifications) can be updated.
  VoidCallback? onSettingsChanged;

  /// Snapshot of the settings sent to the server with the push token.
  Map<String, bool> get settings => {
        'enabled': pushEnabled,
        'messages': messagesEnabled,
        'matches': matchesEnabled,
        'likes': likesEnabled,
        'account': accountEnabled,
      };

  List<String> get mutedConversations => _mutedConversations.toList();

  static const _messages = _Channel('velora_messages', 'Messages', 'New chat messages');
  static const _matches = _Channel('velora_matches', 'Matches', 'New matches');
  static const _likes = _Channel('velora_likes', 'Likes', 'Super Likes and new likes');
  static const _account = _Channel('velora_account', 'Account & safety', 'Verification and report updates');

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
      onDidReceiveNotificationResponse: (response) =>
          _handleTap(response.payload),
    );

    // App was started by tapping a notification.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _handleTap(launch!.notificationResponse?.payload);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
      // Push notifications shown by the system while the app is closed use
      // these channels, so they must exist before the first banner.
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      for (final channel in [_messages, _matches, _likes, _account]) {
        await android?.createNotificationChannel(
          AndroidNotificationChannel(
            channel.id,
            channel.name,
            description: channel.description,
            importance: Importance.high,
          ),
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    pushEnabled = prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
    messagesEnabled = prefs.getBool(StorageKeys.messageNotifications) ?? true;
    matchesEnabled = prefs.getBool(StorageKeys.matchNotifications) ?? true;
    likesEnabled = prefs.getBool(StorageKeys.likeNotifications) ?? true;
    accountEnabled = prefs.getBool(StorageKeys.accountNotifications) ?? true;
    _mutedConversations =
        (prefs.getStringList(StorageKeys.mutedConversations) ?? const [])
            .toSet();

    _initialized = true;
  }

  /// Taps that arrive before a handler is registered (cold start) are held
  /// and delivered as soon as one is set.
  void setTapHandler(NotificationTapHandler? handler) {
    _tapHandler = handler;
    final pending = _pendingTap;
    if (handler != null && pending != null) {
      _pendingTap = null;
      handler(pending);
    }
  }

  void _handleTap(String? rawPayload) {
    if (rawPayload == null || rawPayload.isEmpty) return;
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map) return;
      payload = decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      return;
    }
    deliverTap(payload);
  }

  /// A tapped notification, from a local banner or a push. Payload shape:
  /// `{id, type, metadata}`.
  void deliverTap(Map<String, dynamic> payload) {
    final handler = _tapHandler;
    if (handler == null) {
      _pendingTap = payload;
    } else {
      handler(payload);
    }
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    onSettingsChanged?.call();
  }

  Future<void> setPushEnabled(bool enabled) async {
    pushEnabled = enabled;
    await _setBool(StorageKeys.notificationsEnabled, enabled);
  }

  Future<void> setMessagesEnabled(bool enabled) async {
    messagesEnabled = enabled;
    await _setBool(StorageKeys.messageNotifications, enabled);
  }

  Future<void> setMatchesEnabled(bool enabled) async {
    matchesEnabled = enabled;
    await _setBool(StorageKeys.matchNotifications, enabled);
  }

  Future<void> setLikesEnabled(bool enabled) async {
    likesEnabled = enabled;
    await _setBool(StorageKeys.likeNotifications, enabled);
  }

  Future<void> setAccountEnabled(bool enabled) async {
    accountEnabled = enabled;
    await _setBool(StorageKeys.accountNotifications, enabled);
  }

  bool isConversationMuted(String conversationId) =>
      _mutedConversations.contains(conversationId);

  Future<void> setConversationMuted(String conversationId, bool muted) async {
    if (conversationId.isEmpty) return;
    muted
        ? _mutedConversations.add(conversationId)
        : _mutedConversations.remove(conversationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.mutedConversations,
      _mutedConversations.toList(),
    );
    onSettingsChanged?.call();
  }

  bool _allows(AppNotification notification) {
    if (!pushEnabled) return false;
    switch (notification.type) {
      case NotificationType.chat:
        return messagesEnabled &&
            !isConversationMuted(notification.conversationId);
      case NotificationType.match:
        return matchesEnabled;
      case NotificationType.like:
      case NotificationType.superLike:
        return likesEnabled;
      default:
        return accountEnabled;
    }
  }

  _Channel _channelFor(String type) {
    switch (type) {
      case NotificationType.chat:
        return _messages;
      case NotificationType.match:
        return _matches;
      case NotificationType.like:
      case NotificationType.superLike:
        return _likes;
      default:
        return _account;
    }
  }

  /// Stable per-subject id, so a newer message from the same chat replaces
  /// the previous banner instead of stacking.
  int _idFor(AppNotification notification) {
    final subject = switch (notification.type) {
      NotificationType.chat => 'chat_${notification.conversationId}',
      NotificationType.match => 'match_${notification.actorId}',
      NotificationType.like ||
      NotificationType.superLike =>
        'like_${notification.actorId}',
      _ => 'notification_${notification.id}',
    };
    return subject.hashCode & 0x7fffffff;
  }

  Future<void> show(AppNotification notification) async {
    if (kIsWeb || !_initialized || !_allows(notification)) return;

    final channel = _channelFor(notification.type);
    final body = notification.type == NotificationType.chat &&
            notification.count > 1
        ? '${notification.body} (${notification.count} new messages)'
        : notification.body;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(body),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      _idFor(notification),
      notification.title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({
        'id': notification.id,
        'type': notification.type,
        'metadata': notification.metadata,
      }),
    );
  }

  /// Removes a chat's banner once the chat has been read.
  Future<void> clearConversation(String conversationId) async {
    if (kIsWeb || !_initialized || conversationId.isEmpty) return;
    await _plugin.cancel(('chat_$conversationId').hashCode & 0x7fffffff);
    // Android shows a push with id 0 and the tag the server set.
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin.cancel(0, tag: 'chat_$conversationId');
    }
  }

  Future<void> clearAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }
}

class _Channel {
  const _Channel(this.id, this.name, this.description);

  final String id;
  final String name;
  final String description;
}
