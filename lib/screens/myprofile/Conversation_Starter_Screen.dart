import 'package:flutter/material.dart';

class ConversationStarterScreen extends StatelessWidget {
  const ConversationStarterScreen({super.key});

  Widget chat(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD3DC), Color(0xFFD6C4F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: const [
                  BackButton(),
                  Text(
                    "Conversation Starters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    chat("What’s your favorite travel destination?"),
                    chat("What do you enjoy doing on weekends?"),
                    chat("What kind of movies do you like?"),
                    chat("Do you prefer coffee or tea?"),
                    chat("What’s something you’re passionate about?"),
                    chat("What’s the best memory from your childhood?"),
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