import 'package:flutter/material.dart';
import '../subscription/subscription_screen.dart';

class LikedYouScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const LikedYouScreen({super.key, this.onTabTapped});

  @override
  State<LikedYouScreen> createState() => _LikedYouScreenState();
}

class _LikedYouScreenState extends State<LikedYouScreen> {
  int _selectedFilter = 0; // 0 = All, 1 = New, 2 = Nearby

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilter = index;
    });
    // TODO: Add filtering logic here based on selected filter
    // You can filter the profile list based on: All, New, or Nearby
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9C6D0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Liked You",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     onTabTapped?.call(1); // Go to People tab
                  //   },
                  //   child: const Icon(Icons.people_outline, size: 28),
                  // ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Check out people who liked your profile!",
                style: TextStyle(color: Colors.black54),
              ),
            ),

            const SizedBox(height: 20),

            /// MUST SEE PROFILES
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Must-see profiles",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            /// HORIZONTAL CARDS
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildProfileCard("SK, 25", "95% MATCH"),
                  _buildProfileCard("Alex, 24", "NEW"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// FILTER BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildChip("All 42", _selectedFilter == 0, () => _onFilterSelected(0)),
                  _buildChip("New 12", _selectedFilter == 1, () => _onFilterSelected(1)),
                  _buildChip("Nearby 8", _selectedFilter == 2, () => _onFilterSelected(2)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PREMIUM BOX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Someone already likes you.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Upgrade to Premium to see your full list of likes and match instantly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    /// BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5C8A), Color(0xFFFF2E63)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "Upgrade to Premium",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// PROFILE CARD
  Widget _buildProfileCard(String name, String tag) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage("assets/images/profile.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(tag, style: const TextStyle(color: Colors.pink, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// CHIP
  Widget _buildChip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.pink : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: active ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
