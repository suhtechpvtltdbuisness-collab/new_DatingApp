import 'package:flutter/material.dart';

class ImprovedProfileScreen extends StatelessWidget {
  const ImprovedProfileScreen({super.key});

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
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
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
                      "Improve Your Profile",
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
                    tip('Use clear photos (face + full body, no heavy filters).'),
                    tip('Write a short, real bio (interests, vibe, what you want).'),
                    tip('Be honest about age, job, and intentions.'),
                    tip('Add prompts to spark conversations.'),
                    tip('Stay active & responsive.'),
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