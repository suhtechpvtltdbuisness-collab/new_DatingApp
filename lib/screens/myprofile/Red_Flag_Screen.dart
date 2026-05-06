import 'package:flutter/material.dart';

class RedFlagScreen extends StatelessWidget {
  const RedFlagScreen({super.key});

  /// TIP CARD
  Widget tip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD3DC), Color(0xFFD6C4F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 APP BAR (FIXED)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Red Flags to Watch",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              /// LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    tip('Moves too fast ("I love you" in days).'),
                    tip('Avoids video calls or real-life meetups.'),
                    tip('Asks for money, gifts, or favors.'),
                    tip('Pushes for personal info too soon.'),
                    tip('Inconsistent stories or profile details.'),
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