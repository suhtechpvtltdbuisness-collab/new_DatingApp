import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/media_url.dart';

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType; // image, video, document

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.timestamp,
    required this.status,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: resolveMediaUrl(json['senderImage']?.toString() ?? ''),
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString()).toLocal()
          : DateTime.now(),
      status: _parseStatus(json['status'], json['isRead'] == true),
      isRead: json['isRead'] == true ||
          (json['status']?.toString().toLowerCase() == 'read'),
      attachmentUrl: json['attachmentUrl'] != null
          ? resolveMediaUrl(json['attachmentUrl'].toString())
          : null,
      attachmentType: json['attachmentType'],
    );
  }

  static MessageStatus _parseStatus(dynamic raw, bool isRead) {
    if (isRead) return MessageStatus.read;
    final normalized = raw?.toString().toLowerCase().trim() ?? '';
    switch (normalized) {
      case 'sending':
      case 'pending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? message,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isRead,
    String? attachmentUrl,
    String? attachmentType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
    );
  }
}

class ConversationModel {
  final String id;
  final String userId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeenTime;
  final List<ChatMessageModel> messages;
  final bool isBlocked;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeenTime,
    this.messages = const [],
    this.isBlocked = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      otherUserId: json['otherUserId'] ?? '',
      otherUserName: json['otherUserName'] ?? '',
      otherUserImage: resolveMediaUrl(json['otherUserImage']?.toString() ?? ''),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime']).toLocal()
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      lastSeenTime: json['lastSeenTime'] != null
          ? DateTime.parse(json['lastSeenTime']).toLocal()
          : null,
      messages: json['messages'] != null
          ? List<ChatMessageModel>.from(
              (json['messages'] as List)
                  .map((e) => ChatMessageModel.fromJson(e)))
          : [],
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserImage': otherUserImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'lastSeenTime': lastSeenTime?.toIso8601String(),
      'messages': messages.map((e) => e.toJson()).toList(),
      'isBlocked': isBlocked,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? otherUserId,
    String? otherUserName,
    String? otherUserImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeenTime,
    List<ChatMessageModel>? messages,
    bool? isBlocked,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserImage: otherUserImage ?? this.otherUserImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeenTime: lastSeenTime ?? this.lastSeenTime,
      messages: messages ?? this.messages,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
