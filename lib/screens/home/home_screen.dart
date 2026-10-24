import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/controllers/chat_controller.dart';
import 'package:dating_app/controllers/notification_controller.dart';
import 'package:dating_app/screens/notifications/notifications_center_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final NotificationController _notifications =
      Get.find<NotificationController>();
  Worker? _tabRequestWorker;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _tabRequestWorker = ever<int?>(_notifications.requestedTab, (tab) {
      if (tab == null || !mounted) return;
      _notifications.requestedTab.value = null;
      _onTabTapped(tab);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AuthService().isLoggedIn()) {
        AppRoutes.toOnboarding();
        return;
      }
      _notifications.start();
      Get.find<ChatController>().setChatListVisible(_currentIndex == 2);
      if (_currentIndex == HomeTab.likedYou) _notifications.onLikedYouOpened();
      // A tab requested before this screen existed (notification tap on launch).
      final pending = _notifications.requestedTab.value;
      if (pending != null) {
        _notifications.requestedTab.value = null;
        _onTabTapped(pending);
      }
    });
  }

  @override
  void dispose() {
    _tabRequestWorker?.dispose();
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().setChatListVisible(false);
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Get.find<ChatController>().setChatListVisible(index == 2);
    if (index == HomeTab.likedYou) _notifications.onLikedYouOpened();
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
                      Row(
                        children: [
                          _NotificationBell(controller: _notifications),
                          const SizedBox(width: 10),
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
                      Obx(() => _buildNavItem(0, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Liked you',
                          badge: _notifications.newLikes.value)),
                      _buildNavItem(1, Icons.people_outline_rounded, Icons.people_alt_rounded, 'People'),
                      Obx(() => _buildNavItem(2, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat',
                          badge: Get.find<ChatController>().unreadCount.value)),
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

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, {int badge = 0}) {
    final isActive = _currentIndex == index;
    final iconWidget = Icon(isActive ? activeIcon : icon, color: isActive ? Colors.white : AppTheme.textTertiaryColor, size: 22);
    return GestureDetector(
      onTap: () => _onTabTapped(index),
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
            badge > 0 && !isActive
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      iconWidget,
                      Positioned(right: -8, top: -5, child: _CountBadge(count: badge)),
                    ],
                  )
                : iconWidget,
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

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.controller});

  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow(),
      ),
      child: Obx(() {
        final unread = controller.unreadCount.value;
        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => Get.to(() => const NotificationsCenterScreen()),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                unread > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                size: 22,
                color: AppTheme.primaryColor,
              ),
              if (unread > 0)
                Positioned(right: -7, top: -6, child: _CountBadge(count: unread)),
            ],
          ),
        );
      }),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}
