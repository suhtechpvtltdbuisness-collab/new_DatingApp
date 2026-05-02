import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';

class MatchScreen extends StatelessWidget {

  final String userName;
  final String image1;
  final String image2;

  const MatchScreen({
    super.key,
    required this.userName,
    required this.image1,
    required this.image2,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEED1DA),

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            /// Match Images
            Stack(
              alignment: Alignment.center,
              children: [

                Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    width: 180,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(image1),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(80, -40),
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      width: 180,
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(image2),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// Title
            Text(
              "It's a match, $userName!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Start a conversation now with each other",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            /// Say Hello Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: 'new', // placeholder — will be replaced with real chatId from match response
                        name: userName,
                        image: image2,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Say hello",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// Keep Swiping
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.pink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {

                  Navigator.pop(context);

                },
                child: const Text(
                  "Keep swiping",
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}