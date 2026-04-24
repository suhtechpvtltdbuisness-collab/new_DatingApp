import 'package:flutter/material.dart';
import '../chat/chat_list_screen.dart';
import '../filter/filter_screen.dart';
import '../profile/profile_screen.dart';
import '../myprofile/my_profile_screen.dart';
import '../like/liked_you_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  
  const HomeScreen({super.key, this.initialIndex = 1});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex; // Default to "People" tab (index 1)

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6EB),
      body: SafeArea(
        child: Column(
          children: [
            /// Header - Only show on People tab
            if (_currentIndex == 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Hookup",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FilterScreen(),
                          ),
                        );
                      },
                      child: const Icon(Icons.tune, size: 26),
                    ),
                  ],
                ),
              ),

            /// Content using IndexedStack to keep all screens in memory
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  LikedYouScreen(onTabTapped: _onTabTapped),
                  _buildPeopleTab(), // People tab
                  ChatListScreen(onTabTapped: _onTabTapped),
                  MyProfileScreen(onTabTapped: _onTabTapped),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Bottom Tab Bar
            Container(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileDetailsScreen(),
            ),
          );
        },
        child: Stack(
          children: [
            /// Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/profile.png",
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            /// Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),

            /// Info
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Photo verified",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Akshat, 29",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        color: Colors.white70,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Engineer at IT Sector",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Like Button
            Positioned(
              bottom: 20,
              left: 40,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.pink,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
              ),
            ),

            /// Star Button
            Positioned(
              bottom: 20,
              right: 40,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.purple,
                child: const Icon(Icons.star, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.pink : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.pink : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
