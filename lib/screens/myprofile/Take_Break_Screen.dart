import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';

class TakeBreakChoice {
  const TakeBreakChoice({
    required this.hideProfile,
    required this.disableNotifications,
    required this.keepMatches,
    required this.untilLabel,
  });

  final bool hideProfile;
  final bool disableNotifications;
  final bool keepMatches;
  final String untilLabel;
}

class TakeBreakScreen extends StatefulWidget {
  const TakeBreakScreen({super.key});

  @override
  State<TakeBreakScreen> createState() => _TakeBreakScreenState();
}

class _TakeBreakScreenState extends State<TakeBreakScreen> {
  int selectedOption = 0;
  bool hideProfile = true;
  bool disableNotifications = true;
  bool keepMatches = true;

  String get _untilLabel {
    switch (selectedOption) {
      case 0:
        return 'for 24 hours';
      case 1:
        return 'for 7 days';
      default:
        return 'until you turn it off';
    }
  }

  Widget buildOption(String text, int value) {
    final selected = selectedOption == value;
    return InkWell(
      onTap: () => setState(() => selectedOption = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFF3D77) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: selectedOption,
              activeColor: const Color(0xFFFF3D77),
              onChanged: (val) {
                if (val == null) return;
                setState(() => selectedOption = val);
              },
            ),
            Text(text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget buildSwitch(String text, bool value, ValueChanged<bool> onChanged) {
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
      backgroundColor: const Color(0xFFE9D3DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Take a Break',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pause account for', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            buildOption('24 hrs', 0),
            buildOption('7 days', 1),
            buildOption('Until manually resumed', 2),
            const SizedBox(height: 10),
            buildSwitch(
              'Hide profile during break',
              hideProfile,
              (val) => setState(() => hideProfile = val),
            ),
            buildSwitch(
              'Disable notifications',
              disableNotifications,
              (val) => setState(() => disableNotifications = val),
            ),
            buildSwitch(
              'Keep matches saved',
              keepMatches,
              (val) => setState(() => keepMatches = val),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    TakeBreakChoice(
                      hideProfile: hideProfile,
                      disableNotifications: disableNotifications,
                      keepMatches: keepMatches,
                      untilLabel: _untilLabel,
                    ),
                  );
                },
                child: const Text(
                  'Start break',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
