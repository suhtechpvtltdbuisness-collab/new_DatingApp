import 'package:dating_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService.instance;
  late bool pushNotifications = _service.pushEnabled;
  late bool messages = _service.messagesEnabled;
  late bool matches = _service.matchesEnabled;
  late bool likes = _service.likesEnabled;
  late bool accountUpdates = _service.accountEnabled;

  Future<void> _setPush(bool value) async {
    setState(() => pushNotifications = value);
    await _service.setPushEnabled(value);
  }

  Future<void> _setMessages(bool value) async {
    setState(() => messages = value);
    await _service.setMessagesEnabled(value);
  }

  Future<void> _setMatches(bool value) async {
    setState(() => matches = value);
    await _service.setMatchesEnabled(value);
  }

  Future<void> _setLikes(bool value) async {
    setState(() => likes = value);
    await _service.setLikesEnabled(value);
  }

  Future<void> _setAccountUpdates(bool value) async {
    setState(() => accountUpdates = value);
    await _service.setAccountEnabled(value);
  }

  /// Category switches only matter while push notifications are on.
  Function(bool)? _whenPushOn(Function(bool) onChanged) =>
      pushNotifications ? onChanged : null;

  Widget buildSwitchTile(String title, bool value, Function(bool)? onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
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
            child: Column(
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
                  _whenPushOn(_setMessages),
                ),
                buildSwitchTile(
                  "New Matches",
                  matches,
                  _whenPushOn(_setMatches),
                ),
                buildSwitchTile(
                  "Likes & Super Likes",
                  likes,
                  _whenPushOn(_setLikes),
                ),
                buildSwitchTile(
                  "Account & Safety Updates",
                  accountUpdates,
                  _whenPushOn(_setAccountUpdates),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(6, 14, 6, 0),
                  child: Text(
                    "These control alerts on this device. Everything still appears in the notifications list.",
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
