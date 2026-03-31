import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

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

              // ✅ List of Users (IMPORTANT: no const here)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    UserCard(name: "Rahul"),
                    UserCard(name: "Rahul"),
                    UserCard(name: "Rahul"),
                    UserCard(name: "Rahul"),
                    UserCard(name: "Rahul"),
                    UserCard(name: "Rahul"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String name;

  const UserCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // ❌ not const-safe
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFD6C7F4),
            child: Text(
              name[0],
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

          // Unblock Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
              color: Colors.grey.shade200,
            ),
            child: const Text("Unblock"),
          ),
        ],
      ),
    );
  }
}