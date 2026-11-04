import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/swipe_service.dart';
import '../myprofile/Edit_Profile_Screen.dart';
import '../../models/chat_model.dart';
import '../matches/matches_screen.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const ChatListScreen({super.key, this.onTabTapped});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatController _chatController;
  final UserController _userController = Get.find<UserController>();
  int? _likesCount;
  bool _likesLoading = true;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    // Refresh conversations every time this screen is shown
    _chatController.getConversations(refresh: true);
    _loadLikesCount();
  }

  /// Real count from GET /swipes/liked-you (no placeholder numbers).
  Future<void> _loadLikesCount() async {
    setState(() => _likesLoading = true);
    final response = await SwipeService().getIncomingLikes();
    if (!mounted) return;
    setState(() {
      _likesLoading = false;
      _likesCount = response.success ? response.data?.allCount : null;
    });
  }

  String get _likesLabel {
    if (_likesLoading) return '…';
    final count = _likesCount;
    if (count == null) return '–';
    return count > 50 ? '50+' : '$count';
  }

  void _openLikes() {
    if (widget.onTabTapped != null) {
      widget.onTabTapped!(0); // "Liked you" tab
    }
  }

  Future<void> _openOpeningMoves() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (updated == true) {
      await _userController.refreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryColor),
                  ),
                ],
              ),
            ),

            /// Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: AppTheme.inputBorderColor),
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: AppTheme.primaryColor,
                  decoration: AppTheme.borderlessInputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiaryColor),
                    hintText: 'Search matches or chats',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Matches Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your matches',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimaryColor),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MatchesScreen()),
                    ),
                    child: const Text('See all', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Horizontal match avatars
            Obx(() {
              final convs = _chatController.conversations;
              return SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Show up to 3 avatars from conversations
                    ...convs
                        .take(3)
                        .map(
                          (conv) => _matchAvatar(
                            conv.otherUserImage,
                            conv.otherUserName,
                          ),
                        ),

                    /// Likes bubble
                    GestureDetector(
                      onTap: _openLikes,
                      child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.heroGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _likesLabel,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Likes', style: TextStyle(color: AppTheme.textPrimaryColor)),
                      ],
                    ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 15),

            /// Opening Moves Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _openOpeningMoves,
                child: GlassCard(
                  padding: const EdgeInsets.all(15),
                  radius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() {
                          final user = _userController.currentUser.value;
                          final moves = user?.openingMoves ?? const <String>[];
                          final subtitle = _userController.isLoading.value && user == null
                              ? 'Loading…'
                              : moves.isEmpty
                                  ? 'Add questions new matches can reply to'
                                  : moves.first;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'YOUR OPENING MOVES',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                subtitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textPrimaryColor),
                              ),
                            ],
                          );
                        }),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiaryColor),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Chat List
            Expanded(
              child: Obx(() {
                if (_chatController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                final conversations = _chatController.conversations;

                if (conversations.isEmpty &&
                    _chatController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _chatController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: () =>
                              _chatController.getConversations(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (conversations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No conversations yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Start matching to begin chatting!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: () =>
                      _chatController.getConversations(refresh: true),
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _chatTile(context, conversations[index]);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Match avatar widget
  // ---------------------------------------------------------------------------
  static Widget _matchAvatar(String imageUrl, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : const AssetImage('assets/images/profile.png')
                      as ImageProvider,
          ),
          const SizedBox(height: 5),
          Text(
            name.split(' ').first, // first name only
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chat tile
  // ---------------------------------------------------------------------------
  Widget _chatTile(BuildContext context, ConversationModel conv) {
    final timeLabel = _timeLabel(conv.lastMessageTime);
    final hasUnread = conv.unreadCount > 0;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: conv.id,
              name: conv.otherUserName,
              image: conv.otherUserImage.isNotEmpty
                  ? conv.otherUserImage
                  : 'assets/images/profile.png',
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: conv.otherUserImage.startsWith('http')
                ? NetworkImage(conv.otherUserImage)
                : const AssetImage('assets/images/profile.png')
                      as ImageProvider,
          ),
          if (conv.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conv.otherUserName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conv.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
          color: hasUnread ? Colors.black87 : Colors.grey,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeLabel, style: const TextStyle(fontSize: 12)),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conv.unreadCount > 9 ? '9+' : '${conv.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Format timestamp
  // ---------------------------------------------------------------------------
  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}';
    }
  }
}
