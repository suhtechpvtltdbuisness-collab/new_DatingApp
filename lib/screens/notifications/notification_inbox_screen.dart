import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _InboxKind { message, match }

class _InboxItem {
  const _InboxItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    required this.image,
    required this.userId,
    required this.conversationId,
    required this.name,
    required this.hasUnread,
  });

  final String id;
  final _InboxKind kind;
  final String title;
  final String body;
  final DateTime time;
  final String image;
  final String userId;
  final String conversationId;
  final String name;
  final bool hasUnread;
}

/// Inbox of recent activity: new chat messages and new matches.
class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  static const _readKey = 'notification_inbox_read_ids';

  late final ChatController _chat;
  late final SwipeController _swipe;
  final Set<String> _readIds = {};

  @override
  void initState() {
    super.initState();
    _chat = Get.find<ChatController>();
    _swipe = Get.find<SwipeController>();
    _loadReadIds();
    _chat.getConversations(refresh: true, silent: true);
    _swipe.getMatches(refresh: true);
  }

  Future<void> _loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_readKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _readIds.addAll(saved));
  }

  Future<void> _saveReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readKey, _readIds.toList());
  }

  List<_InboxItem> _buildItems() {
    final items = <_InboxItem>[];

    for (final conv in _chat.conversations) {
      if (conv.lastMessage.trim().isEmpty) continue;
      final id = 'msg_${conv.id}_${conv.lastMessageTime.millisecondsSinceEpoch}';
      final name = conv.otherUserName.trim().isEmpty
          ? 'Someone'
          : conv.otherUserName.trim();
      items.add(
        _InboxItem(
          id: id,
          kind: _InboxKind.message,
          title: name,
          body: conv.lastMessage,
          time: conv.lastMessageTime,
          image: conv.otherUserImage,
          userId: conv.otherUserId,
          conversationId: conv.id,
          name: name,
          hasUnread: conv.unreadCount > 0 && !_readIds.contains(id),
        ),
      );
    }

    for (final MatchModel match in _swipe.matches) {
      final user = match.matchedUser;
      if (!match.isAccepted || user == null) continue;
      final id = 'match_${match.id}';
      final name = user.firstName.trim().isEmpty ? 'Someone' : user.firstName;
      items.add(
        _InboxItem(
          id: id,
          kind: _InboxKind.match,
          title: "It's a match! 🎉",
          body: 'You and $name liked each other. Say hi!',
          time: match.acceptedAt ?? match.createdAt,
          image: user.profileImage,
          userId: user.id,
          conversationId: '',
          name: user.fullName,
          hasUnread: !_readIds.contains(id),
        ),
      );
    }

    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  void _markAllRead(List<_InboxItem> items) {
    setState(() {
      for (final item in items) {
        _readIds.add(item.id);
      }
    });
    _saveReadIds();
  }

  Future<void> _open(_InboxItem item) async {
    if (item.hasUnread) {
      setState(() => _readIds.add(item.id));
      _saveReadIds();
    }

    var conversationId = item.conversationId;
    if (conversationId.isEmpty) {
      final existing = _chat.conversations
          .firstWhereOrNull((c) => c.otherUserId == item.userId);
      conversationId = existing?.id ?? '';
    }
    if (conversationId.isEmpty) {
      final created = await _chat.createChat(
        recipientId: item.userId,
        initialMessage: 'Hello 👋',
      );
      conversationId = created?.id ?? '';
    }
    if (!mounted || conversationId.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: conversationId,
          name: item.name,
          image: item.image.isNotEmpty ? item.image : 'assets/images/profile.png',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final items = _buildItems();
            final hasAnyUnread = items.any((item) => item.hasUnread);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
                  child: Row(
                    children: [
                      const BackButton(color: Colors.black),
                      const Expanded(
                        child: Text(
                          'Notifications',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            hasAnyUnread ? () => _markAllRead(items) : null,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Mark all read',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppTheme.primaryColor,
                          onRefresh: () async {
                            await _chat.getConversations(
                                refresh: true, silent: true);
                            await _swipe.getMatches(refresh: true);
                          },
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, index) => _buildTile(items[index]),
                          ),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 160),
        Icon(Icons.notifications_none_rounded,
            size: 56, color: AppTheme.textTertiaryColor),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No notifications yet',
            style: TextStyle(color: AppTheme.textTertiaryColor, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(_InboxItem item) {
    final isMatch = item.kind == _InboxKind.match;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _open(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(item, isMatch),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            item.hasUnread ? FontWeight.w700 : FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeLabel(item.time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.hasUnread)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(_InboxItem item, bool isMatch) {
    final hasImage = item.image.startsWith('http');
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEFE7FF),
            backgroundImage: hasImage
                ? NetworkImage(item.image)
                : const AssetImage('assets/images/profile.png')
                    as ImageProvider,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isMatch ? AppTheme.primaryColor : AppTheme.accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                isMatch ? Icons.favorite : Icons.chat_bubble,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${time.day} ${months[time.month - 1]}';
  }
}
