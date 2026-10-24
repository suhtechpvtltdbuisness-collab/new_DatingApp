import 'package:dating_app/controllers/notification_controller.dart';
import 'package:dating_app/models/notification_model.dart';
import 'package:dating_app/screens/myprofile/Notifications_Screen.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Everything that happened on the account: matches, likes, messages and
/// account updates, newest first.
class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final NotificationController _controller = Get.find<NotificationController>();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.loadNotifications();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This removes every notification from this list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Clear all',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _controller.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          const BackButton(color: AppTheme.textPrimaryColor),
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: _controller.unreadCount.value > 0
                  ? _controller.markAllRead
                  : null,
              child: const Text('Mark all read'),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimaryColor),
            onSelected: (value) {
              if (value == 'settings') {
                Get.to(() => const NotificationsScreen());
              } else if (value == 'clear') {
                _confirmClearAll();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Notification settings')),
              PopupMenuItem(value: 'clear', child: Text('Clear all')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Obx(() {
      final items = _controller.notifications;
      if (_controller.isLoading.value && items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (items.isEmpty) {
        return RefreshIndicator(
          onRefresh: _controller.loadNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              _emptyState(),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _controller.loadNotifications,
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: items.length + (_controller.hasMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            return _tile(items[index]);
          },
        ),
      );
    });
  }

  Widget _emptyState() {
    final error = _controller.errorMessage.value;
    return Column(
      children: [
        Container(
          height: 96,
          width: 96,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          error.isNotEmpty ? error : 'No notifications yet',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'New matches, likes and messages will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ),
      ],
    );
  }

  Widget _tile(AppNotification notification) {
    final style = _TypeStyle.of(notification.type);
    final unread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _controller.delete(notification),
      child: Material(
        color: unread ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () => _controller.open(notification),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(notification, style),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _timeLabel(notification),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 6),
                    height: 9,
                    width: 9,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(AppNotification notification, _TypeStyle style) {
    final photo = notification.actorPhoto;
    final badge = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: style.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(style.icon, size: 11, color: Colors.white),
    );

    if (!photo.startsWith('http')) {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: style.color.withOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(style.icon, color: style.color, size: 24),
      );
    }

    return SizedBox(
      height: 48,
      width: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: style.color.withOpacity(0.14),
            backgroundImage: NetworkImage(photo),
          ),
          Positioned(right: -2, bottom: -2, child: badge),
        ],
      ),
    );
  }

  String _timeLabel(AppNotification notification) {
    final diff = DateTime.now().difference(notification.createdAt);
    final String when;
    if (diff.inMinutes < 1) {
      when = 'Just now';
    } else if (diff.inHours < 1) {
      when = '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      when = '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      when = '${diff.inDays}d ago';
    } else {
      when = DateFormat('d MMM').format(notification.createdAt);
    }
    if (notification.type == NotificationType.chat && notification.count > 1) {
      return '$when · ${notification.count} messages';
    }
    return when;
  }
}

class _TypeStyle {
  const _TypeStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  static _TypeStyle of(String type) {
    switch (type) {
      case NotificationType.chat:
        return const _TypeStyle(Icons.chat_bubble_rounded, AppTheme.accentColor);
      case NotificationType.match:
        return const _TypeStyle(Icons.favorite_rounded, AppTheme.primaryColor);
      case NotificationType.like:
        return const _TypeStyle(Icons.thumb_up_alt_rounded, AppTheme.warmAccentColor);
      case NotificationType.superLike:
        return const _TypeStyle(Icons.star_rounded, AppTheme.superLikeColor);
      case NotificationType.profile:
        return const _TypeStyle(Icons.verified_rounded, AppTheme.successColor);
      default:
        return const _TypeStyle(Icons.shield_rounded, AppTheme.infoColor);
    }
  }
}
