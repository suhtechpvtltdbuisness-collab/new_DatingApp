import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final swipeController = Get.find<SwipeController>();
  late final ChatController _chatController;
  String? _busyMatchId;
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }
    _chatController = Get.find<ChatController>();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _bootstrapping = true);
    await Future.wait([
      swipeController.getMatches(),
      _chatController.getConversations(),
    ]);
    if (!mounted) return;
    setState(() => _bootstrapping = false);
  }

  Set<String> get _chattedUserIds => _chatController.conversations
      .map((c) => c.otherUserId)
      .where((id) => id.isNotEmpty)
      .toSet();

  String _matchPartnerId(MatchModel match) {
    final user = match.matchedUser;
    if (user != null && user.id.isNotEmpty) return user.id;
    return match.targetUserId;
  }

  List<MatchModel> _unmessagedMatches(List<MatchModel> matches) {
    final chatted = _chattedUserIds;
    final seen = <String>{};
    final result = <MatchModel>[];
    for (final match in matches) {
      final partnerId = _matchPartnerId(match);
      if (partnerId.isEmpty) continue;
      if (chatted.contains(partnerId)) continue;
      if (!seen.add(partnerId)) continue;
      result.add(match);
    }
    return result;
  }

  Future<void> _openChat(MatchModel match) async {
    final user = match.matchedUser;
    final recipientId = _matchPartnerId(match);
    if (recipientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open chat for this match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_busyMatchId != null) return;
    setState(() => _busyMatchId = match.id);

    final conv = await _chatController.createChat(recipientId: recipientId);

    if (!mounted) return;
    setState(() => _busyMatchId = null);

    if (conv == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _chatController.errorMessage.value.isNotEmpty
                ? _chatController.errorMessage.value
                : 'Could not start a chat. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final name = user != null && user.fullName.trim().isNotEmpty
        ? user.fullName
        : 'Match';
    final image = user != null && user.profileImage.isNotEmpty
        ? user.profileImage
        : 'assets/images/profile.png';

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: conv.id,
          name: name,
          image: image,
        ),
      ),
    );

    // Refresh so this match drops out of the list after chatting.
    if (mounted) await _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Matches'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Obx(() {
            final loading =
                _bootstrapping || swipeController.isLoading.value;
            final visible =
                _unmessagedMatches(swipeController.matches.toList());

            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (visible.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        swipeController.errorMessage.value.isEmpty
                            ? 'No new matches to chat with'
                            : swipeController.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: _bootstrap,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final match = visible[index];
                  final user = match.matchedUser;
                  final busy = _busyMatchId == match.id;
                  return GlassCard(
                    radius: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.15),
                          backgroundImage:
                              user != null && user.profileImage.isNotEmpty
                                  ? NetworkImage(user.profileImage)
                                  : null,
                          child: user != null && user.profileImage.isNotEmpty
                              ? null
                              : const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user == null
                                    ? 'Unknown user'
                                    : user.age > 0
                                        ? '${user.fullName}, ${user.age}'
                                        : user.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.locationLabel.isNotEmpty == true
                                    ? user!.locationLabel
                                    : match.status.name,
                                style: const TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (match.isPending)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconAction(
                                icon: Icons.close_rounded,
                                color: AppTheme.rejectColor,
                                onTap: () =>
                                    swipeController.rejectMatch(match.id),
                              ),
                              const SizedBox(width: 8),
                              _iconAction(
                                icon: Icons.check_rounded,
                                color: AppTheme.acceptColor,
                                onTap: () =>
                                    swipeController.acceptMatch(match.id),
                              ),
                            ],
                          )
                        else if (busy)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          TextButton.icon(
                            onPressed: () => _openChat(match),
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                            ),
                            label: const Text('Chat'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
