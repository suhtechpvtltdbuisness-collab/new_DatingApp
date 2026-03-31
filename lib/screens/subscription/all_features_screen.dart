import 'package:flutter/material.dart';

class AllFeaturesScreen extends StatelessWidget {
  const AllFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEED6DF),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "All Features",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Why you'll love",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Premium",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Get more of the best with exclusive features designed for meaningful connections.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// SECTION 1
                    _sectionTitle("FIND GREAT PEOPLE FASTER"),

                    _bigCard(
                      icon: Icons.remove_red_eye,
                      title: "See who liked you",
                      subtitle: "Cut the waiting and match instantly.",
                    ),

                    _bigCard(
                      icon: Icons.all_inclusive,
                      title: "Unlimited likes",
                      subtitle: "Swipe as much as your heart desires.",
                    ),

                    _bigCard(
                      icon: Icons.tune,
                      title: "Advanced filters",
                      subtitle: "Find exactly who you're looking for.",
                    ),

                    const SizedBox(height: 20),

                    /// SECTION 2
                    _sectionTitle("BE SEEN WHEN IT COUNTS"),

                    _smallItem(
                      icon: Icons.star,
                      title: "5 SuperSwipes a week",
                      subtitle: "Tell them you're really interested.",
                    ),

                    _smallItem(
                      icon: Icons.flash_on,
                      title: "1 Spotlight a week",
                      subtitle: "Be the top profile in your area for 30 mins.",
                    ),

                    const SizedBox(height: 20),

                    /// SECTION 3
                    _sectionTitle("MAKE IT YOURS"),

                    _smallItem(
                      icon: Icons.visibility_off,
                      title: "Incognito mode",
                      subtitle: "Only people you've liked will see you.",
                    ),

                    _smallItem(
                      icon: Icons.public,
                      title: "Travel mode",
                      subtitle: "Change your location and swipe anywhere.",
                    ),

                    _smallItem(
                      icon: Icons.undo,
                      title: "Unlimited Backtrack",
                      subtitle: "Accidentally swiped left? Bring them back.",
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// BOTTOM NAV (OPTIONAL)
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// BIG CARD
  Widget _bigCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.pink),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// SMALL ITEM
  Widget _smallItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.pink),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// BOTTOM NAV
  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border),
              SizedBox(height: 4),
              Text("Liked you"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people),
              SizedBox(height: 4),
              Text("People"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline),
              SizedBox(height: 4),
              Text("Chat"),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, color: Colors.pink),
              SizedBox(height: 4),
              Text("Profile"),
            ],
          ),
        ],
      ),
    );
  }
}