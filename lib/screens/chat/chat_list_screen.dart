import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const ChatListScreen({super.key, this.onTabTapped});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    // Refresh conversations every time this screen is shown
    _chatController.getConversations(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEED1DA),
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
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onTabTapped?.call(1),
                    child: const Icon(Icons.people_outline, size: 28),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Search matches or chats',
                    border: InputBorder.none,
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
                children: const [
                  Text(
                    'Your matches',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(color: Colors.pink),
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
                    ...convs.take(3).map((conv) =>
                        _matchAvatar(conv.otherUserImage, conv.otherUserName)),

                    /// Likes bubble
                    Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '50+',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('Likes'),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 15),

            /// Opening Moves Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3D7DF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR OPENING MOVES',
                            style: TextStyle(
                                color: Colors.pink,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "What's the best piece of advice you've received?",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Chat List
            Expanded(
              child: Obx(() {
                if (_chatController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  );
                }

                final conversations = _chatController.conversations;

                if (conversations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 60, color: Colors.pink),
                        SizedBox(height: 12),
                        Text(
                          'No conversations yet',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 16),
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
                  color: Colors.pink,
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
                color: Colors.pink,
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