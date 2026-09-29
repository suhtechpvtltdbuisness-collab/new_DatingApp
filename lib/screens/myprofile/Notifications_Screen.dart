import 'package:dating_app/services/notification_service.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      pushNotifications =
          prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
      messages = prefs.getBool(StorageKeys.messageNotifications) ?? true;
      matches = prefs.getBool(StorageKeys.matchNotifications) ?? true;
      _loading = false;
    });
  }

  Future<void> _setPush(bool value) async {
    setState(() => pushNotifications = value);
    await NotificationService.instance.setPushEnabled(value);
  }

  Future<void> _setMessages(bool value) async {
    setState(() => messages = value);
    await NotificationService.instance.setMessagesEnabled(value);
  }

  Future<void> _setMatches(bool value) async {
    setState(() => matches = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.matchNotifications, value);
  }

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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      buildSwitchTile(
                        "Push Notifications",
                        pushNotifications,
                        _setPush,
                      ),
                      buildSwitchTile(
                        "Messages",
                        messages,
                        _setMessages,
                      ),
                      buildSwitchTile(
                        "New Matches",
                        matches,
                        _setMatches,
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
