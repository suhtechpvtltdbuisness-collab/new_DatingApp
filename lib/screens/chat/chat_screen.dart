import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'report_user_screen.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String image;

  const ChatScreen({
    super.key,
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
  final TextEditingController messageController = TextEditingController();
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

  List<Map<String, dynamic>> messages = [
    {
      "text":
          "Hi Jake, how are you? I saw on the app that we've crossed paths several times this week 😊",
      "isMe": false,
      "time": "2:55 PM"
    },
    {
      "text":
          "Haha truly! Nice to meet you Grace! What about a cup of coffee today evening? ☕",
      "isMe": true,
      "time": "3:02 PM"
    },
    {
      "text": "Sure, let’s do it! 😊",
      "isMe": false,
      "time": "3:10 PM"
    },
    {
      "text":
          "Great I will write later the exact time and place. See you soon!",
      "isMe": true,
      "time": "3:12 PM"
    },
  ];

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final warning = _contactWarningForText(text);
    if (warning != null) {
      blockedAttempts += 1;
      messageController.clear();
      if (blockedAttempts >= 2) {
        _showChatRestrictedDialog();
      } else {
        _showToast(warning);
      }
      return;
    }

    setState(() {
      messages.add({
        "text": text,
        "isMe": true,
        "time": _currentTimeLabel(),
      });
    });

    messageController.clear();
  }

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
    if (RegExp(r'\d[\d\s\-\.\(\)]{2,}\d').hasMatch(text)) {
      return true;
    }
    return digitsOnly.length >= 7;
  }

  bool _containsNumberWordContact(String normalized) {
    final tokens = normalized.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
    if (tokens.length < 2) return false;
    final numberWordCount = tokens.where((token) => _numberWords.contains(token)).length;
    return numberWordCount >= 2;
  }

  bool _containsDisguisedNumberContact(String original, String normalized) {
    final tokens = original.toLowerCase().split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
    if (tokens.isEmpty) return false;

    final disguisedTokens = tokens.where((token) {
      final containsDigitAndLetter = RegExp(r'(?=.*[0-9])(?=.*[a-zA-Z])').hasMatch(token);
      if (!containsDigitAndLetter) return false;
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
        .where((token) => _numberWords.contains(token))
        .length;

    return disguisedTokens >= 1 && normalizedNumberWords >= 2;
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleMenuSelection(_ChatMenuOption option) async {
    switch (option) {
      case _ChatMenuOption.viewProfile:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()),
        );
        break;
      case _ChatMenuOption.muteNotifications:
        setState(() {
          notificationsMuted = !notificationsMuted;
        });
        _showToast(notificationsMuted
            ? 'Notifications muted'
            : 'Notifications unmuted');
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
          onConfirm: () {
            _showToast('User blocked and chat removed');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        );
        break;
      case _ChatMenuOption.report:
        final didBlock = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (_) => ReportUserScreen(userName: widget.name),
          ),
        );
        if (didBlock == true) {
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
          onConfirm: () {
            setState(() {
              messages.clear();
            });
            _showToast('Conversation deleted');
          },
        );
        break;
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
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
              child: Text(confirmText,
                  style: TextStyle(color: Colors.pink.shade700)),
            ),
          ],
        );
      },
    );
  }

  void _showChatRestrictedDialog() {
    final timeString = _currentTimeLabel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Chat Restricted',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You've repeatedly attempted to share contact details. Please review our community guidelines.",
                style: TextStyle(color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Time $timeString',
                      style: TextStyle(color: Colors.pink.shade700, fontSize: 12),
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('I Understand', style: TextStyle(color: Colors.pink.shade700)),
            )
          ],
        );
      },
    );
  }

  String _currentTimeLabel() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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
              backgroundImage: AssetImage(widget.image),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Text("Online",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
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
                child: Text(notificationsMuted
                    ? 'Unmute Notifications'
                    : 'Mute Notifications'),
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
          )
        ],
      ),

      body: Column(
        children: [
          /// CHAT LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              children: [
                /// TODAY DIVIDER
                Row(
                  children: [
                    Expanded(
                        child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Today",
                          style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                        child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 10),

                /// MESSAGES
                ...messages.map((msg) {
                  bool isMe = msg["isMe"];

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          constraints:
                              const BoxConstraints(maxWidth: 260),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFFEFD6DE)
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                          ),
                          child: Text(
                            msg["text"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                        /// TIME + TICKS
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg["time"],
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.done_all,
                                  size: 14, color: Colors.pink),
                            ]
                          ],
                        )
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 10),

                /// TYPING INDICATOR
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withAlpha((0.05 * 255).round()),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Dot(),
                        SizedBox(width: 4),
                        Dot(),
                        SizedBox(width: 4),
                        Dot(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          /// INPUT BAR
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: "Type your message..",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Icon(Icons.emoji_emotions_outlined,
                            color: Colors.grey)
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// TYPING DOT
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