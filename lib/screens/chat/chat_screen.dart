import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/chat/emoji_picker_panel.dart';
import 'report_user_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final String image;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.image,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

enum _ChatMenuOption {
  viewProfile,
  muteNotifications,
  unmatch,
  block,
  report,
  deleteConversation,
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _chatController;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _showEmojiPicker = false;
  final ScrollController _scrollController = ScrollController();
  Worker? _messagesWorker;
  String? _lastMessageId;

  // ---- contact-info guard ----
  final List<String> _numberWords = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
    'twenty',
  ];
  int blockedAttempts = 0;
  bool notificationsMuted = false;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>();
    _scrollController.addListener(_onScroll);
    _chatController.openConversation(widget.chatId).then((_) {
      if (mounted) _scrollToBottom();
    });
    _messagesWorker = ever<List<ChatMessageModel>>(_chatController.messages, (msgs) {
      if (!mounted || msgs.isEmpty) return;
      final latestId = msgs.last.id;
      if (latestId == _lastMessageId) return;
      _lastMessageId = latestId;
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _scrollController.removeListener(_onScroll);
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    _chatController.leaveConversation();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 80) {
      _chatController.loadOlderMessages(widget.chatId);
    }
  }

  // -------------------------------------------------------------------------
  // Scroll to bottom
  // -------------------------------------------------------------------------
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // Send message
  // -------------------------------------------------------------------------
  /// Swap the keyboard for the emoji panel (and back) rather than stacking
  /// both, which would leave no room for the conversation.
  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _inputFocusNode.requestFocus();
    } else {
      _inputFocusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  /// Insert at the caret, not blindly at the end, so emoji land where the
  /// user is actually typing.
  void _insertEmoji(String emoji) {
    final text = _inputController.text;
    final selection = _inputController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final updated = text.replaceRange(start, end, emoji);
    _inputController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    _chatController.onComposerChanged(widget.chatId, updated);
  }

  void _backspace() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    final selection = _inputController.selection;
    final end = selection.end >= 0 ? selection.end : text.length;
    if (end == 0) return;

    // For a collapsed caret, step back one full grapheme so a multi-code-unit
    // emoji is deleted in one press instead of breaking into pieces.
    final start = selection.start >= 0 && selection.start != end
        ? selection.start
        : text.substring(0, end).characters.skipLast(1).string.length;

    final updated = text.replaceRange(start, end, '');
    _inputController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start),
    );
    _chatController.onComposerChanged(widget.chatId, updated);
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final warning = _contactWarningForText(text);
    if (warning != null) {
      blockedAttempts += 1;
      _inputController.clear();
      if (blockedAttempts >= 2) {
        _showChatRestrictedDialog();
      } else {
        _showToast(warning);
      }
      return;
    }

    if (_chatController.isChatBlocked(widget.chatId)) {
      _showToast('You blocked this user. Unblock them to send messages.');
      return;
    }

    _inputController.clear();
    _chatController.sendMessage(widget.chatId, text).then((sent) {
      if (!sent && mounted) {
        _showToast(_chatController.errorMessage.value.isNotEmpty
            ? _chatController.errorMessage.value
            : 'Message could not be sent');
      }
    });
    _scrollToBottom();
  }

  // -------------------------------------------------------------------------
  // Contact-info detection (kept from original)
  // -------------------------------------------------------------------------
  String? _contactWarningForText(String text) {
    final normalized = _normalizeText(text);
    if (_containsDisguisedNumberContact(text, normalized)) {
      return 'Our AI detected a disguised attempt to share contact details. Message blocked.';
    }
    if (_containsPhoneDigits(text)) {
      return 'Exchanging phone numbers not allowed.';
    }
    if (_containsNumberWordContact(normalized)) {
      return 'Sharing contact details in written form is not allowed.';
    }
    return null;
  }

  String _normalizeText(String text) {
    var normalized = text.toLowerCase();
    const leetMap = {
      '0': 'o',
      '1': 'i',
      '!': 'i',
      '3': 'e',
      '4': 'a',
      '5': 's',
      '7': 't',
      '8': 'b',
    };
    for (final entry in leetMap.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _containsPhoneDigits(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 3) return false;
    if (RegExp(r'\d[\d\s\-\.\(\)]{2,}\d').hasMatch(text)) return true;
    return digitsOnly.length >= 7;
  }

  bool _containsNumberWordContact(String normalized) {
    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.length < 2) return false;
    return tokens.where((t) => _numberWords.contains(t)).length >= 2;
  }

  bool _containsDisguisedNumberContact(String original, String normalized) {
    final tokens = original
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return false;

    final disguisedTokens = tokens.where((token) {
      final hasDigitAndLetter = RegExp(
        r'(?=.*[0-9])(?=.*[a-zA-Z])',
      ).hasMatch(token);
      if (!hasDigitAndLetter) return false;
      final rebuilt = token
          .replaceAll('0', 'o')
          .replaceAll('1', 'i')
          .replaceAll('!', 'i')
          .replaceAll('3', 'e')
          .replaceAll('4', 'a')
          .replaceAll('5', 's')
          .replaceAll('7', 't')
          .replaceAll('8', 'b')
          .replaceAll('\$', 's');
      final cleaned = rebuilt.replaceAll(RegExp(r'[^a-z]'), '');
      return _numberWords.contains(cleaned);
    }).length;

    final normalizedNumberWords = normalized
        .split(RegExp(r'\s+'))
        .where((t) => _numberWords.contains(t))
        .length;

    return disguisedTokens >= 1 && normalizedNumberWords >= 2;
  }

  // -------------------------------------------------------------------------
  // Menu actions
  // -------------------------------------------------------------------------
  void _handleMenuSelection(_ChatMenuOption option) async {
    switch (option) {
      case _ChatMenuOption.viewProfile:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileDetailsScreen(
              userId: _chatController.currentConversation.value?.otherUserId,
            ),
          ),
        );
        break;

      case _ChatMenuOption.muteNotifications:
        setState(() => notificationsMuted = !notificationsMuted);
        _showToast(
          notificationsMuted ? 'Notifications muted' : 'Notifications unmuted',
        );
        break;

      case _ChatMenuOption.unmatch:
        _showConfirmationDialog(
          title: 'Unmatch',
          message: 'Are you sure you want to unmatch?',
          confirmText: 'Confirm',
          onConfirm: () {
            _showToast('You have unmatched successfully');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        );
        break;

      case _ChatMenuOption.block:
        _showConfirmationDialog(
          title: 'Block User',
          message: 'Blocked users cannot contact you',
          confirmText: 'Block',
          onConfirm: () async {
            final ok = await _chatController.blockUserInChat(widget.chatId);
            if (!mounted) return;
            if (!ok) {
              _showToast(_chatController.errorMessage.value.isNotEmpty
                  ? _chatController.errorMessage.value
                  : 'Could not block user');
              return;
            }
            _showToast('User blocked and chat removed');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        );
        break;

      case _ChatMenuOption.report:
        final otherUserId =
            _chatController.currentConversation.value?.otherUserId;
        final didBlock = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (_) => ReportUserScreen(
              userName: widget.name,
              reportedUserId: otherUserId,
            ),
          ),
        );
        if (didBlock == true && mounted) {
          final ok = await _chatController.blockUserInChat(widget.chatId);
          if (!mounted) return;
          if (!ok) {
            _showToast(_chatController.errorMessage.value.isNotEmpty
                ? _chatController.errorMessage.value
                : 'Could not block user');
            break;
          }
          _showToast('User blocked successfully');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
        break;

      case _ChatMenuOption.deleteConversation:
        _showConfirmationDialog(
          title: 'Delete Conversation',
          message: 'This will delete all messages permanently',
          confirmText: 'Delete',
          onConfirm: () async {
            final ok = await _chatController.deleteChat(widget.chatId);
            if (!mounted) return;
            if (!ok) {
              _showToast(_chatController.errorMessage.value.isNotEmpty
                  ? _chatController.errorMessage.value
                  : 'Could not delete conversation');
              return;
            }
            _showToast('Conversation deleted');
            Navigator.pop(context);
          },
        );
        break;
    }
  }

  // -------------------------------------------------------------------------
  // Dialogs & toasts
  // -------------------------------------------------------------------------
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryDarkColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black87, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              confirmText,
              style: TextStyle(color: AppTheme.primaryDarkColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatRestrictedDialog() {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Chat Restricted',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You've repeatedly attempted to share contact details. "
              "Please review our community guidelines.",
              style: TextStyle(color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Time $timeString',
                style: TextStyle(color: AppTheme.primaryDarkColor, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'I Understand',
              style: TextStyle(color: AppTheme.primaryDarkColor),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.image.startsWith('http')
                  ? NetworkImage(widget.image)
                  : AssetImage(widget.image) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Obx(() {
              final conv = _chatController.currentConversation.value;
              final isOnline = conv?.isOnline ?? false;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        actions: [
          PopupMenuButton<_ChatMenuOption>(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            offset: const Offset(0, 48),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _ChatMenuOption.viewProfile,
                child: Text('View Profile'),
              ),
              PopupMenuItem(
                value: _ChatMenuOption.muteNotifications,
                child: Text(
                  notificationsMuted
                      ? 'Unmute Notifications'
                      : 'Mute Notifications',
                ),
              ),
              const PopupMenuItem(
                value: _ChatMenuOption.unmatch,
                child: Text('Unmatch / Remove Match'),
              ),
              const PopupMenuItem(
                value: _ChatMenuOption.block,
                child: Text('Block User'),
              ),
              const PopupMenuItem(
                value: _ChatMenuOption.report,
                child: Text('Report User'),
              ),
              const PopupMenuItem(
                value: _ChatMenuOption.deleteConversation,
                child: Text('Delete Conversation'),
              ),
            ],
            onSelected: _handleMenuSelection,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.more_vert, color: Colors.black),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          /// CHAT LIST
          Expanded(
            child: Obx(() {
              if (_chatController.isLoadingMessages.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                );
              }

              final msgs = _chatController.messages;

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                itemCount: msgs.length + 2, // +1 header divider +1 typing
                itemBuilder: (context, index) {
                  // First item: "Today" divider
                  if (index == 0) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Today',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }

                  // Last item: typing indicator
                  if (index == msgs.length + 1) {
                    if (!_chatController.isTyping.value) {
                      return const SizedBox.shrink();
                    }
                    return const _TypingIndicator();
                  }

                  final msg = msgs[index - 1];
                  final isMe = msg.senderId == _chatController.currentUserId;

                  return _MessageBubble(
                    msg: msg,
                    isMe: isMe,
                    timeLabel: _formatTime(msg.timestamp),
                  );
                },
              );
            }),
          ),

          /// INPUT BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.only(left: 18, right: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: TextField(
                                  controller: _inputController,
                                  focusNode: _inputFocusNode,
                                  onTap: () {
                                    if (_showEmojiPicker) {
                                      setState(
                                          () => _showEmojiPicker = false);
                                    }
                                  },
                                  onSubmitted: (_) => _sendMessage(),
                                  onChanged: (value) =>
                                      _chatController.onComposerChanged(
                                          widget.chatId, value),
                                  minLines: 1,
                                  maxLines: 5,
                                  textInputAction: TextInputAction.send,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  cursorColor: AppTheme.primaryColor,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                  // isCollapsed drops the decorator's reserved
                                  // vertical space, which was pushing the hint
                                  // below the centre of the pill.
                                  decoration:
                                      AppTheme.borderlessInputDecoration(
                                    hintText: 'Type your message..',
                                    isCollapsed: true,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: _showEmojiPicker
                                  ? 'Hide emoji'
                                  : 'Emoji',
                              onPressed: _toggleEmojiPicker,
                              splashRadius: 20,
                              icon: Icon(
                                _showEmojiPicker
                                    ? Icons.keyboard_outlined
                                    : Icons.emoji_emotions_outlined,
                                color: _showEmojiPicker
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade600,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => GestureDetector(
                        onTap: _chatController.isSending.value
                            ? null
                            : _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _chatController.isSending.value
                                ? AppTheme.primaryColor.withOpacity(0.25)
                                : AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _chatController.isSending.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// EMOJI PANEL
          if (_showEmojiPicker)
            EmojiPickerPanel(
              onEmojiSelected: _insertEmoji,
              onBackspace: _backspace,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Message bubble widget
// ---------------------------------------------------------------------------
class _MessageBubble extends StatelessWidget {
  final ChatMessageModel msg;
  final bool isMe;
  final String timeLabel;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFEFD6DE) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(msg.message, style: const TextStyle(fontSize: 14)),
          ),

          /// Time + delivery tick
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeLabel,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: msg.status == MessageStatus.read
                      ? Colors.blue
                      : AppTheme.primaryColor,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing indicator
// ---------------------------------------------------------------------------
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Legacy public alias kept so any old call-sites that use `Dot` still compile
class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
