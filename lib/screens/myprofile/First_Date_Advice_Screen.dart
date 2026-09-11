import 'package:flutter/material.dart';

class FirstDateAdviceScreen extends StatelessWidget {
  const FirstDateAdviceScreen({super.key});

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
                      "First Date Advice",
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
                    tip("Keep it casual & public."),
                    tip("Arrive on your own."),
                    tip("Inform a friend beforehand."),
                    tip("Stay confident, be yourself."),
                    tip("Avoid checking your phone frequently."),
                    tip("End the date on a positive note."),
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