import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/services/notification_service.dart';
import 'package:dating_app/services/realtime_socket_service.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/content_moderation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Chat Controller
/// Manages chat, messaging, and conversation state
class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final RealtimeSocketService _socket = RealtimeSocketService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  // Observable state variables
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final isLoadingOlder = false.obs;
  final conversations = <ConversationModel>[].obs;
  final currentConversation = Rx<ConversationModel?>(null);
  final messages = <ChatMessageModel>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isSending = false.obs;
  final isTyping = false.obs;
  final realtimeConnected = false.obs;
  final unreadCount = 0.obs;
  final hasMoreMessages = false.obs;
  /// Set when the open chat ends (unmatch or block) so the screen can close.
  final closedConversationId = ''.obs;
  final messageController = Rx<TextEditingController>(TextEditingController());

  String get currentUserId => _authService.getCurrentUserId() ?? '';

  static const int PAGE_SIZE = 50;
  int _messagePage = 1;
  static const Duration _ackTimeout = Duration(seconds: 8);
  final Random _random = Random();
  // Sends waiting for the server's `message_ack`, keyed by clientId.
  final Map<String, Completer<Map<String, dynamic>?>> _pendingAcks = {};
  bool _catchingUp = false;
  Timer? _typingDebounce;
  Timer? _typingClearTimer;
  final List<StreamSubscription<dynamic>> _socketSubscriptions = [];
  Worker? _socketStatusWorker;

  @override
  void onInit() {
    super.onInit();
    // Created at app start; before login there is nothing to load. The chat
    // list loads itself once shown, and again whenever the socket connects.
    if (_authService.isLoggedIn()) getConversations();
    _bindRealtime();
  }

  @override
  void onClose() {
    _failPendingAcks();
    _typingDebounce?.cancel();
    _typingClearTimer?.cancel();
    for (final sub in _socketSubscriptions) {
      sub.cancel();
    }
    _socketStatusWorker?.dispose();
    messageController.value.dispose();
    super.onClose();
  }

  /// The socket is opened by NotificationController (with the user's access
  /// token); all chat traffic rides on it. There is no polling: when the
  /// socket comes back, whatever was missed is fetched once.
  void _bindRealtime() {
    realtimeConnected.value = _socket.isConnected;
    _socketSubscriptions.addAll([
      _socket.on('conversation_updated').listen(_onInboxEvent),
      _socket.on('new_message').listen(_onNewMessage),
      _socket.on('message_ack').listen(_onMessageAck),
      _socket.on('typing').listen(_onTyping),
      _socket.on('messages_delivered').listen(_onDelivered),
      _socket.on('messages_read').listen(_onRead),
      _socket.on('presence').listen(_onPresence),
      _socket.on('conversation_removed').listen(_onConversationRemoved),
      _socket.on('match_removed').listen(_onMatchRemoved),
    ]);
    _socketStatusWorker = ever<SocketStatus>(_socket.status, (status) {
      final connected = status == SocketStatus.connected;
      if (connected == realtimeConnected.value) return;
      realtimeConnected.value = connected;
      if (connected) {
        _catchUp();
      } else {
        // Sends in flight fall back to REST instead of waiting for a timeout.
        _failPendingAcks();
      }
    });
  }

  /// Refreshes the chat list and the open thread after a reconnect.
  Future<void> _catchUp() async {
    if (_catchingUp) return;
    _catchingUp = true;
    try {
      await getConversations(refresh: true, silent: true);
      final openId = currentConversation.value?.id;
      if (openId != null && openId.isNotEmpty) {
        await _catchUpOpenConversation(openId);
      }
    } finally {
      _catchingUp = false;
    }
  }

  void setChatListVisible(bool visible) {
    // Live updates keep the list current; only refresh when they're down.
    if (visible && !_socket.isConnected) {
      getConversations(refresh: true, silent: true);
    }
  }

  /// Fetches only the messages newer than the last one we have.
  Future<void> _catchUpOpenConversation(String chatId) async {
    String? lastId;
    for (final m in messages.reversed) {
      if (m.id.isNotEmpty && !m.id.startsWith('temp_')) {
        lastId = m.id;
        break;
      }
    }
    final response = await _chatService.getMessages(
      chatId,
      page: 1,
      limit: PAGE_SIZE,
      afterMessageId: lastId,
    );
    if (!response.success || response.data == null) return;
    if (currentConversation.value?.id != chatId) return;

    if (lastId != null && response.data!.hasMore) {
      // Too much was missed to patch in; reload the latest page.
      await getMessages(chatId);
    } else {
      for (final msg in response.data!.messages) {
        _upsertMessage(msg);
      }
      _sortMessages();
    }
    final last = messages.lastOrNull;
    if (last != null && last.senderId != currentUserId) {
      markConversationAsRead(chatId);
    }
  }

  void _onMessageAck(Map<String, dynamic> payload) {
    final clientId = payload['clientId']?.toString() ?? '';
    final pending = _pendingAcks.remove(clientId);
    if (pending != null && !pending.isCompleted) pending.complete(payload);
  }

  void _failPendingAcks() {
    final pending = Map.of(_pendingAcks);
    _pendingAcks.clear();
    for (final completer in pending.values) {
      if (!completer.isCompleted) completer.complete(null);
    }
  }

  void _onConversationRemoved(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId']?.toString() ?? '';
    if (conversationId.isEmpty) return;
    _dropConversation((c) => c.id == conversationId);
  }

  void _onMatchRemoved(Map<String, dynamic> payload) {
    final userId = payload['userId']?.toString() ?? '';
    if (userId.isEmpty) return;
    _dropConversation((c) => c.otherUserId == userId);
  }

  void _dropConversation(bool Function(ConversationModel) test) {
    final ids = conversations.where(test).map((c) => c.id).toSet();
    final current = currentConversation.value;
    if (current != null && test(current)) ids.add(current.id);
    if (ids.isEmpty) return;

    conversations.removeWhere((c) => ids.contains(c.id));
    _recomputeUnread();
    for (final id in ids) {
      NotificationService.instance.clearConversation(id);
    }
    if (current != null && ids.contains(current.id)) {
      closedConversationId.value = current.id;
    }
  }

  void _onInboxEvent(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId']?.toString() ?? '';
    if (conversationId.isEmpty) return;

    // Read on another device (or here): that chat has nothing unread.
    final readerId = payload['readerId']?.toString() ?? '';
    if (readerId.isNotEmpty) {
      if (readerId == currentUserId) {
        final idx = conversations.indexWhere((c) => c.id == conversationId);
        if (idx != -1) {
          conversations[idx] = conversations[idx].copyWith(unreadCount: 0);
          _recomputeUnread();
        }
        NotificationService.instance.clearConversation(conversationId);
      }
      return;
    }

    final lastMessage = payload['lastMessage']?.toString() ?? '';
    final lastMessageAtRaw = payload['lastMessageAt'];
    DateTime? lastMessageAt;
    if (lastMessageAtRaw != null) {
      lastMessageAt = DateTime.tryParse(lastMessageAtRaw.toString())?.toLocal();
    }

    final openId = currentConversation.value?.id;
    final isOpen = openId == conversationId;
    final unreadDelta = (payload['unreadDelta'] as num?)?.toInt() ?? 0;

    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final existing = conversations[idx];
      conversations[idx] = existing.copyWith(
        lastMessage: lastMessage.isNotEmpty ? lastMessage : existing.lastMessage,
        lastMessageTime: lastMessageAt ?? existing.lastMessageTime,
        unreadCount: isOpen
            ? 0
            : existing.unreadCount + (unreadDelta > 0 ? unreadDelta : 0),
      );
      _moveConversationToTop(idx);
    } else {
      getConversations(refresh: true, silent: true);
    }

    _recomputeUnread();
    // The open thread itself is updated by `new_message`; system banners
    // come from NotificationController.
  }

  void _onNewMessage(Map<String, dynamic> payload) {
    final chatId = currentConversation.value?.id;
    if (chatId == null || chatId.isEmpty || payload['id'] == null) return;
    final msg = ChatMessageModel.fromJson(payload);
    if (msg.conversationId != chatId) return;

    _upsertMessage(msg);
    _sortMessages();
    _updateConversationPreview(chatId, msg.message, msg.timestamp);
    if (msg.senderId != currentUserId) {
      isTyping.value = false;
      markConversationAsRead(chatId);
    }
  }

  void _onTyping(Map<String, dynamic> payload) {
    final chatId = currentConversation.value?.id;
    if (chatId == null || payload['conversationId']?.toString() != chatId) {
      return;
    }
    final typerId = payload['userId']?.toString() ?? '';
    if (typerId.isEmpty || typerId == currentUserId) return;
    isTyping.value = true;
    _typingClearTimer?.cancel();
    _typingClearTimer = Timer(
      AppConstants.typingIndicatorDuration,
      () => isTyping.value = false,
    );
  }

  void _onDelivered(Map<String, dynamic> payload) {
    final chatId = currentConversation.value?.id;
    if (chatId == null || payload['conversationId']?.toString() != chatId) {
      return;
    }
    final delivererId = payload['userId']?.toString() ?? '';
    if (delivererId.isEmpty || delivererId == currentUserId) return;
    final ids = (payload['messageIds'] as List?)
            ?.map((e) => e.toString())
            .where((id) => id.isNotEmpty)
            .toSet() ??
        <String>{};
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.senderId != currentUserId) continue;
      if (ids.isNotEmpty && !ids.contains(m.id)) continue;
      if (m.status == MessageStatus.sending || m.status == MessageStatus.sent) {
        messages[i] = m.copyWith(status: MessageStatus.delivered);
      }
    }
  }

  void _onRead(Map<String, dynamic> payload) {
    final chatId = currentConversation.value?.id;
    if (chatId == null || payload['conversationId']?.toString() != chatId) {
      return;
    }
    final readerId = payload['userId']?.toString() ?? '';
    if (readerId.isEmpty || readerId == currentUserId) return;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.senderId == currentUserId && m.status != MessageStatus.read) {
        messages[i] = m.copyWith(isRead: true, status: MessageStatus.read);
      }
    }
  }

  void _onPresence(Map<String, dynamic> payload) {
    final userId = payload['userId']?.toString() ?? '';
    if (userId.isEmpty) return;
    final isOnline = payload['isOnline'] == true;
    final lastActive =
        DateTime.tryParse(payload['lastActive']?.toString() ?? '')?.toLocal();

    for (var i = 0; i < conversations.length; i++) {
      if (conversations[i].otherUserId != userId) continue;
      conversations[i] = conversations[i].copyWith(
        isOnline: isOnline,
        lastSeenTime: lastActive ?? conversations[i].lastSeenTime,
      );
    }
    final current = currentConversation.value;
    if (current != null && current.otherUserId == userId) {
      currentConversation.value = current.copyWith(
        isOnline: isOnline,
        lastSeenTime: lastActive ?? current.lastSeenTime,
      );
    }
  }

  void _moveConversationToTop(int idx) {
    if (idx <= 0) return;
    final item = conversations.removeAt(idx);
    conversations.insert(0, item);
  }

  void _recomputeUnread() {
    unreadCount.value =
        conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
  }

  void _upsertMessage(ChatMessageModel msg) {
    if (msg.id.isEmpty) return;
    final existingIdx = messages.indexWhere((m) => m.id == msg.id);
    if (existingIdx != -1) {
      final existing = messages[existingIdx];
      messages[existingIdx] = _statusRank(msg.status) >= _statusRank(existing.status)
          ? msg
          : msg.copyWith(status: existing.status, isRead: existing.isRead);
      return;
    }

    // Replace the optimistic bubble with the saved message.
    final clientId = msg.clientId ?? '';
    final tempIdx = messages.indexWhere(
      (m) =>
          m.id.startsWith('temp_') &&
          (clientId.isNotEmpty
              ? m.clientId == clientId
              : m.senderId == msg.senderId && m.message == msg.message),
    );
    if (tempIdx != -1) {
      messages[tempIdx] = msg;
      return;
    }

    messages.add(msg);
  }

  int _statusRank(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 0;
      case MessageStatus.sent:
        return 1;
      case MessageStatus.delivered:
        return 2;
      case MessageStatus.read:
        return 3;
    }
  }

  void _sortMessages() {
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<bool> getConversations({
    bool refresh = false,
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        isLoading.value = true;
        errorMessage.value = '';
      }

      final conversationsFuture = _chatService.getConversations();
      final blockListFuture =
          silent ? Future.value(true) : _userController.getBlockedUsers();
      final response = await conversationsFuture;
      final blockListLoaded = await blockListFuture;

      if (response.success && response.data != null) {
        final blockedIds = _userController.blockedUsers.toSet();
        conversations.value = response.data!
            .where((c) => !blockedIds.contains(c.otherUserId))
            .toList();
        if (!blockListLoaded) {
          _logger.w('Block list unavailable — chat list may include blocked users');
        }
      } else if (!silent) {
        conversations.clear();
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load conversations';
      }

      _recomputeUnread();
      return response.success;
    } catch (e) {
      if (!silent) {
        errorMessage.value = 'Failed to load conversations';
        conversations.clear();
      }
      _logger.e('Get conversations error', error: e);
      return false;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  UserController get _userController => Get.find<UserController>();

  bool isChatBlocked(String chatId) {
    final conv = currentConversation.value?.id == chatId
        ? currentConversation.value
        : conversations.firstWhereOrNull((c) => c.id == chatId);
    if (conv == null) return false;
    return conv.isBlocked ||
        _userController.blockedUsers.contains(conv.otherUserId);
  }

  void resetSession() {
    _failPendingAcks();
    _typingClearTimer?.cancel();
    closedConversationId.value = '';
    conversations.clear();
    messages.clear();
    currentConversation.value = null;
    chatUsers.clear();
    unreadCount.value = 0;
    errorMessage.value = '';
    successMessage.value = '';
    isLoading.value = false;
    isLoadingMessages.value = false;
    isSending.value = false;
    isTyping.value = false;
    hasMoreMessages.value = false;
    _messagePage = 1;
  }

  Future<bool> openConversation(String chatId) async {
    final ok = await getConversation(chatId);
    if (!ok) return false;

    NotificationService.instance.clearConversation(chatId);
    // Online status and new messages arrive over the socket from here on.
    return true;
  }

  Future<void> leaveConversation() async {
    _typingClearTimer?.cancel();
    isTyping.value = false;
    clearCurrentConversation();
  }

  Future<bool> getConversation(String chatId) async {
    try {
      isLoadingMessages.value = true;
      errorMessage.value = '';
      _messagePage = 1;

      final response = await _chatService.getConversation(chatId);

      if (response.success && response.data != null) {
        currentConversation.value = response.data;
        messages.value = List<ChatMessageModel>.from(response.data!.messages);
        _sortMessages();
        hasMoreMessages.value = messages.length >= PAGE_SIZE;

        if (messages.isEmpty) {
          await getMessages(chatId);
        }

        await markConversationAsRead(chatId);
        return true;
      }

      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'Failed to load conversation';
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to load conversation';
      _logger.e('Get conversation error', error: e);
      return false;
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<bool> getMessages(String chatId, {int page = 1}) async {
    try {
      errorMessage.value = '';

      final response = await _chatService.getMessages(
        chatId,
        page: page,
        limit: PAGE_SIZE,
      );

      if (response.success && response.data != null) {
        final pageData = response.data!;
        if (page <= 1) {
          messages.value = List<ChatMessageModel>.from(pageData.messages);
        } else {
          final existingIds = messages.map((m) => m.id).toSet();
          final older = pageData.messages
              .where((m) => !existingIds.contains(m.id))
              .toList();
          messages.insertAll(0, older);
        }
        _sortMessages();
        _messagePage = pageData.page;
        hasMoreMessages.value = pageData.hasMore;
        return true;
      }

      errorMessage.value = response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to load messages';
      _logger.e('Get messages error', error: e);
      return false;
    }
  }

  Future<bool> loadOlderMessages(String chatId) async {
    if (isLoadingOlder.value || !hasMoreMessages.value) return false;
    try {
      isLoadingOlder.value = true;
      return await getMessages(chatId, page: _messagePage + 1);
    } finally {
      isLoadingOlder.value = false;
    }
  }

  Future<bool> sendMessage(String chatId, String messageText) async {
    if (messageText.trim().isEmpty) return false;

    final trimmed = messageText.trim();
    final abusive = ContentModeration.abusiveWarning(trimmed);
    if (abusive != null) {
      errorMessage.value = abusive;
      return false;
    }

    if (trimmed.length > AppConstants.maxChatMessageLength) {
      errorMessage.value =
          'Message must be at most ${AppConstants.maxChatMessageLength} characters';
      return false;
    }

    messageController.value.clear();
    return _deliver(chatId, message: trimmed);
  }

  /// Uploads a photo, then sends it as a message.
  Future<bool> sendPhoto(String chatId, String filePath) async {
    final clientId = _newClientId();
    final placeholder = _optimistic(chatId, clientId, message: '');
    messages.add(placeholder);

    final response = await _chatService.uploadChatMedia(chatId, filePath);
    final url = response.data ?? '';
    if (!response.success || url.isEmpty) {
      messages.removeWhere((m) => m.id == placeholder.id);
      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'Photo could not be uploaded';
      return false;
    }
    return _deliver(
      chatId,
      message: '',
      attachmentUrl: url,
      clientId: clientId,
      optimisticAdded: true,
    );
  }

  // 0x7fffffff, not 1 << 32: on web, ints are 32-bit for shifts and
  // `1 << 32` is 0, which nextInt rejects (every send crashed).
  String _newClientId() =>
      'c${DateTime.now().microsecondsSinceEpoch}${_random.nextInt(0x7fffffff)}';

  ChatMessageModel _optimistic(
    String chatId,
    String clientId, {
    required String message,
    String? attachmentUrl,
  }) {
    return ChatMessageModel(
      id: 'temp_$clientId',
      conversationId: chatId,
      senderId: currentUserId,
      senderName: 'Me',
      senderImage: '',
      message: message,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentUrl != null ? 'image' : null,
      clientId: clientId,
    );
  }

  /// Sends over the socket and waits for the server's ack. If the socket is
  /// down or the ack doesn't come, the same message goes over REST; the
  /// clientId makes the server store it only once.
  Future<bool> _deliver(
    String chatId, {
    required String message,
    String? attachmentUrl,
    String? clientId,
    bool optimisticAdded = false,
  }) async {
    final id = clientId ?? _newClientId();
    final tempId = 'temp_$id';
    if (!optimisticAdded) {
      messages.add(_optimistic(chatId, id, message: message));
    }

    try {
      isSending.value = true;
      errorMessage.value = '';

      ChatMessageModel? saved;
      String? failure;

      final ack = await _sendOverSocket(chatId, id, message, attachmentUrl);
      if (ack != null && ack['ok'] == true && ack['message'] is Map) {
        saved = ChatMessageModel.fromJson(
          Map<String, dynamic>.from(ack['message'] as Map),
        );
      } else if (ack != null && ack['ok'] == false) {
        final status = (ack['status'] as num?)?.toInt() ?? 0;
        failure = ack['error']?.toString();
        if (status == 403 || status == 404) {
          _dropConversation((c) => c.id == chatId);
        }
        if (status >= 500) failure = null; // retry over REST below
      }

      if (saved == null && failure == null) {
        final response = await _chatService.sendMessage(
          chatId,
          message,
          attachmentUrl: attachmentUrl,
          attachmentType: attachmentUrl != null ? 'image' : null,
          clientId: id,
        );
        if (response.success && response.data != null) {
          saved = response.data;
        } else {
          failure = response.message;
          if (response.statusCode == 403 || response.statusCode == 404) {
            _dropConversation((c) => c.id == chatId);
          }
        }
      }

      if (saved != null) {
        _upsertMessage(saved.clientId == null ? saved.copyWith(clientId: id) : saved);
        _sortMessages();
        _updateConversationPreview(
          chatId,
          saved.message.isNotEmpty ? saved.message : '📷 Photo',
          saved.timestamp,
        );
        return true;
      }

      messages.removeWhere((m) => m.id == tempId);
      errorMessage.value = (failure != null && failure.isNotEmpty)
          ? failure
          : 'Message could not be sent';
      return false;
    } catch (e) {
      messages.removeWhere((m) => m.id == tempId);
      errorMessage.value = 'Message could not be sent';
      _logger.e('Send message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Null when the socket is down or the server didn't answer in time.
  Future<Map<String, dynamic>?> _sendOverSocket(
    String chatId,
    String clientId,
    String message,
    String? attachmentUrl,
  ) async {
    if (!_socket.isConnected) return null;
    final completer = Completer<Map<String, dynamic>?>();
    _pendingAcks[clientId] = completer;
    final sent = _socket.send('send_message', {
      'conversationId': chatId,
      'clientId': clientId,
      'message': message,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentUrl != null) 'attachmentType': 'image',
    });
    if (!sent) {
      _pendingAcks.remove(clientId);
      return null;
    }
    try {
      return await completer.future.timeout(_ackTimeout);
    } on TimeoutException {
      return null;
    } finally {
      _pendingAcks.remove(clientId);
    }
  }

  void _updateConversationPreview(
    String chatId,
    String lastMessage,
    DateTime at,
  ) {
    final convIdx = conversations.indexWhere((c) => c.id == chatId);
    if (convIdx == -1) return;
    conversations[convIdx] = conversations[convIdx].copyWith(
      lastMessage: lastMessage,
      lastMessageTime: at,
      unreadCount: currentConversation.value?.id == chatId
          ? 0
          : conversations[convIdx].unreadCount,
    );
    _moveConversationToTop(convIdx);
    _recomputeUnread();
  }

  Future<bool> markConversationAsRead(String chatId) async {
    try {
      if (!_socket.send('mark_read', {'conversationId': chatId})) {
        await _chatService.markConversationAsRead(chatId);
      }

      final index = conversations.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        conversations[index] = conversations[index].copyWith(unreadCount: 0);
      }
      _recomputeUnread();
      return true;
    } catch (e) {
      _logger.e('Mark read error', error: e);
      return false;
    }
  }

  Future<bool> deleteMessage(String chatId, String messageId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      await _chatService.deleteMessage(chatId, messageId);
      messages.removeWhere((m) => m.id == messageId);
      successMessage.value = 'Message deleted';
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete message';
      _logger.e('Delete message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<String?> uploadChatMedia(String chatId, String filePath) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.uploadChatMedia(chatId, filePath);

      if (response.success && response.data != null) {
        return response.data;
      }
      errorMessage.value = response.message;
      return null;
    } catch (e) {
      errorMessage.value = 'Failed to upload media';
      _logger.e('Upload media error', error: e);
      return null;
    } finally {
      isSending.value = false;
    }
  }

  void onComposerChanged(String chatId, String text) {
    if (chatId.isEmpty || text.trim().isEmpty) return;
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 600), () {
      sendTypingIndicator(chatId);
    });
  }

  Future<void> sendTypingIndicator(String chatId) async {
    if (_socket.send('typing', {'conversationId': chatId})) return;
    try {
      await _chatService.sendTypingIndicator(chatId);
    } catch (e) {
      _logger.e('Typing indicator error', error: e);
    }
  }

  Future<bool> blockUserInChat(String chatId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final conv = currentConversation.value?.id == chatId
          ? currentConversation.value
          : conversations.firstWhereOrNull((c) => c.id == chatId);
      final otherUserId = conv?.otherUserId ?? '';
      if (otherUserId.isEmpty) {
        errorMessage.value = 'Could not identify the user to block';
        return false;
      }

      final ok = await _userController.blockUser(otherUserId);
      if (!ok) {
        errorMessage.value = _userController.errorMessage.value.isNotEmpty
            ? _userController.errorMessage.value
            : 'Failed to block user';
        return false;
      }

      successMessage.value = 'User blocked';
      conversations.removeWhere((c) => c.otherUserId == otherUserId);
      if (currentConversation.value?.otherUserId == otherUserId) {
        await leaveConversation();
      }
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to block user';
      _logger.e('Block user error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> reportMessage(String messageId, String reason) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.reportMessage(messageId, reason);

      if (response.success) {
        successMessage.value = 'Message reported successfully';
        return true;
      }
      errorMessage.value = response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to report message';
      _logger.e('Report message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  void clearCurrentConversation() {
    currentConversation.value = null;
    messages.clear();
    hasMoreMessages.value = false;
    _messagePage = 1;
  }

  Future<bool> deleteChat(String chatId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      await _chatService.deleteChat(chatId);

      conversations.removeWhere((c) => c.id == chatId);
      if (currentConversation.value?.id == chatId) {
        await leaveConversation();
      }
      successMessage.value = 'Conversation deleted';
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete conversation';
      _logger.e('Delete chat error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<ConversationModel?> createChat({
    required String recipientId,
    String? initialMessage,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.createChat(
        recipientId: recipientId,
        initialMessage: initialMessage,
      );

      if (response.success && response.data != null) {
        final conv = response.data!;
        final existingIdx = conversations.indexWhere((c) => c.id == conv.id);
        if (existingIdx == -1) {
          conversations.insert(0, conv);
        } else {
          conversations[existingIdx] = conv;
          _moveConversationToTop(existingIdx);
        }
        successMessage.value = 'Chat started';
        return conv;
      }
      errorMessage.value = response.message;
      return null;
    } catch (e) {
      errorMessage.value = 'Failed to start chat';
      _logger.e('Create chat error', error: e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateChat(
    String chatId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.updateChat(chatId, updateData);

      if (response.success && response.data != null) {
        final idx = conversations.indexWhere((c) => c.id == chatId);
        if (idx != -1) {
          conversations[idx] = response.data!;
        }
        if (currentConversation.value?.id == chatId) {
          currentConversation.value = response.data!;
        }
        successMessage.value = 'Chat updated';
        return true;
      }
      errorMessage.value = response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to update chat';
      _logger.e('Update chat error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  final chatUsers = <Map<String, dynamic>>[].obs;

  Future<bool> getChatUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getChatUsers();

      if (response.success && response.data != null) {
        chatUsers.value = response.data!;
        return true;
      }
      errorMessage.value = response.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to load chat users';
      _logger.e('Get chat users error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ConversationModel>> getChatByRecipient(
    String recipientId,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getChatByRecipient(recipientId);

      if (response.success && response.data != null) {
        return response.data!;
      }
      errorMessage.value = response.message;
      return [];
    } catch (e) {
      errorMessage.value = 'Failed to load chats for recipient';
      _logger.e('Get chat by recipient error', error: e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ConversationModel>> getChatHistory(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getChatHistory(userId);

      if (response.success && response.data != null) {
        return response.data!;
      }
      errorMessage.value = response.message;
      return [];
    } catch (e) {
      errorMessage.value = 'Failed to load chat history';
      _logger.e('Get chat history error', error: e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
