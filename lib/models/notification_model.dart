/// Kinds of notification the backend sends (`Notification.type`).
class NotificationType {
  static const chat = 'chat';
  static const match = 'match';
  static const like = 'like';
  static const superLike = 'super_like';
  static const profile = 'profile';
  static const system = 'system';
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.metadata,
    required this.count,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> metadata;

  /// How many events were folded into this one (several chat messages).
  final int count;
  final bool isRead;
  final DateTime createdAt;

  String meta(String key) => metadata[key]?.toString() ?? '';

  String get conversationId => meta('conversationId');

  /// The other person involved (liker, match, message sender).
  String get actorId =>
      meta('userId').isNotEmpty ? meta('userId') : meta('senderId');

  String get actorName =>
      meta('name').isNotEmpty ? meta('name') : meta('senderName');

  String get actorPhoto =>
      meta('photo').isNotEmpty ? meta('photo') : meta('senderPhoto');

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['metadata'];
    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: (json['type'] ?? NotificationType.system).toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      metadata: rawMeta is Map
          ? rawMeta.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{},
      count: int.tryParse('${json['count'] ?? 1}') ?? 1,
      isRead: json['isRead'] == true || json['readAt'] != null,
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}')?.toLocal() ??
              DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        metadata: metadata,
        count: count,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

class NotificationPage {
  const NotificationPage({
    required this.notifications,
    required this.unreadCount,
    required this.page,
    required this.hasMore,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final int page;
  final bool hasMore;

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final items = json['notifications'];
    return NotificationPage(
      notifications: items is List
          ? items
              .whereType<Map>()
              .map((item) => AppNotification.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ))
              .toList()
          : const [],
      unreadCount: int.tryParse('${json['unreadCount'] ?? 0}') ?? 0,
      page: int.tryParse('${json['page'] ?? 1}') ?? 1,
      hasMore: json['hasMore'] == true,
    );
  }
}
