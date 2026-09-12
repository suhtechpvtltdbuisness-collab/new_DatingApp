import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';
import '../chat/chat_list_screen.dart';
import '../filter/filter_screen.dart';
import '../myprofile/my_profile_screen.dart';
import '../like/liked_you_screen.dart';
import '../swipe/swipe_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthService().isLoggedIn()) {
        AppRoutes.toOnboarding();
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              if (_currentIndex == 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.heroGradient.createShader(bounds),
                        child: const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.softShadow(),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FilterScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.tune_rounded, size: 22, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    LikedYouScreen(onTabTapped: _onTabTapped),
                    const SwipeScreen(),
                    ChatListScreen(onTabTapped: _onTabTapped),
                    MyProfileScreen(onTabTapped: _onTabTapped),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.14),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Liked you'),
                      _buildNavItem(1, Icons.people_outline_rounded, Icons.people_alt_rounded, 'People'),
                      _buildNavItem(2, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
                      _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.heroGradient : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? Colors.white : AppTheme.textTertiaryColor, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.white : AppTheme.textTertiaryColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
