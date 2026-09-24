import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/chat_realtime_service.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Chat Controller
/// Manages chat, messaging, and conversation state
class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatRealtimeService _realtime = ChatRealtimeService();
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
  final messageController = Rx<TextEditingController>(TextEditingController());

  String get currentUserId => _authService.getCurrentUserId() ?? '';

  static const int PAGE_SIZE = 50;
  int _messagePage = 1;
  Timer? _pollTimer;
  Timer? _typingDebounce;

  @override
  void onInit() {
    super.onInit();
    getConversations();
    _bootstrapRealtime();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _typingDebounce?.cancel();
    _realtime.disposeAll();
    messageController.value.dispose();
    super.onClose();
  }

  Future<void> _bootstrapRealtime() async {
    await _realtime.initialize();
    realtimeConnected.value = _realtime.isEnabled;
    final userId = currentUserId;
    if (userId.isEmpty) return;

    if (_realtime.isEnabled) {
      await _realtime.subscribeUserInbox(
        userId: userId,
        onEvent: _onInboxEvent,
      );
    } else if (_chatListVisible) {
      _startPolling();
    }
  }

  bool _chatListVisible = false;

  /// Without realtime, polling runs only while the chat list or a thread is on screen.
  void setChatListVisible(bool visible) {
    _chatListVisible = visible;
    if (_realtime.isEnabled) return;
    final threadOpen = currentConversation.value?.id.isNotEmpty ?? false;
    if (visible || threadOpen) {
      if (visible) getConversations(refresh: true, silent: true);
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final openId = currentConversation.value?.id;
      if (openId != null && openId.isNotEmpty) {
        await _refreshOpenConversationQuietly(openId);
      } else {
        await getConversations(refresh: true, silent: true);
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _refreshOpenConversationQuietly(String chatId) async {
    final response = await _chatService.getMessages(chatId, page: 1, limit: PAGE_SIZE);
    if (!response.success || response.data == null) return;

    final incoming = response.data!.messages;
    for (final msg in incoming) {
      _upsertMessage(msg);
    }
    _sortMessages();
  }

  void _onInboxEvent(String event, Map<String, dynamic> payload) {
    if (event != 'conversation_updated') return;

    final conversationId = payload['conversationId']?.toString() ?? '';
    if (conversationId.isEmpty) return;

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

    final nested = payload['message'];
    if (isOpen && nested is Map) {
      final msg = ChatMessageModel.fromJson(
        nested.map((key, value) => MapEntry(key.toString(), value)),
      );
      _upsertMessage(msg);
      _sortMessages();
      markConversationAsRead(conversationId);
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
      messages[existingIdx] = msg;
      return;
    }

    // Replace optimistic temp bubble with the real message.
    final tempIdx = messages.indexWhere(
      (m) =>
          m.id.startsWith('temp_') &&
          m.senderId == msg.senderId &&
          m.message == msg.message,
    );
    if (tempIdx != -1) {
      messages[tempIdx] = msg;
      return;
    }

    messages.add(msg);
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
    _stopPolling();
    _realtime.disposeAll();
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

    await _realtime.subscribeConversation(
      conversationId: chatId,
      currentUserId: currentUserId,
      onMessage: (payload) {
        if (payload['id'] == null) return;
        final msg = ChatMessageModel.fromJson(payload);
        if (msg.conversationId.isNotEmpty && msg.conversationId != chatId) {
          return;
        }
        _upsertMessage(msg);
        _sortMessages();
        _updateConversationPreview(chatId, msg.message, msg.timestamp);
        markConversationAsRead(chatId);
      },
      onTyping: (userId) {
        isTyping.value = userId.isNotEmpty;
      },
      onRead: (payload) {
        final readerId = payload['userId']?.toString() ?? '';
        if (readerId.isEmpty || readerId == currentUserId) return;
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          if (m.senderId == currentUserId && !m.isRead) {
            messages[i] = m.copyWith(isRead: true, status: MessageStatus.read);
          }
        }
      },
    );

    if (!_realtime.isEnabled) {
      _startPolling();
    }

    return true;
  }

  Future<void> leaveConversation() async {
    isTyping.value = false;
    await _realtime.unsubscribeConversation();
    clearCurrentConversation();
    if (!_realtime.isEnabled) {
      _chatListVisible ? _startPolling() : _stopPolling();
    }
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
    if (trimmed.length > AppConstants.maxChatMessageLength) {
      errorMessage.value =
          'Message must be at most ${AppConstants.maxChatMessageLength} characters';
      return false;
    }

    final optimisticMsg = ChatMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: chatId,
      senderId: currentUserId,
      senderName: 'Me',
      senderImage: '',
      message: trimmed,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    messages.add(optimisticMsg);
    messageController.value.clear();

    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.sendMessage(chatId, trimmed);

      if (response.success && response.data != null) {
        _upsertMessage(response.data!);
        _sortMessages();
        _updateConversationPreview(chatId, trimmed, DateTime.now());
        return true;
      }

      messages.removeWhere((m) => m.id == optimisticMsg.id);
      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'Message could not be sent';
      return false;
    } catch (e) {
      messages.removeWhere((m) => m.id == optimisticMsg.id);
      errorMessage.value = 'Message could not be sent';
      _logger.e('Send message error', error: e);
      return false;
    } finally {
      isSending.value = false;
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
      await _chatService.markConversationAsRead(chatId);

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
