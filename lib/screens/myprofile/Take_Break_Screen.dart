import 'package:flutter/material.dart';

class TakeBreakScreen extends StatefulWidget {
  const TakeBreakScreen({super.key});

  @override
  State<TakeBreakScreen> createState() => _TakeBreakScreenState();
}

class _TakeBreakScreenState extends State<TakeBreakScreen> {
  int selectedOption = 0;

  bool hideProfile = false;
  bool disableNotifications = false;
  bool keepMatches = false;

  Widget buildOption(String text, int value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Radio(
            value: value,
            groupValue: selectedOption,
            activeColor: const Color(0xFFFF3D77),
            onChanged: (val) {
              setState(() {
                selectedOption = val!;
              });
            },
          ),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildSwitch(String text, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF3D77),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D3DC), // soft gradient feel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Take a Break",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pause account for",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            buildOption("24 hrs", 0),
            buildOption("7 days", 1),
            buildOption("Until manually resumed", 2),

            const SizedBox(height: 10),

            buildSwitch("Hide profile during break", hideProfile, (val) {
              setState(() => hideProfile = val);
            }),

            buildSwitch("Disable notifications", disableNotifications, (val) {
              setState(() => disableNotifications = val);
            }),

            buildSwitch("Keep matches saved", keepMatches, (val) {
              setState(() => keepMatches = val);
            }),
          ],
        ),
      ),
    );
  }
}