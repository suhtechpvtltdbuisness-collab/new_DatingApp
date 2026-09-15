import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Chat Controller
/// Manages chat, messaging, and conversation state
class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();

  // Observable state variables
  final isLoading = false.obs;
  final isLoadingMessages = false.obs;
  final conversations = <ConversationModel>[].obs;
  final currentConversation = Rx<ConversationModel?>(null);
  final messages = <ChatMessageModel>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isSending = false.obs;
  final isTyping = false.obs;
  final unreadCount = 0.obs;
  final messageController = Rx<TextEditingController>(TextEditingController());

  // Current logged-in user id (to determine "isMe" for messages)
  String get currentUserId => _authService.getCurrentUserId() ?? '';

  // Pagination
  static const int PAGE_SIZE = 50;

  @override
  void onInit() {
    super.onInit();
    getConversations();
  }

  @override
  void onClose() {
    messageController.value.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // Get conversations list — GET /chats, minus users the viewer has blocked
  // ---------------------------------------------------------------------------
  Future<bool> getConversations({bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // GET /chats does not exclude blocked users, so the block list from
      // GET /users/blocked is fetched alongside and applied here.
      final conversationsFuture = _chatService.getConversations();
      final blockListFuture = _userController.getBlockedUsers();
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
        _logger.i('Loaded ${conversations.length} conversations from API');
      } else {
        conversations.clear();
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load conversations';
      }

      unreadCount.value =
          conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);

      return response.success;
    } catch (e) {
      errorMessage.value = 'Failed to load conversations';
      _logger.e('Get conversations error', error: e);
      conversations.clear();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  UserController get _userController => Get.find<UserController>();

  /// Whether the other participant of [chatId] is on the viewer's block list.
  bool isChatBlocked(String chatId) {
    final conv = currentConversation.value?.id == chatId
        ? currentConversation.value
        : conversations.firstWhereOrNull((c) => c.id == chatId);
    if (conv == null) return false;
    return conv.isBlocked ||
        _userController.blockedUsers.contains(conv.otherUserId);
  }

  /// Clears everything tied to the signed-in user (called on logout).
  void resetSession() {
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
  }

  // ---------------------------------------------------------------------------
  // Get single conversation with its messages — GET /chats/:chatId
  // ---------------------------------------------------------------------------
  Future<bool> getConversation(String chatId) async {
    try {
      isLoadingMessages.value = true;
      errorMessage.value = '';

      final response = await _chatService.getConversation(chatId);

      if (response.success && response.data != null) {
        currentConversation.value = response.data;
        messages.value = response.data!.messages;
        _logger.i('Loaded conversation: $chatId');

        // If messages are empty, try fetching them separately
        if (messages.isEmpty) {
          await getMessages(chatId);
        }

        // Mark as read in the background
        _chatService.markConversationAsRead(chatId);
        return true;
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Failed to load conversation';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load conversation';
      _logger.e('Get conversation error', error: e);
      return false;
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Get messages for a conversation — GET /chats/:chatId/messages
  // ---------------------------------------------------------------------------
  Future<bool> getMessages(String chatId) async {
    try {
      errorMessage.value = '';

      final response = await _chatService.getMessages(chatId);

      if (response.success && response.data != null) {
        messages.value = response.data!;
        _logger.i('Loaded ${messages.length} messages');
        return true;
      } else {
        errorMessage.value = response.message;
        _logger.w('Get messages failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load messages';
      _logger.e('Get messages error', error: e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Send message — POST /chats/:chatId/messages
  // ---------------------------------------------------------------------------
  Future<bool> sendMessage(String chatId, String messageText) async {
    if (messageText.trim().isEmpty) return false;

    final trimmed = messageText.trim();

    // Optimistic UI — add immediately with "sending" status
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
        // Replace optimistic message with real one from server
        final idx = messages.indexWhere((m) => m.id == optimisticMsg.id);
        if (idx != -1) {
          messages[idx] = response.data!;
        }

        // Update conversation last message
        final convIdx = conversations.indexWhere((c) => c.id == chatId);
        if (convIdx != -1) {
          conversations[convIdx] = conversations[convIdx].copyWith(
            lastMessage: trimmed,
            lastMessageTime: DateTime.now(),
          );
        }

        _logger.i('Message sent successfully');
        return true;
      } else {
        // Not delivered (e.g. the other user blocked this account) — drop the
        // optimistic bubble instead of pretending it was sent.
        messages.removeWhere((m) => m.id == optimisticMsg.id);
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Message could not be sent';
        _logger.w('Send message API failed: ${response.error}');
        return false;
      }
    } catch (e) {
      messages.removeWhere((m) => m.id == optimisticMsg.id);
      errorMessage.value = 'Message could not be sent';
      _logger.e('Send message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Mark conversation as read
  // ---------------------------------------------------------------------------
  Future<bool> markConversationAsRead(String chatId) async {
    try {
      await _chatService.markConversationAsRead(chatId);

      final index = conversations.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        conversations[index] = conversations[index].copyWith(unreadCount: 0);
      }

      unreadCount.value =
          conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);

      return true;
    } catch (e) {
      _logger.e('Mark read error', error: e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Delete message
  // ---------------------------------------------------------------------------
  Future<bool> deleteMessage(String chatId, String messageId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      await _chatService.deleteMessage(chatId, messageId);

      // Remove locally regardless of API result
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

  // ---------------------------------------------------------------------------
  // Upload chat media
  // ---------------------------------------------------------------------------
  Future<String?> uploadChatMedia(String chatId, String filePath) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.uploadChatMedia(chatId, filePath);

      if (response.success && response.data != null) {
        return response.data;
      } else {
        errorMessage.value = response.message;
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload media';
      _logger.e('Upload media error', error: e);
      return null;
    } finally {
      isSending.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Send typing indicator
  // ---------------------------------------------------------------------------
  Future<void> sendTypingIndicator(String chatId) async {
    try {
      await _chatService.sendTypingIndicator(chatId);
    } catch (e) {
      _logger.e('Typing indicator error', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Block the other participant of a chat — POST /users/:id/block
  // ---------------------------------------------------------------------------
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
        clearCurrentConversation();
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

  // ---------------------------------------------------------------------------
  // Report message
  // ---------------------------------------------------------------------------
  Future<bool> reportMessage(String messageId, String reason) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.reportMessage(messageId, reason);

      if (response.success) {
        successMessage.value = 'Message reported successfully';
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to report message';
      _logger.e('Report message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Clear messages
  // ---------------------------------------------------------------------------
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // ---------------------------------------------------------------------------
  // Clear current conversation on exit
  // ---------------------------------------------------------------------------
  void clearCurrentConversation() {
    currentConversation.value = null;
    messages.clear();
  }

  // ---------------------------------------------------------------------------
  // DELETE /chats/:chatId  →  delete an entire chat and remove from list
  // ---------------------------------------------------------------------------
  Future<bool> deleteChat(String chatId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      await _chatService.deleteChat(chatId);

      // Remove from local list regardless of API outcome (best-effort)
      conversations.removeWhere((c) => c.id == chatId);
      if (currentConversation.value?.id == chatId) {
        clearCurrentConversation();
      }
      successMessage.value = 'Conversation deleted';
      _logger.i('Chat deleted: $chatId');
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete conversation';
      _logger.e('Delete chat error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // POST /chats  →  create / start a new chat with a user
  // Returns the new ConversationModel so the caller can navigate into it.
  // ---------------------------------------------------------------------------
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
        // Add to top of conversations list if not already there
        final existingIdx = conversations.indexWhere((c) => c.id == conv.id);
        if (existingIdx == -1) {
          conversations.insert(0, conv);
        } else {
          conversations[existingIdx] = conv;
        }
        successMessage.value = 'Chat started';
        _logger.i('Chat created: ${conv.id}');
        return conv;
      } else {
        errorMessage.value = response.message;
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to start chat';
      _logger.e('Create chat error', error: e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // PUT /chats/:chatId  →  update chat metadata (mute, archive, nickname…)
  // ---------------------------------------------------------------------------
  Future<bool> updateChat(
    String chatId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.updateChat(chatId, updateData);

      if (response.success && response.data != null) {
        // Refresh the entry in the conversations list
        final idx = conversations.indexWhere((c) => c.id == chatId);
        if (idx != -1) {
          conversations[idx] = response.data!;
        }
        // Also refresh currentConversation if open
        if (currentConversation.value?.id == chatId) {
          currentConversation.value = response.data!;
        }
        successMessage.value = 'Chat updated';
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to update chat';
      _logger.e('Update chat error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // Observable list for chat users (all users ever chatted with)
  final chatUsers = <Map<String, dynamic>>[].obs;

  // ---------------------------------------------------------------------------
  // GET /chat-users  →  all users the current user has ever chatted with
  // ---------------------------------------------------------------------------
  Future<bool> getChatUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getChatUsers();

      if (response.success && response.data != null) {
        chatUsers.value = response.data!;
        _logger.i('Loaded ${chatUsers.length} chat users');
        return true;
      } else {
        errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load chat users';
      _logger.e('Get chat users error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // GET /chats/recipient/:recipientId  →  all chats with a specific user
  // ---------------------------------------------------------------------------
  Future<List<ConversationModel>> getChatByRecipient(
    String recipientId,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getChatByRecipient(recipientId);

      if (response.success && response.data != null) {
        _logger.i('Loaded ${response.data!.length} chats for recipient: $recipientId');
        return response.data!;
      } else {
        errorMessage.value = response.message;
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Failed to load chats for recipient';
      _logger.e('Get chat by recipient error', error: e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // GET /chat-history/:userId  →  full chat history for a user
  // ---------------------------------------------------------------------------
  Future<List<ConversationModel>> getChatHistory(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getChatHistory(userId);

      if (response.success && response.data != null) {
        _logger.i('Loaded ${response.data!.length} history entries for user: $userId');
        return response.data!;
      } else {
        errorMessage.value = response.message;
        return [];
      }
    } catch (e) {
      errorMessage.value = 'Failed to load chat history';
      _logger.e('Get chat history error', error: e);
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
