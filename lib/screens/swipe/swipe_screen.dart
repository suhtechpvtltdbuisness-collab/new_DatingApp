import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/swipe_controller.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final SwipableStackController _controller = SwipableStackController();
  final SwipeController swipeController = Get.find<SwipeController>();

  @override
  void initState() {
    super.initState();
    // Load profiles if not already loaded
    if (swipeController.profiles.isEmpty) {
      swipeController.loadProfiles();
    }
  }

  /// Helper method to load more profiles when running out
  Future<void> _moveToNextProfile(int currentIndex) async {
    // Check if we need to load more profiles
    if (currentIndex + 1 >= swipeController.profiles.length) {
      debugPrint("📥 Loading more profiles...");
      await swipeController.loadMoreProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEED1DA),
      body: SafeArea(
        child: Obx(() {
          if (swipeController.isLoading.value && swipeController.profiles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (swipeController.profiles.isEmpty) {
            return const Center(
              child: Text(
                'No more profiles to show',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SwipableStack(
              controller: _controller,
              itemCount: swipeController.profiles.length,
              onSwipeCompleted: (index, swipeDirection) async {
                final profile = swipeController.profiles[index];

                if (swipeDirection == SwipeDirection.left) {
                  // ❌ LEFT SWIPE = PASS (Skip profile, show next)
                  debugPrint("⬅️ Swiped Left - Passing profile: ${profile.fullName}");
                  await swipeController.passProfile(profile);
                  await _moveToNextProfile(index);
                } else if (swipeDirection == SwipeDirection.right) {
                  // ❤️ RIGHT SWIPE = LIKE (Like profile, check for match)
                  debugPrint("➡️ Swiped Right - Liking profile: ${profile.fullName}");
                  final success = await swipeController.likeProfile(profile);
                  
                  if (success) {
                    // Check if it's a match
                    if (swipeController.successMessage.value.contains("match")) {
                      debugPrint("🎉 MATCH FOUND with ${profile.fullName}!");
                      // Show match screen for 2 seconds then go back
                      if (mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchScreen(
                              userName: profile.fullName,
                              image1: "assets/images/profile.png",
                              image2: profile.photoUrls.isNotEmpty 
                                  ? profile.photoUrls.first 
                                  : "assets/images/profile.png",
                            ),
                          ),
                        );
                      }
                    } else {
                      debugPrint("👍 Liked ${profile.fullName} (no match yet)");
                    }
                    await _moveToNextProfile(index);
                  } else {
                    debugPrint("❌ Failed to like profile");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to like profile. Try again.")),
                    );
                  }
                }
              },
              builder: (context, properties) {
                final profile = swipeController.profiles[properties.index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: profile.photoUrls.isNotEmpty
                            ? Image.network(
                                profile.photoUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset("assets/images/profile.png", fit: BoxFit.cover),
                              )
                            : Image.asset(
                                "assets/images/profile.png",
                                fit: BoxFit.cover,
                              ),
                      ),
                      // Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black54],
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Name and age
                      Positioned(
                        bottom: 30,
                        left: 20,
                        child: Text(
                          "${profile.fullName}, ${profile.age}",
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
          );
        }),
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
            // Profile Cards
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
            // Match Text
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
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            // Say Hello Button
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
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Keep Swiping
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
                  style: const TextStyle(color: Colors.pink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}