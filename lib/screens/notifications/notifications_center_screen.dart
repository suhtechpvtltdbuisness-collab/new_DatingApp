import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_app/controllers/notification_controller.dart';
import 'package:dating_app/models/notification_model.dart';
import 'package:dating_app/screens/myprofile/Notifications_Screen.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Modern, attractive and fully responsive Notifications Center screen.
/// Displays matches, messages, likes and system updates with live filtering,
/// glassmorphism visuals, and adaptive multi-screen support.
class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  final NotificationController _controller = Get.find<NotificationController>();
  final ScrollController _scroll = ScrollController();

  // Active filter category: 'all', 'matches', 'messages', 'likes'
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _controller.loadNotifications();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.errorColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Clear notifications?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently remove all notifications from your inbox.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Clear all',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.clearAll();
    }
  }

  List<AppNotification> _filterNotifications(List<AppNotification> all) {
    switch (_activeFilter) {
      case 'matches':
        return all
            .where((n) => n.type == NotificationType.match)
            .toList();
      case 'messages':
        return all
            .where((n) => n.type == NotificationType.chat)
            .toList();
      case 'likes':
        return all
            .where((n) =>
                n.type == NotificationType.like ||
                n.type == NotificationType.superLike)
            .toList();
      case 'all':
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 650;
              final horizontalPadding = isTablet ? 24.0 : 16.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildHeader(context),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildFilterChips(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: _buildBody(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          // Frosted Back Button
          Material(
            color: Colors.white.withOpacity(0.85),
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.04),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.maybePop(context),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title + Unread Count Badge
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Notifications',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                Obx(() {
                  final unread = _controller.unreadCount.value;
                  if (unread <= 0) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$unread new',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Action: Mark All Read (Compact, Modern Pill)
          Obx(() {
            final unread = _controller.unreadCount.value;
            if (unread <= 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.04),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _controller.markAllRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.done_all_rounded,
                          size: 15,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Read all',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // More Options Menu
          Material(
            color: Colors.white.withOpacity(0.85),
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.04),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: AppTheme.textPrimaryColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.15),
              onSelected: (value) {
                if (value == 'settings') {
                  Get.to(() => const NotificationsScreen());
                } else if (value == 'clear') {
                  _confirmClearAll();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: AppTheme.textPrimaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notification settings',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_sweep_outlined,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Clear all',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final all = _controller.notifications;
      final matchCount = all.where((n) => n.type == NotificationType.match).length;
      final chatCount = all.where((n) => n.type == NotificationType.chat).length;
      final likeCount = all.where((n) =>
          n.type == NotificationType.like ||
          n.type == NotificationType.superLike).length;

      final filters = [
        {'id': 'all', 'label': 'All', 'count': all.length},
        {'id': 'matches', 'label': 'Matches', 'count': matchCount},
        {'id': 'messages', 'label': 'Chats', 'count': chatCount},
        {'id': 'likes', 'label': 'Likes', 'count': likeCount},
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: filters.map((f) {
            final id = f['id'] as String;
            final label = f['label'] as String;
            final count = f['count'] as int;
            final isSelected = _activeFilter == id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _activeFilter = id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.heroGradient : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.9),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondaryColor,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildBody() {
    return Obx(() {
      final allItems = _controller.notifications;

      if (_controller.isLoading.value && allItems.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2.5,
          ),
        );
      }

      final items = _filterNotifications(allItems);

      if (items.isEmpty) {
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: _controller.loadNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
              _buildEmptyState(),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: _controller.loadNotifications,
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(top: 4, bottom: 32),
          itemCount: items.length + (_controller.hasMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }
            return _buildNotificationTile(items[index]);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    final error = _controller.errorMessage.value;
    final isFiltered = _activeFilter != 'all';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.14),
                  AppTheme.accentColor.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 44,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            error.isNotEmpty
                ? error
                : isFiltered
                    ? 'No $_activeFilter notifications'
                    : 'All caught up!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isFiltered
                  ? 'Switch back to "All" to view all account activity.'
                  : 'New matches, likes, and messages will arrive right here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppTheme.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => setState(() => _activeFilter = 'all'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text(
                'Show all',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    final style = _TypeStyle.of(notification.type);
    final unread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF3D77), Color(0xFFFF5E8A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      onDismissed: (_) => _controller.delete(notification),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _controller.open(notification),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unread
                  ? Colors.white
                  : Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unread
                    ? AppTheme.primaryColor.withOpacity(0.25)
                    : Colors.white.withOpacity(0.9),
                width: unread ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: unread
                      ? AppTheme.primaryColor.withOpacity(0.08)
                      : Colors.black.withOpacity(0.02),
                  blurRadius: unread ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with type indicator badge
                _buildAvatar(notification, style),
                const SizedBox(width: 13),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title + Timestamp
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight:
                                    unread ? FontWeight.w800 : FontWeight.w700,
                                color: AppTheme.textPrimaryColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeLabel(notification),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.w500,
                              color: unread
                                  ? AppTheme.primaryColor
                                  : AppTheme.textTertiaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Body text
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight:
                              unread ? FontWeight.w500 : FontWeight.w400,
                          color: unread
                              ? AppTheme.textPrimaryColor.withOpacity(0.9)
                              : AppTheme.textSecondaryColor,
                        ),
                      ),

                      // Optional pill tag for folded messages or special event
                      if (notification.type == NotificationType.chat &&
                          notification.count > 1) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 11,
                                color: AppTheme.accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${notification.count} new messages',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (notification.type == NotificationType.match) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 11,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'New Match',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Unread glowing dot indicator
                if (unread)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppNotification notification, _TypeStyle style) {
    final photo = notification.actorPhoto;
    final hasPhoto = photo.startsWith('http');

    final badge = Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        gradient: style.gradient,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: style.color.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(style.icon, size: 10, color: Colors.white),
    );

    if (!hasPhoto) {
      // Modern multi-stop gradient container for placeholder avatar
      return SizedBox(
        height: 52,
        width: 52,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: style.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: style.color.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(style.icon, color: Colors.white, size: 24),
              ),
            ),
            Positioned(right: -3, bottom: -3, child: badge),
          ],
        ),
      );
    }

    return SizedBox(
      height: 52,
      width: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: photo,
              height: 52,
              width: 52,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: style.color.withOpacity(0.1),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(gradient: style.gradient),
                child: Icon(style.icon, color: Colors.white, size: 22),
              ),
            ),
          ),
          Positioned(right: -3, bottom: -3, child: badge),
        ],
      ),
    );
  }

  String _timeLabel(AppNotification notification) {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('d MMM').format(notification.createdAt);
    }
  }
}

class _TypeStyle {
  const _TypeStyle(this.icon, this.color, this.gradient);

  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  static _TypeStyle of(String type) {
    switch (type) {
      case NotificationType.chat:
        return const _TypeStyle(
          Icons.chat_bubble_rounded,
          AppTheme.accentColor,
          LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case NotificationType.match:
        return const _TypeStyle(
          Icons.favorite_rounded,
          AppTheme.primaryColor,
          LinearGradient(
            colors: [Color(0xFFFF3D77), Color(0xFFFF5E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case NotificationType.like:
        return const _TypeStyle(
          Icons.thumb_up_alt_rounded,
          AppTheme.warmAccentColor,
          LinearGradient(
            colors: [Color(0xFFFF8A5C), Color(0xFFFFAB78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case NotificationType.superLike:
        return const _TypeStyle(
          Icons.star_rounded,
          AppTheme.superLikeColor,
          LinearGradient(
            colors: [Color(0xFF4DC4FF), Color(0xFF1E90FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case NotificationType.profile:
        return const _TypeStyle(
          Icons.verified_rounded,
          AppTheme.successColor,
          LinearGradient(
            colors: [Color(0xFF33D69F), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      default:
        return const _TypeStyle(
          Icons.shield_rounded,
          AppTheme.infoColor,
          LinearGradient(
            colors: [Color(0xFF4DA3FF), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}
