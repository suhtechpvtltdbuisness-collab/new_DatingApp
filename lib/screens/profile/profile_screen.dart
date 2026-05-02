import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileDetailsContent();
  }
}

class ProfileDetailsContent extends StatelessWidget {
  const ProfileDetailsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// SAY HELLO — pass context here ✅
              _button(context, "Say Hello to Akshat 👋", true),

              const SizedBox(height: 15),

              /// LIKE — pass context here ✅
              _button(context, "Like ❤️", false),

              const SizedBox(height: 25),

              _sectionTitle(Icons.info, "My Story"),
              const SizedBox(height: 10),
              const Text(
                "I'm a minimalist by profession but a maximalist at heart "
                "when it comes to experiences. By day, I design sustainable "
                "urban spaces that breathe life back into the city.\n\n"
                "Born in Milan, refined in London, and now making Barcelona "
                "my canvas. Looking for someone who values intellectual curiosity "
                "and enjoys spontaneous weekend trips.",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.photo, color: Colors.pink),
                      SizedBox(width: 8),
                      Text("Life Highlights",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Text("View all 12 >", style: TextStyle(color: Colors.pink))
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _image("assets/images/profile.png", 310)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _image("assets/images/profile.png", 150),
                        const SizedBox(height: 10),
                        _image("assets/images/profile.png", 150),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _sectionTitle(Icons.bolt, "The Vibe"),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _chip("Active"),
                  _chip("Non-smoker"),
                  _chip("Virgo"),
                  _chip("Social Drinker"),
                  _chip("Wants Kids"),
                ],
              ),

              const SizedBox(height: 25),

              _sectionTitle(Icons.check_circle, "The Essentials"),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _essentialItem(Icons.work_outline, "PROFESSION", "Senior Architect"),
                    _divider(),
                    _essentialItem(Icons.school_outlined, "EDUCATION", "Politecnico di Milano"),
                    _divider(),
                    _essentialItem(Icons.home_outlined, "HOMETOWN", "Milan, Italy"),
                    _divider(),
                    _essentialItem(Icons.language, "LANGUAGES", "English, Italian, Spanish"),
                    _divider(),
                    _essentialItem(Icons.access_time, "DAILY ROUTINE", "Early Bird"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _topChip("Active"),
                  _topChip("Non-smoker"),
                  _topChip("Virgo"),
                  _topChip("Social Drinker"),
                  _topChip("Wants Kids"),
                ],
              ),

              const SizedBox(height: 25),

              _sectionTitle(Icons.music_note, "Current Rotation"),
              const SizedBox(height: 15),

              _musicCard("Pink + White", "Frank Ocean"),
              const SizedBox(height: 10),
              _musicCard("After Dark", "Mr. Kitty"),
              const SizedBox(height: 10),
              _musicCard("Titi Me Pregunto", "Bad Bunny"),

              const SizedBox(height: 25),

              _sectionTitle(Icons.chat_bubble_outline, "Deep Dives"),
              const SizedBox(height: 15),

              _deepDiveCard(
                "My Sunday morning looks like...",
                "Waking up at 8 AM without an alarm, a slow walk to the florist, and then spending two hours over a pour-over coffee while reading a physical copy of architectural digest.",
              ),

              const SizedBox(height: 15),

              _deepDiveCard(
                "The quickest way to my heart is...",
                "Through a shared love of travel and culture. If you can recommend a hidden gem in any city or share a story from your travels, we're off to a great start.",
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  "Report or Block Profile",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- REUSABLES ----------

  /// ✅ Fixed: context is now a parameter
  Widget _button(BuildContext context, String text, bool filled) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: filled
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: 'new', // placeholder until a real match chat is created
                      name: "Akshat",
                      image: "assets/images/profile.png",
                    ),
                  ),
                );
              },
              child: Text(text),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.pink),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {},
              child: Text(text, style: const TextStyle(color: Colors.pink)),
            ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.pink),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _image(String path, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(path, height: height, fit: BoxFit.cover),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(text),
    );
  }

  Widget _topChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(text, style: const TextStyle(color: Colors.pink)),
    );
  }

  Widget _musicCard(String title, String artist) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, color: Colors.pink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(artist, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.graphic_eq, color: Colors.pink),
        ],
      ),
    );
  }

  Widget _essentialItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade200);

  Widget _deepDiveCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('" $title"',
              style: const TextStyle(
                  color: Colors.pink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}