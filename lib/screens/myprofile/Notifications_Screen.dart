import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool pushNotifications = true;
  bool messages = true;
  bool matches = true;
  bool likes = false;
  bool appUpdates = true;

  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFFF3D77),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ✅ GRADIENT BACKGROUND
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: const [
                    BackButton(color: Colors.black),
                    Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// SWITCHES
                buildSwitchTile(
                  "Push Notifications",
                  pushNotifications,
                  (val) => setState(() => pushNotifications = val),
                ),

                buildSwitchTile(
                  "Messages",
                  messages,
                  (val) => setState(() => messages = val),
                ),

                buildSwitchTile(
                  "New Matches",
                  matches,
                  (val) => setState(() => matches = val),
                ),

                buildSwitchTile(
                  "Likes & Reactions",
                  likes,
                  (val) => setState(() => likes = val),
                ),

                buildSwitchTile(
                  "App Updates",
                  appUpdates,
                  (val) => setState(() => appUpdates = val),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}