import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/services/chat_service.dart';
import 'package:dating_app/data/mock_data.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

/// Chat Controller
/// Manages chat, messaging, and conversation state
class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final Logger _logger = Logger();

  // Observable state variables
  final isLoading = false.obs;
  final conversations = <ConversationModel>[].obs;
  final currentConversation = Rx<ConversationModel?>(null);
  final messages = <ChatMessageModel>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isSending = false.obs;
  final isTyping = false.obs;
  final unreadCount = 0.obs;
  final messageController = Rx<TextEditingController>(TextEditingController());

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

  /// Get conversations list
  Future<bool> getConversations({bool refresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load mock data for demo
      conversations.value = MockData.sampleConversations;
      
      // Calculate total unread count
      unreadCount.value = conversations
          .fold<int>(0, (sum, conv) => sum + conv.unreadCount);

      _logger.i('Loaded ${conversations.length} demo conversations');
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to load conversations';
      _logger.e('Get conversations error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get conversation detail with messages
  Future<bool> getConversation(String conversationId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _chatService.getConversation(conversationId);

      if (response.success && response.data != null) {
        currentConversation.value = response.data;
        messages.value = response.data!.messages;

        // Mark as read
        await markConversationAsRead(conversationId);

        _logger.i('Loaded conversation: $conversationId');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Get conversation failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load conversation';
      _logger.e('Get conversation error', error: e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get messages for conversation
  Future<bool> getMessages(String conversationId) async {
    try {
      errorMessage.value = '';

      final response = await _chatService.getMessages(conversationId);

      if (response.success && response.data != null) {
        messages.value = response.data!;
        _logger.i('Loaded ${response.data!.length} messages');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Get messages failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load messages';
      _logger.e('Get messages error', error: e);
      return false;
    }
  }

  /// Send message
  Future<bool> sendMessage(String conversationId, String messageText) async {
    if (messageText.trim().isEmpty) {
      return false;
    }

    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.sendMessage(
        conversationId,
        messageText.trim(),
      );

      if (response.success && response.data != null) {
        // Add message to local list
        messages.add(response.data!);

        // Clear input
        messageController.value.clear();

        // Update conversation last message
        if (currentConversation.value != null) {
          currentConversation.value = currentConversation.value!.copyWith(
            lastMessage: messageText,
            lastMessageTime: DateTime.now(),
          );
        }

        _logger.i('Message sent');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Send message failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to send message';
      _logger.e('Send message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Mark conversation as read
  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      final response = await _chatService.markConversationAsRead(conversationId);

      if (response.success) {
        // Update local conversation
        final index = conversations.indexWhere((c) => c.id == conversationId);
        if (index != -1) {
          final updated = conversations[index].copyWith(unreadCount: 0);
          conversations[index] = updated;
        }

        // Update unread count
        unreadCount.value = conversations
            .fold<int>(0, (sum, conv) => sum + conv.unreadCount);

        _logger.i('Conversation marked as read');
        return true;
      } else {
        _logger.w('Mark read failed: ${response.error}');
        return false;
      }
    } catch (e) {
      _logger.e('Mark read error', error: e);
      return false;
    }
  }

  /// Delete message
  Future<bool> deleteMessage(String conversationId, String messageId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.deleteMessage(
        conversationId,
        messageId,
      );

      if (response.success) {
        // Remove message from local list
        messages.removeWhere((m) => m.id == messageId);

        successMessage.value = 'Message deleted';
        _logger.i('Message deleted');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Delete message failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete message';
      _logger.e('Delete message error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Upload chat media
  Future<String?> uploadChatMedia(String conversationId, String filePath) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.uploadChatMedia(
        conversationId,
        filePath,
      );

      if (response.success && response.data != null) {
        _logger.i('Media uploaded');
        return response.data;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Upload media failed: ${response.error}');
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

  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId) async {
    try {
      await _chatService.sendTypingIndicator(conversationId);
    } catch (e) {
      _logger.e('Typing indicator error', error: e);
    }
  }

  /// Block user in chat
  Future<bool> blockUserInChat(String conversationId) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.blockUserInChat(conversationId);

      if (response.success) {
        successMessage.value = 'User blocked';
        // Remove conversation from list
        conversations.removeWhere((c) => c.id == conversationId);
        _logger.i('User blocked');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Block user failed: ${response.error}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to block user';
      _logger.e('Block user error', error: e);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  /// Report message
  Future<bool> reportMessage(String messageId, String reason) async {
    try {
      isSending.value = true;
      errorMessage.value = '';

      final response = await _chatService.reportMessage(messageId, reason);

      if (response.success) {
        successMessage.value = 'Message reported successfully';
        _logger.i('Message reported');
        return true;
      } else {
        errorMessage.value = response.error ?? response.message;
        _logger.w('Report message failed: ${response.error}');
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

  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
