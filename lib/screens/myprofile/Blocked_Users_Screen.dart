import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // List of blocked users - in real app, this would come from API/local storage
  final List<Map<String, dynamic>> _blockedUsers = [
    {'id': '1', 'name': 'Rahul', 'avatar': 'R'},
    {'id': '2', 'name': 'Rahul', 'avatar': 'R'},
    {'id': '3', 'name': 'Rahul', 'avatar': 'R'},
    {'id': '4', 'name': 'Rahul', 'avatar': 'R'},
    {'id': '5', 'name': 'Rahul', 'avatar': 'R'},
  ];

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
                    color: Colors.pink.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_open,
                    size: 50,
                    color: Colors.pink.shade400,
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
                    border: Border.all(color: Colors.pink),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.pink,
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
                    color: Colors.pink,
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

  // Method to unblock a user
  void _unblockUser(String userId, String userName) {
    setState(() {
      _blockedUsers.removeWhere((user) => user['id'] == userId);
    });

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userName has been unblocked'),
        backgroundColor: const Color(0xFFE91E63),
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
            colors: [Color(0xFFF6C1CC), Color(0xFFD6C7F4)],
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
                child: _blockedUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _blockedUsers.length,
                        itemBuilder: (context, index) {
                          final user = _blockedUsers[index];
                          return UserCard(
                            name: user['name'],
                            avatar: user['avatar'],
                            onUnblock: () => _showUnblockDialog(
                              context,
                              user['id'],
                              user['name'],
                            ),
                          );
                        },
                      ),
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
            'All users have been unblocked',
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
            backgroundColor: const Color(0xFFD6C7F4),
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
                  color: const Color(0xFFE91E63), // Pink border
                  width: 1.5,
                ),
                color: Colors.transparent,
              ),
              child: const Text(
                "Unblock",
                style: TextStyle(
                  color: Color(0xFFE91E63), // Pink text
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