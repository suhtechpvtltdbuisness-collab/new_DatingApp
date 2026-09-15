import 'package:dating_app/models/api_models.dart';
import 'package:dating_app/models/chat_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:logger/logger.dart';

class MessagePage {
  final List<ChatMessageModel> messages;
  final int page;
  final int limit;
  final bool hasMore;

  const MessagePage({
    required this.messages,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}

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

  // ---------------------------------------------------------------------------
  // GET /chats  →  list of conversations
  // ---------------------------------------------------------------------------
  Future<ApiResponse<List<ConversationModel>>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.i('Fetching conversations (page: $page)');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getConversations,
        queryParameters: {'page': page, 'limit': limit},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        // Handle different possible response shapes
        List<dynamic>? list;
        if (raw['chats'] is List) {
          list = raw['chats'] as List;
        } else if (raw['conversations'] is List) {
          list = raw['conversations'] as List;
        } else if (raw['data'] is List) {
          list = raw['data'] as List;
        } else if (raw is List) {
          list = raw as List;
        }

        final conversations = (list ?? [])
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();

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

  // ---------------------------------------------------------------------------
  // GET /chats/:chatId  →  single conversation with messages
  // ---------------------------------------------------------------------------
  Future<ApiResponse<ConversationModel>> getConversation(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _logger.i('Fetching chat: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getConversation,
        {'chatId': chatId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        // The backend may return the conversation at root, or under 'chat'/'conversation'
        final Map<String, dynamic> convJson =
            (raw['chat'] ?? raw['conversation'] ?? raw)
                as Map<String, dynamic>;

        final conversation = ConversationModel.fromJson(convJson);
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

  // ---------------------------------------------------------------------------
  // GET /chats/:chatId/messages  →  messages for a chat
  // ---------------------------------------------------------------------------
  Future<ApiResponse<MessagePage>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _logger.i('Fetching messages for chat: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getMessages,
        {'chatId': chatId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'page': page, 'limit': limit},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        List<dynamic>? list;
        if (raw['messages'] is List) {
          list = raw['messages'] as List;
        } else if (raw['data'] is List) {
          list = raw['data'] as List;
        } else if (raw is List) {
          list = raw as List;
        }

        final messages = (list ?? [])
            .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          message: 'Messages fetched successfully',
          data: MessagePage(
            messages: messages,
            page: (raw['page'] as num?)?.toInt() ?? page,
            limit: (raw['limit'] as num?)?.toInt() ?? limit,
            hasMore: raw['hasMore'] == true,
          ),
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

  // ---------------------------------------------------------------------------
  // POST /chats/:chatId/messages  →  send a message
  // ---------------------------------------------------------------------------
  Future<ApiResponse<ChatMessageModel>> sendMessage(
    String chatId,
    String message, {
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      _logger.i('Sending message to chat: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.sendMessage,
        {'chatId': chatId},
      );

      final data = <String, dynamic>{
        'message': message,
        if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        if (attachmentType != null) 'attachmentType': attachmentType,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: data,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        // ApiClient unwraps { data: <messageObject> }. Prefer the object itself;
        // never treat the string body field "message" as the envelope.
        final Map<String, dynamic> msgJson;
        if (raw['id'] != null && raw['senderId'] != null) {
          msgJson = raw;
        } else if (raw['data'] is Map<String, dynamic>) {
          msgJson = raw['data'] as Map<String, dynamic>;
        } else if (raw['message'] is Map<String, dynamic>) {
          msgJson = raw['message'] as Map<String, dynamic>;
        } else {
          msgJson = raw;
        }
        final chatMessage = ChatMessageModel.fromJson(msgJson);
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

  // ---------------------------------------------------------------------------
  // POST /chats/:chatId/read  →  mark conversation as read
  // ---------------------------------------------------------------------------
  Future<ApiResponse<void>> markConversationAsRead(String chatId) async {
    try {
      _logger.i('Marking chat as read: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.markAsRead,
        {'chatId': chatId},
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

  // ---------------------------------------------------------------------------
  // DELETE /chats/:chatId/messages/:messageId
  // ---------------------------------------------------------------------------
  Future<ApiResponse<void>> deleteMessage(
    String chatId,
    String messageId,
  ) async {
    try {
      _logger.i('Deleting message: $messageId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.deleteMessage,
        {'chatId': chatId, 'messageId': messageId},
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

  // ---------------------------------------------------------------------------
  // POST /chats/:chatId/upload
  // ---------------------------------------------------------------------------
  Future<ApiResponse<String>> uploadChatMedia(
    String chatId,
    String filePath,
  ) async {
    try {
      _logger.i('Uploading media to chat: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.uploadChatMedia,
        {'chatId': chatId},
      );

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        endpoint,
        filePath: filePath,
        fieldName: 'media',
        fromJsonT: (json) => json as Map<String, dynamic>,
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

  // ---------------------------------------------------------------------------
  // POST /chats/:chatId/typing
  // ---------------------------------------------------------------------------
  Future<ApiResponse<void>> sendTypingIndicator(String chatId) async {
    try {
      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.typingIndicator,
        {'chatId': chatId},
      );

      final response = await _apiClient.post<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      // Don't propagate errors for typing indicator
      return ApiResponse<void>.success(
        message: 'Typing indicator sent',
        data: null,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // POST /chats/messages/report
  // ---------------------------------------------------------------------------
  Future<ApiResponse<void>> reportMessage(
    String messageId,
    String reason, {
    String? reportedUserId,
    String? details,
  }) async {
    try {
      _logger.i('Reporting message: $messageId');

      final response = await _apiClient.post<void>(
        ApiEndpoints.reportMessage,
        data: {
          if (messageId.isNotEmpty) 'messageId': messageId,
          'reason': reason,
          if (reportedUserId != null && reportedUserId.isNotEmpty)
            'reportedUserId': reportedUserId,
          if (details != null && details.isNotEmpty) 'details': details,
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

  // ---------------------------------------------------------------------------
  // DELETE /chats/:chatId  →  delete an entire chat
  // ---------------------------------------------------------------------------
  Future<ApiResponse<void>> deleteChat(String chatId) async {
    try {
      _logger.i('Deleting chat: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.deleteChat,
        {'chatId': chatId},
      );

      final response = await _apiClient.delete<void>(
        endpoint,
        fromJsonT: (_) {},
      );

      return response;
    } catch (e) {
      _logger.e('Delete chat error', error: e);
      return ApiResponse.error(
        message: 'Failed to delete chat',
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // POST /chats  →  create a new chat (start a conversation)
  // ---------------------------------------------------------------------------
  Future<ApiResponse<ConversationModel>> createChat({
    required String recipientId,
    String? initialMessage,
  }) async {
    try {
      _logger.i('Creating chat with recipient: $recipientId');

      final data = <String, dynamic>{
        'recipientId': recipientId,
        if (initialMessage != null && initialMessage.isNotEmpty)
          'message': initialMessage,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.createChat,
        data: data,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        final Map<String, dynamic> convJson =
            (raw['chat'] ?? raw['conversation'] ?? raw) as Map<String, dynamic>;
        final conversation = ConversationModel.fromJson(convJson);
        return ApiResponse.success(
          message: 'Chat created successfully',
          data: conversation,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to create chat',
        );
      }
    } catch (e) {
      _logger.e('Create chat error', error: e);
      return ApiResponse.error(
        message: 'Failed to create chat',
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PUT /chats/:chatId  →  update/edit a chat (e.g. mute, archive, nickname)
  // ---------------------------------------------------------------------------
  Future<ApiResponse<ConversationModel>> updateChat(
    String chatId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      _logger.i('Updating chat: $chatId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.updateChat,
        {'chatId': chatId},
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint,
        data: updateData,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        final Map<String, dynamic> convJson =
            (raw['chat'] ?? raw['conversation'] ?? raw) as Map<String, dynamic>;
        final conversation = ConversationModel.fromJson(convJson);
        return ApiResponse.success(
          message: 'Chat updated successfully',
          data: conversation,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to update chat',
        );
      }
    } catch (e) {
      _logger.e('Update chat error', error: e);
      return ApiResponse.error(
        message: 'Failed to update chat',
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // GET /chat-users  →  get all users the current user has chatted with
  // ---------------------------------------------------------------------------
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatUsers() async {
    try {
      _logger.i('Fetching all chatted users');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.getChatUsers,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        List<dynamic>? list;
        if (raw['users'] is List) {
          list = raw['users'] as List;
        } else if (raw['data'] is List) {
          list = raw['data'] as List;
        } else if (raw is List) {
          list = raw as List;
        }

        final users = (list ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();

        return ApiResponse.success(
          message: 'Chat users fetched successfully',
          data: users,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch chat users',
        );
      }
    } catch (e) {
      _logger.e('Get chat users error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch chat users',
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // GET /chats/recipient/:recipientId  →  get all chats with a specific user
  // ---------------------------------------------------------------------------
  Future<ApiResponse<List<ConversationModel>>> getChatByRecipient(
    String recipientId,
  ) async {
    try {
      _logger.i('Fetching chats for recipient: $recipientId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.getChatByRecipient,
        {'recipientId': recipientId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        List<dynamic>? list;
        if (raw['chats'] is List) {
          list = raw['chats'] as List;
        } else if (raw['conversations'] is List) {
          list = raw['conversations'] as List;
        } else if (raw['data'] is List) {
          list = raw['data'] as List;
        } else if (raw is List) {
          list = raw as List;
        }

        final conversations = (list ?? [])
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          message: 'Chats by recipient fetched successfully',
          data: conversations,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch chats by recipient',
        );
      }
    } catch (e) {
      _logger.e('Get chat by recipient error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch chats by recipient',
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // GET /chat-history/:userId  →  full chat history for a user
  // ---------------------------------------------------------------------------
  Future<ApiResponse<List<ConversationModel>>> getChatHistory(
    String userId,
  ) async {
    try {
      _logger.i('Fetching chat history for user: $userId');

      final endpoint = ApiEndpoints.getEndpoint(
        ApiEndpoints.chatHistory,
        {'userId': userId},
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final raw = response.data!;
        List<dynamic>? list;
        if (raw['history'] is List) {
          list = raw['history'] as List;
        } else if (raw['chats'] is List) {
          list = raw['chats'] as List;
        } else if (raw['data'] is List) {
          list = raw['data'] as List;
        } else if (raw is List) {
          list = raw as List;
        }

        final conversations = (list ?? [])
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          message: 'Chat history fetched successfully',
          data: conversations,
        );
      } else {
        return ApiResponse.error(
          message: response.message,
          error: response.error ?? 'Failed to fetch chat history',
        );
      }
    } catch (e) {
      _logger.e('Get chat history error', error: e);
      return ApiResponse.error(
        message: 'Failed to fetch chat history',
        error: e.toString(),
      );
    }
  }
}
