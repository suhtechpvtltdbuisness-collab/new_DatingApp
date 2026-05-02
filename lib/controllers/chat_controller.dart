import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/data/mock_data.dart';
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
  // Get conversations list — real API with mock fallback
  // ---------------------------------------------------------------------------
  Future<bool> getConversations({bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getConversations();

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        conversations.value = response.data!;
        _logger.i('Loaded ${conversations.length} conversations from API');
      } else {
        // Fallback to mock data so the UI always shows something
        _logger.w('API returned no conversations — using mock data');
        conversations.value = MockData.sampleConversations;
      }

      // Calculate total unread count
      unreadCount.value =
          conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to load conversations';
      _logger.e('Get conversations error', error: e);
      // Fallback
      conversations.value = MockData.sampleConversations;
      return false;
    } finally {
      isLoading.value = false;
    }
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
        _logger.w('getConversation failed — trying mock fallback');
        // Try mock fallback
        final mockConv = MockData.getConversation(chatId);
        if (mockConv != null) {
          currentConversation.value = mockConv;
          messages.value = MockData.getMessagesForConversation(chatId);
          return true;
        }
        errorMessage.value = response.error ?? response.message;
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
        // Fallback to mock messages
        final mockMessages = MockData.getMessagesForConversation(chatId);
        if (mockMessages.isNotEmpty) {
          messages.value = mockMessages;
        }
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
        // Update optimistic message to "sent" anyway for demo purposes
        final idx = messages.indexWhere((m) => m.id == optimisticMsg.id);
        if (idx != -1) {
          messages[idx] = optimisticMsg.copyWith(status: MessageStatus.sent);
        }
        _logger.w('Send message API failed: ${response.error}');
        return false;
      }
    } catch (e) {
      // Keep optimistic message visible with sent status
      final idx = messages.indexWhere((m) => m.id == optimisticMsg.id);
      if (idx != -1) {
        messages[idx] = optimisticMsg.copyWith(status: MessageStatus.sent);
      }
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
        errorMessage.value = response.error ?? response.message;
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
  // Block user in chat
  // ---------------------------------------------------------------------------
  Future<bool> blockUserInChat(String chatId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      await _chatService.blockUserInChat(chatId);

      successMessage.value = 'User blocked';
      conversations.removeWhere((c) => c.id == chatId);
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
        errorMessage.value = response.error ?? response.message;
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
}
