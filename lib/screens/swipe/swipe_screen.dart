import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {

  final SwipableStackController _controller = SwipableStackController();

  final List<Map<String, String>> profiles = [
    {
      "name": "Akshat",
      "age": "29",
      "image": "assets/images/profile.png"
    },
    {
      "name": "Rahul",
      "age": "27",
      "image": "assets/images/profile.png"
    },
    {
      "name": "Sourabh",
      "age": "28",
      "image": "assets/images/profile.png"
    },
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEED1DA),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: SwipableStack(
            controller: _controller,
            itemCount: profiles.length,

            onSwipeCompleted: (index, direction) {

              /// LEFT SWIPE
              if (direction == SwipeDirection.left) {
                debugPrint("Not Interested");
              }

              /// RIGHT SWIPE
              if (direction == SwipeDirection.right) {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchScreen(
                      userName: profiles[index]["name"]!,
                      image1: "assets/images/profile.png",
                      image2: profiles[index]["image"]!,
                    ),
                  ),
                );

              }
            },

            builder: (context, properties) {

              final profile = profiles[properties.index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(25),

                child: Stack(
                  children: [

                    Positioned.fill(
                      child: Image.asset(
                        profile["image"]!,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// Gradient
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black54
                            ],
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    /// Name
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: Text(
                        "${profile["name"]}, ${profile["age"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

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

            /// Profile Cards
            Stack(
              alignment: Alignment.center,
              children: [

                Transform.rotate(
                  angle: -0.25,
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
                    angle: 0.25,
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

                const Positioned(
                  top: 0,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite, color: Colors.pink),
                  ),
                )
              ],
            ),

            const SizedBox(height: 40),

            /// Match Text
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

                  Navigator.pop(context);

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