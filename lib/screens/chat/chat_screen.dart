import 'package:flutter/material.dart';

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

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

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
    if (messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": messageController.text,
        "isMe": true,
        "time": "Now"
      });
    });

    messageController.clear();
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
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert, color: Colors.black),
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
                          color: Colors.black12.withOpacity(0.05),
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