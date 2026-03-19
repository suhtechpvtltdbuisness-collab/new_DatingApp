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
      "text": "Sure, let's do it! 😊",
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
      backgroundColor: const Color(0xFFF7F7F7),

      /// App Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [

            CircleAvatar(
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
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            )
          ],
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black)
        ],
      ),

      body: Column(
        children: [

          /// Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {

                bool isMe = messages[index]["isMe"];

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        constraints:
                            const BoxConstraints(maxWidth: 260),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFEAD1DC)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(messages[index]["text"]),
                      ),

                      Text(
                        messages[index]["time"],
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          /// Message Input
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Your message",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: Colors.pink,
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: sendMessage,
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