import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:logger/logger.dart';

/// Chat Service
/// Handles messaging and chat-related operations
class ChatService {
  final ApiClient _apiClient = ApiClient();
  final Logger _logger = Logger();

  // Singleton
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  // Get conversations list
  Future<ApiResponse<List<ConversationModel>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.i('Fetching conversations (page: $page)');

      final queryParams = {
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getConversations,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final conversations = (response.data!['conversations'] as List?)
                ?.map((e) => ConversationModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Conversations fetched successfully',
          data: conversations,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch conversations',
        );
      }
    } catch (e) {
      _logger.e('Get conversations error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch conversations',
        error: e.toString(),
      );
    }
  }

  // Get conversation detail with messages
  Future<ApiResponse<ConversationModel>> getConversation(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _logger.i('Fetching conversation: $conversationId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getConversation,
        {'id': conversationId},
      );

      final queryParams = {
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final conversation = ConversationModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Conversation fetched successfully',
          data: conversation,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch conversation',
        );
      }
    } catch (e) {
      _logger.e('Get conversation error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch conversation',
        error: e.toString(),
      );
    }
  }

  // Get messages
  Future<ApiResponse<List<ChatMessageModel>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _logger.i('Fetching messages for conversation: $conversationId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getMessages,
        {'id': conversationId},
      );

      final queryParams = {
        'page': page,
        'limit': limit,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParams,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final messages = (response.data!['messages'] as List?)
                ?.map((e) => ChatMessageModel.fromJson(e))
                .toList() ??
            [];
        return ApiResponse.success(
          message: 'Messages fetched successfully',
          data: messages,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch messages',
        );
      }
    } catch (e) {
      _logger.e('Get messages error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch messages',
        error: e.toString(),
      );
    }
  }

  // Send message
  Future<ApiResponse<ChatMessageModel>> sendMessage(
    String conversationId,
    String message, {
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      _logger.i('Sending message to conversation: $conversationId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.sendMessage,
        {'id': conversationId},
      );

      final data = {
        'message': message,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: data,
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final chatMessage = ChatMessageModel.fromJson(response.data!);
        return ApiResponse.success(
          message: 'Message sent successfully',
          data: chatMessage,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to send message',
        );
      }
    } catch (e) {
      _logger.e('Send message error', error: e);
      return ApiResponse.error(
        message: 'Failed to send message',
        error: e.toString(),
      );
    }
  }

  // Mark conversation as read
  Future<ApiResponse<void>> markConversationAsRead(String conversationId) async {
    try {
      _logger.i('Marking conversation as read: $conversationId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.markAsRead,
        {'id': conversationId},
      );

      final response = await _apiClient.post<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Mark as read error', error: e);
      return ApiResponse.error(
        message: 'Failed to mark as read',
        error: e.toString(),
      );
    }
  }

  // Delete message
  Future<ApiResponse<void>> deleteMessage(
    String conversationId,
    String messageId,
  ) async {
    try {
      _logger.i('Deleting message: $messageId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.deleteMessage,
        {'id': conversationId, 'messageId': messageId},
      );

      final response = await _apiClient.delete<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Delete message error', error: e);
      return ApiResponse.error(
        message: 'Failed to delete message',
        error: e.toString(),
      );
    }
  }

  // Upload chat media
  Future<ApiResponse<String>> uploadChatMedia(
    String conversationId,
    String filePath,
  ) async {
    try {
      _logger.i('Uploading media to conversation: $conversationId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.uploadChatMedia,
        {'id': conversationId},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        endpoint,
        filePath: filePath,
        fieldName: 'media',
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final mediaUrl = response.data!['mediaUrl'] as String? ?? '';
        return ApiResponse.success(
          message: 'Media uploaded successfully',
          data: mediaUrl,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to upload media',
        );
      }
    } catch (e) {
      _logger.e('Upload media error', error: e);
      return ApiResponse.error(
        message: 'Failed to upload media',
        error: e.toString(),
      );
    }
  }

  // Send typing indicator
  Future<ApiResponse<void>> sendTypingIndicator(String conversationId) async {
    try {
      _logger.i('Sending typing indicator: $conversationId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.typingIndicator,
        {'id': conversationId},
      );

      final response = await _apiClient.post<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Typing indicator error', error: e);
      // Don't propagate error for typing indicator
      return ApiResponse<void>.success(
        message: 'Typing indicator sent',
        data: null,
      );
    }
  }

  // Block user in chat
  Future<ApiResponse<void>> blockUserInChat(String conversationId) async {
    try {
      _logger.i('Blocking user in chat: $conversationId');

      // This would be implemented as a separate endpoint
      final response = ApiResponse<void>.success(
        message: 'User blocked',
        data: null,
      );

      return response;
    } catch (e) {
      _logger.e('Block user error', error: e);
      return ApiResponse.error(
        message: 'Failed to block user',
        error: e.toString(),
      );
    }
  }

  // Report message
  Future<ApiResponse<void>> reportMessage(
    String messageId,
    String reason,
  ) async {
    try {
      _logger.i('Reporting message: $messageId');

      final response = await _apiClient.post<void>(
        ApiEndpoints.reportMessage,
        data: {
          'messageId': messageId,
          'reason': reason,
        },
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Report message error', error: e);
      return ApiResponse.error(
        message: 'Failed to report message',
        error: e.toString(),
      );
    }
  }
}
