import 'package:flutter/material.dart';
class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  Widget buildTile(String title, [String? description]) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
            ),
          ],
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
                    SizedBox(width: 8),
                    Text(
                      "Community Guidelines",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                buildTile("Be respectful & honest"),
                buildTile("No harassment or hate"),
                buildTile("No fake profiles"),
                buildTile("Keep conversations safe"),
                buildTile(
                  "No sharing phone numbers or contact details",
                  "Exchanging phone numbers is not allowed — including numbers "
                  "written in words, spaced out or disguised with letters. The "
                  "same applies to other contact details. Messages that break "
                  "this rule are blocked, and repeated attempts can restrict "
                  "your chats.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}