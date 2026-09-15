import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/utils/theme.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final UserController _userController = Get.find<UserController>();
  String? _loadError;
  String? _unblockingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    final ok = await _userController.getBlockedUsers();
    if (!mounted) return;
    if (!ok) {
      setState(() => _loadError = _userController.errorMessage.value.isNotEmpty
          ? _userController.errorMessage.value
          : 'Could not load blocked users');
    }
  }

  // Method to show unblock confirmation dialog
  void _showUnblockDialog(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// IMAGE
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_open,
                    size: 50,
                    color: AppTheme.primaryColor.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Unblock $userName?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "You will be able to see their profile and send them messages again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 20),

                /// Cancel
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Unblock
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _unblockUser(userId, userName);
                    },
                    child: const Text(
                      "Unblock",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Note: You can block them again anytime.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Unblock via DELETE /users/:id/unblock/:blockedUserId
  Future<void> _unblockUser(String userId, String userName) async {
    setState(() => _unblockingId = userId);
    final ok = await _userController.unblockUser(userId);
    if (!mounted) return;
    setState(() => _unblockingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '$userName has been unblocked'
            : (_userController.errorMessage.value.isNotEmpty
                ? _userController.errorMessage.value
                : 'Could not unblock $userName')),
        backgroundColor: ok ? const Color(0xFFFF3D77) : Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔙 Back + Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Blocked Users",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ✅ List of Users
              Expanded(
                child: Obx(() {
                  final users = _userController.blockedProfiles.toList();
                  if (_userController.isLoadingBlocked.value && users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_loadError != null && users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_loadError!, style: const TextStyle(color: Colors.red)),
                          TextButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    );
                  }
                  if (users.isEmpty) return _buildEmptyState();
                  return RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final name = user.fullName.isEmpty ? 'Member' : user.fullName;
                        return UserCard(
                          name: name,
                          avatar: name.substring(0, 1).toUpperCase(),
                          onUnblock: _unblockingId != null
                              ? () {}
                              : () => _showUnblockDialog(context, user.id, name),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state when no blocked users
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Blocked Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'People you block will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String name;
  final String avatar;
  final VoidCallback onUnblock;

  const UserCard({
    super.key,
    required this.name,
    required this.avatar,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE7D9FF),
            child: Text(
              avatar,
              style: const TextStyle(color: Colors.black),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15),
            ),
          ),

          // Unblock Button - PINK BORDER & PINK TEXT
          GestureDetector(
            onTap: onUnblock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF3D77), // Pink border
                  width: 1.5,
                ),
                color: Colors.transparent,
              ),
              child: const Text(
                "Unblock",
                style: TextStyle(
                  color: Color(0xFFFF3D77), // Pink text
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}