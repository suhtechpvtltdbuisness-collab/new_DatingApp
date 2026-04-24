import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final Function(int)? onTabTapped;

  const ChatListScreen({super.key, this.onTabTapped});

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
                    "Chats",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onTabTapped?.call(1); // Go to People tab
                    },
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
                    hintText: "Search matches or chats",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Matches Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Your matches",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(color: Colors.pink),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Horizontal avatars
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [

                  _matchAvatar("assets/images/profile.png", "Sourabh"),
                  _matchAvatar("assets/images/profile.png", "Ankit"),
                  _matchAvatar("assets/images/profile.png", "Rahul"),

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
                            "50+",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Likes"),
                    ],
                  ),
                ],
              ),
            ),

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
                            "YOUR OPENING MOVES",
                            style: TextStyle(
                                color: Colors.pink,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "What's the best piece of advice you've received?",
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios, size: 16)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Chat List
            Expanded(
              child: ListView(
                children: [

                  _chatTile(
                    context,
                    "Sourabh",
                    "Hey! How are you?",
                    "12:30 PM",
                    true,
                  ),

                  _chatTile(
                    context,
                    "Ankit",
                    "You matched! Start the conversation",
                    "Yesterday",
                    false,
                  ),

                  _chatTile(
                    context,
                    "Rahul",
                    "Let's grab coffee soon?",
                    "Oct 12",
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Match avatar widget
  static Widget _matchAvatar(String image, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(image),
          ),
          const SizedBox(height: 5),
          Text(name),
        ],
      ),
    );
  }

  /// Chat tile with navigation
  static Widget _chatTile(
      BuildContext context,
      String name,
      String message,
      String time,
      bool unread) {

    return ListTile(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              name: name,
              image: "assets/images/profile.png",
            ),
          ),
        );
      },

      leading: const CircleAvatar(
        backgroundImage: AssetImage("assets/images/profile.png"),
      ),

      title: Text(name),

      subtitle: Text(message),

      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontSize: 12)),

          if (unread)
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "2",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}