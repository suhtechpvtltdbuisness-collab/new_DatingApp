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
  late int _currentIndex;

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

            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  LikedYouScreen(onTabTapped: _onTabTapped),
                  _buildPeopleTab(),
                  ChatListScreen(onTabTapped: _onTabTapped),
                  MyProfileScreen(onTabTapped: _onTabTapped),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
            // ── Full image — fills entire card ──
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/profile.png",
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // ── Gradient: dark at bottom, transparent at top ──
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.5],
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),

            // ── Photo verified + Name + Job ──
            Positioned(
              bottom: 160,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 15),
                      SizedBox(width: 5),
                      Text(
                        "Photo verified",
                        style: TextStyle(color: Colors.white, fontSize: 13),
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
                      Icon(Icons.work_outline, color: Colors.white70, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Engineer at IT Sector",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Like button (bottom-left) ──
            Positioned(
              bottom: 96,
              left: 36,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.pink,
                child: const Icon(Icons.favorite, color: Colors.white, size: 26),
              ),
            ),

            // ── Star button (bottom-right) ──
            Positioned(
              bottom: 96,
              right: 36,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.purple,
                child: const Icon(Icons.star, color: Colors.white, size: 26),
              ),
            ),

            // ── "WE HAVE THINGS IN COMMON" card — inside image at very bottom ──
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "WE HAVE THINGS IN COMMON",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCommonChip(Icons.circle_outlined, "Hindu"),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _buildCommonChip(
                            Icons.school_outlined,
                            "Undergraduate degree",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
          Icon(icon, color: isActive ? Colors.pink : Colors.grey),
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