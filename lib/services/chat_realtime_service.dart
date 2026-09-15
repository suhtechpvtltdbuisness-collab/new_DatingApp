import 'dart:async';

import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef RealtimePayloadHandler = void Function(
  String event,
  Map<String, dynamic> payload,
);

/// Supabase Realtime broadcast client (MongoDB remains source of truth).
class ChatRealtimeService {
  ChatRealtimeService._internal();

  static final ChatRealtimeService _instance = ChatRealtimeService._internal();

  factory ChatRealtimeService() => _instance;

  final Logger _logger = Logger();
  final ApiClient _apiClient = ApiClient();

  bool _initialized = false;
  bool _enabled = false;
  RealtimeChannel? _userChannel;
  RealtimeChannel? _conversationChannel;
  String? _activeConversationId;
  Timer? _typingClearTimer;

  bool get isEnabled => _enabled;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    var url = AppConstants.supabaseUrl;
    var anonKey = AppConstants.supabaseAnonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      try {
        final response = await _apiClient.get<Map<String, dynamic>>(
          ApiEndpoints.realtimeConfig,
          fromJsonT: (json) => json as Map<String, dynamic>,
        );
        if (response.success && response.data != null) {
          final data = response.data!;
          if (data['enabled'] == true) {
            url = (data['url'] as String?) ?? '';
            anonKey = (data['anonKey'] as String?) ?? '';
          }
        }
      } catch (e) {
        _logger.w('Realtime config fetch failed: $e');
      }
    }

    if (url.isEmpty || anonKey.isEmpty) {
      _enabled = false;
      _logger.i('Chat realtime disabled — using polling fallback');
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _enabled = true;
      _logger.i('Chat realtime initialized');
    } catch (e) {
      _enabled = false;
      _logger.e('Chat realtime init failed', error: e);
    }
  }

  Future<void> subscribeUserInbox({
    required String userId,
    required RealtimePayloadHandler onEvent,
  }) async {
    await initialize();
    if (!_enabled || userId.isEmpty) return;

    await unsubscribeUserInbox();

    _userChannel = Supabase.instance.client
        .channel('user:$userId')
        .onBroadcast(
          event: 'conversation_updated',
          callback: (payload) {
            onEvent('conversation_updated', _asMap(payload));
          },
        )
        .subscribe();
  }

  Future<void> unsubscribeUserInbox() async {
    final channel = _userChannel;
    _userChannel = null;
    if (channel != null) {
      await Supabase.instance.client.removeChannel(channel);
    }
  }

  Future<void> subscribeConversation({
    required String conversationId,
    required String currentUserId,
    required void Function(Map<String, dynamic> message) onMessage,
    required void Function(String userId) onTyping,
    required void Function(Map<String, dynamic> payload) onRead,
  }) async {
    await initialize();
    if (!_enabled || conversationId.isEmpty) return;

    if (_activeConversationId == conversationId &&
        _conversationChannel != null) {
      return;
    }

    await unsubscribeConversation();
    _activeConversationId = conversationId;

    _conversationChannel = Supabase.instance.client
        .channel('conversation:$conversationId')
        .onBroadcast(
          event: 'new_message',
          callback: (payload) {
            onMessage(_asMap(payload));
          },
        )
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            final data = _asMap(payload);
            final typerId = data['userId']?.toString() ?? '';
            if (typerId.isEmpty || typerId == currentUserId) return;
            onTyping(typerId);
            _typingClearTimer?.cancel();
            _typingClearTimer = Timer(
              AppConstants.typingIndicatorDuration,
              () => onTyping(''),
            );
          },
        )
        .onBroadcast(
          event: 'messages_read',
          callback: (payload) {
            onRead(_asMap(payload));
          },
        )
        .subscribe();
  }

  Future<void> unsubscribeConversation() async {
    _typingClearTimer?.cancel();
    _typingClearTimer = null;
    _activeConversationId = null;
    final channel = _conversationChannel;
    _conversationChannel = null;
    if (channel != null) {
      await Supabase.instance.client.removeChannel(channel);
    }
  }

  Future<void> disposeAll() async {
    await unsubscribeConversation();
    await unsubscribeUserInbox();
  }

  Map<String, dynamic> _asMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      // Supabase may nest under "payload"
      final nested = payload['payload'];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
      return payload;
    }
    if (payload is Map) {
      final map = payload.map((key, value) => MapEntry(key.toString(), value));
      final nested = map['payload'];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
      return map;
    }
    return <String, dynamic>{};
  }
}
