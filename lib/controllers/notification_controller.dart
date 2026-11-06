import 'dart:async';

import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/notification_model.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/screens/notifications/notifications_center_screen.dart';
import 'package:dating_app/services/notification_inbox_service.dart';
import 'package:dating_app/services/notification_service.dart';
import 'package:dating_app/services/push_service.dart';
import 'package:dating_app/services/realtime_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Home tabs a notification can send the user to.
class HomeTab {
  static const likedYou = 0;
  static const people = 1;
  static const chat = 2;
  static const profile = 3;
}

/// Owns the realtime socket for the signed-in session and everything that
/// hangs off it: the in-app notification list, unread badges, system banners
/// and what happens when a notification is tapped.
class NotificationController extends GetxController
    with WidgetsBindingObserver {
  final NotificationInboxService _inbox = NotificationInboxService();
  final RealtimeSocketService _socket = RealtimeSocketService();
  final Logger _logger = Logger();

  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;
  final errorMessage = ''.obs;

  /// Likes that arrived since the Liked You tab was last opened.
  final newLikes = 0.obs;

  /// Bumped on every like / match so the Liked You list can reload itself.
  final likesVersion = 0.obs;

  /// Set to ask HomeScreen to switch tabs; HomeScreen clears it.
  final requestedTab = Rxn<int>();

  Rx<SocketStatus> get socketStatus => _socket.status;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Worker? _statusWorker;
  bool _started = false;
  int _page = 1;

  static const int _pageSize = 30;

  @override
  void onInit() {
    super.onInit();
    NotificationService.instance.setTapHandler(_onSystemNotificationTap);
  }

  @override
  void onClose() {
    stop();
    NotificationService.instance.setTapHandler(null);
    super.onClose();
  }

  /// Called once the user is signed in and on the home screen.
  void start() {
    if (_started) {
      _socket.ensureConnected();
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);

    _subscriptions.addAll([
      _socket.on('notification').listen(_onNotificationEvent),
      _socket.on('notification_count').listen(_onCountEvent),
      _socket.on('match_removed').listen(_onMatchRemoved),
      _socket
          .on(RealtimeSocketService.accountUnavailableEvent)
          .listen(_onAccountSuspended),
    ]);

    // Whatever arrived while disconnected is fetched again on reconnect.
    _statusWorker = ever<SocketStatus>(_socket.status, (status) {
      if (status == SocketStatus.connected) refreshUnreadCount();
    });

    _socket.connect();
    loadNotifications();
    // Lets notifications reach the phone while the app is closed.
    PushService.instance.register();
  }

  /// Logout: drop the socket and everything belonging to the old session.
  Future<void> stop() async {
    if (_started) WidgetsBinding.instance.removeObserver(this);
    _started = false;
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _statusWorker?.dispose();
    _statusWorker = null;
    await _socket.disconnect();
    notifications.clear();
    unreadCount.value = 0;
    newLikes.value = 0;
    hasMore.value = false;
    errorMessage.value = '';
    _page = 1;
    await NotificationService.instance.clearAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _started) {
      _socket.ensureConnected();
      refreshUnreadCount();
    }
  }

  // ---------------------------------------------------------------- loading

  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _inbox.getNotifications(page: 1, limit: _pageSize);
      if (response.success && response.data != null) {
        final page = response.data!;
        notifications.assignAll(page.notifications);
        unreadCount.value = page.unreadCount;
        hasMore.value = page.hasMore;
        _page = 1;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load notifications';
      }
    } catch (e) {
      errorMessage.value = 'Could not load notifications';
      _logger.e('Load notifications error', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final response = await _inbox.getNotifications(
        page: _page + 1,
        limit: _pageSize,
      );
      if (response.success && response.data != null) {
        final page = response.data!;
        final known = notifications.map((n) => n.id).toSet();
        notifications.addAll(
          page.notifications.where((n) => !known.contains(n.id)),
        );
        hasMore.value = page.hasMore;
        _page = page.page;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshUnreadCount() async {
    final response = await _inbox.getUnreadCount();
    if (response.success && response.data != null) {
      unreadCount.value = response.data!;
    }
  }

  // ---------------------------------------------------------------- actions

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    _replace(notification.copyWith(isRead: true));
    if (unreadCount.value > 0) unreadCount.value--;
    await _inbox.markRead(notification.id);
  }

  Future<void> markAllRead() async {
    notifications.assignAll(
      notifications.map((n) => n.isRead ? n : n.copyWith(isRead: true)),
    );
    unreadCount.value = 0;
    await _inbox.markAllRead();
  }

  Future<void> delete(AppNotification notification) async {
    notifications.removeWhere((n) => n.id == notification.id);
    if (!notification.isRead && unreadCount.value > 0) unreadCount.value--;
    await _inbox.delete(notification.id);
  }

  Future<void> clearAll() async {
    notifications.clear();
    unreadCount.value = 0;
    hasMore.value = false;
    await _inbox.clearAll();
    await NotificationService.instance.clearAll();
  }

  void onLikedYouOpened() => newLikes.value = 0;

  void _replace(AppNotification updated) {
    final index = notifications.indexWhere((n) => n.id == updated.id);
    if (index != -1) notifications[index] = updated;
  }

  // ----------------------------------------------------------------- events

  void _onNotificationEvent(Map<String, dynamic> data) {
    final raw = data['notification'];
    if (raw is! Map) return;
    final notification = AppNotification.fromJson(
      raw.map((key, value) => MapEntry(key.toString(), value)),
    );

    // A chat notification replaces the earlier unread one for that chat.
    if (notification.type == NotificationType.chat) {
      notifications.removeWhere(
        (n) =>
            n.type == NotificationType.chat &&
            !n.isRead &&
            n.conversationId == notification.conversationId,
      );
    }
    notifications.removeWhere((n) => n.id == notification.id);
    notifications.insert(0, notification);

    final count = int.tryParse('${data['unreadCount'] ?? ''}');
    if (count != null) unreadCount.value = count;

    _applySideEffects(notification);
    if (_shouldShowBanner(notification)) {
      NotificationService.instance.show(notification);
    }
  }

  void _onCountEvent(Map<String, dynamic> data) {
    final count = int.tryParse('${data['unreadCount'] ?? ''}');
    if (count == null) return;
    unreadCount.value = count;
    if (count == 0) {
      notifications.assignAll(
        notifications.map((n) => n.isRead ? n : n.copyWith(isRead: true)),
      );
    }
  }

  void _applySideEffects(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.match:
        likesVersion.value++;
        if (Get.isRegistered<SwipeController>() &&
            !Get.isPrepared<SwipeController>()) {
          Get.find<SwipeController>().getMatches(refresh: true);
        }
        break;
      case NotificationType.like:
      case NotificationType.superLike:
        newLikes.value++;
        likesVersion.value++;
        break;
      case NotificationType.profile:
        if (Get.isRegistered<UserController>() &&
            !Get.isPrepared<UserController>()) {
          Get.find<UserController>().refreshProfile();
        }
        break;
    }
  }

  bool _shouldShowBanner(AppNotification notification) {
    final inForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    // In the background the push shows it; a banner here would be a duplicate.
    if (!inForeground && PushService.instance.isActive) return false;

    if (notification.type == NotificationType.chat && inForeground) {
      // Already looking at this conversation.
      final chat = Get.isRegistered<ChatController>() &&
              !Get.isPrepared<ChatController>()
          ? Get.find<ChatController>()
          : null;
      if (chat?.currentConversation.value?.id == notification.conversationId) {
        return false;
      }
    }

    // The person who made the match is already looking at the match screen.
    if (notification.type == NotificationType.match &&
        inForeground &&
        notification.metadata['initiatedByYou'] == true) {
      return false;
    }
    return true;
  }

  void _onMatchRemoved(Map<String, dynamic> data) {
    final userId = data['userId']?.toString() ?? '';
    if (userId.isEmpty) return;
    if (Get.isRegistered<SwipeController>() &&
        !Get.isPrepared<SwipeController>()) {
      Get.find<SwipeController>()
          .matches
          .removeWhere((match) => match.matchedUser?.id == userId);
    }
    likesVersion.value++;
  }

  Future<void> _onAccountSuspended(Map<String, dynamic> data) async {
    final message = data['message']?.toString().isNotEmpty == true
        ? data['message'].toString()
        : 'This account is no longer available.';
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().logout();
    } else {
      await stop();
    }
    AppRoutes.toOnboarding();
    Get.snackbar(
      'Signed out',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // ------------------------------------------------------------- navigation

  void _onSystemNotificationTap(Map<String, dynamic> payload) {
    final meta = payload['metadata'];
    final notification = AppNotification.fromJson({
      'id': payload['id'],
      'type': payload['type'],
      'metadata': meta is Map ? meta : const {},
      'createdAt': DateTime.now().toIso8601String(),
    });
    // Wait for the first frame on a cold start so navigation has a navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      open(notification, fromSystemTray: true);
    });
  }

  /// Takes the user to whatever the notification is about.
  Future<void> open(
    AppNotification notification, {
    bool fromSystemTray = false,
  }) async {
    if (notification.id.isNotEmpty) {
      final known = notifications.firstWhereOrNull(
        (n) => n.id == notification.id,
      );
      if (known != null) {
        await markRead(known);
      } else if (fromSystemTray) {
        await _inbox.markRead(notification.id);
        refreshUnreadCount();
      }
    }

    switch (notification.type) {
      case NotificationType.chat:
        _openChat(
          notification.conversationId,
          notification.actorName,
          notification.actorPhoto,
        );
        break;
      case NotificationType.match:
        await _openChatWith(
          notification.actorId,
          notification.actorName,
          notification.actorPhoto,
        );
        break;
      case NotificationType.like:
      case NotificationType.superLike:
        _goToTab(HomeTab.likedYou);
        break;
      default:
        if (fromSystemTray) {
          _backToHome();
          Get.to(() => const NotificationsCenterScreen());
        }
    }
  }

  void _backToHome() {
    var homeInStack = false;
    Get.until((route) {
      if (route.settings.name == AppRoutes.home) homeInStack = true;
      return route.settings.name == AppRoutes.home || route.isFirst;
    });
    if (!homeInStack && Get.currentRoute != AppRoutes.home) {
      AppRoutes.toHome();
    }
  }

  void _goToTab(int tab) {
    _backToHome();
    requestedTab.value = tab;
  }

  void _openChat(String conversationId, String name, String photo) {
    if (conversationId.isEmpty) {
      _goToTab(HomeTab.chat);
      return;
    }
    _goToTab(HomeTab.chat);
    Get.to(
      () => ChatScreen(
        chatId: conversationId,
        name: name.isNotEmpty ? name : 'Chat',
        image: photo.isNotEmpty ? photo : 'assets/images/profile.png',
      ),
    );
  }

  Future<void> _openChatWith(String userId, String name, String photo) async {
    if (userId.isEmpty || !Get.isRegistered<ChatController>()) {
      _goToTab(HomeTab.chat);
      return;
    }
    final conversation =
        await Get.find<ChatController>().createChat(recipientId: userId);
    if (conversation == null) {
      _goToTab(HomeTab.likedYou);
      return;
    }
    _openChat(
      conversation.id,
      conversation.otherUserName.isNotEmpty ? conversation.otherUserName : name,
      conversation.otherUserImage.isNotEmpty
          ? conversation.otherUserImage
          : photo,
    );
  }
}
