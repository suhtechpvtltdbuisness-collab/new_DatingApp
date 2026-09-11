import 'package:flutter/material.dart';
import 'package:dating_app/utils/theme.dart';

class AllFeaturesScreen extends StatefulWidget {
  final int initialIndex;

  const AllFeaturesScreen({super.key, this.initialIndex = 3});

  @override
  State<AllFeaturesScreen> createState() => _AllFeaturesScreenState();
}

class _AllFeaturesScreenState extends State<AllFeaturesScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the corresponding screen based on index
    // Replace the navigation logic below to match your app's routing:
    //
    // if (index == 0) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 0)));
    // } else if (index == 1) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)));
    // } else if (index == 2) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 2)));
    // } else if (index == 3) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 3)));
    // }

    // OR simply pop back to HomeScreen with the selected index:
    Navigator.pop(context, index);
  }

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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
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

            /// BOTTOM NAV
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

  /// BIG CARD — Fixed overflow with Expanded + flexible text
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
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            // ← Fix: prevents right overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SMALL ITEM — Fixed overflow with Expanded + flexible text
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
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            // ← Fix: prevents right overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BOTTOM NAV — Now matches HomeScreen with active/inactive states
  Widget _bottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.favorite_border, "Liked you"),
          _buildNavItem(1, Icons.people, "People"),
          _buildNavItem(2, Icons.chat_bubble_outline, "Chat"),
          _buildNavItem(3, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  /// NAV ITEM — Active/inactive styling matching HomeScreen exactly
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryColor : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
