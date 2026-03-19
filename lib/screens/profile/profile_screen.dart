import 'package:flutter/material.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  int _currentIndex = 1; // default = People

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

      /// ---------------- BODY ----------------
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// SAY HELLO
              _button("Say Hello to Akshat 👋", true),

              const SizedBox(height: 15),

              /// LIKE
              _button("Like ❤️", false),

              const SizedBox(height: 25),

              /// MY STORY
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

              /// LIFE HIGHLIGHTS
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

              /// IMAGE GRID
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

              /// VIBE
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

              /// ESSENTIALS
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

              /// EXTRA CHIPS
              Wrap(
                spacing: 10,
                children: [
                  _topChip("Active"),
                  _topChip("Non-smoker"),
                  _topChip("Virgo"),
                  _topChip("Social Drinker"),
                  _topChip("Wants Kids"),
                ],
              ),

              const SizedBox(height: 25),

              /// CURRENT ROTATION
              _sectionTitle(Icons.music_note, "Current Rotation"),
              const SizedBox(height: 15),

              _musicCard("Pink + White", "Frank Ocean"),
              const SizedBox(height: 10),
              _musicCard("After Dark", "Mr. Kitty"),
              const SizedBox(height: 10),
              _musicCard("Titi Me Pregunto", "Bad Bunny"),

              const SizedBox(height: 25),

              /// DEEP DIVES
              _sectionTitle(Icons.chat_bubble_outline, "Deep Dives"),
              const SizedBox(height: 15),

              _deepDiveCard(
                "My Sunday morning looks like...",
                 "Waking up at 8 AM without an alarm, a slow walk to the florist, and then spending two hours over a pour-over coffee while reading a physical copy of architectural digest.",
              ),

              const SizedBox(height: 15),

              _deepDiveCard(
                "The quickest way to my heart is...",
                 "Through a shared love of travel and culture. If you can recommend a hidden gem in any city or share a story from your travels, we’re off to a great start.",
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  "Report or Block Profile",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 80), // spacing for nav bar
            ],
          ),
        ),
      ),

      /// ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Liked you"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "People"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  /// ---------- REUSABLES ----------

  Widget _button(String text, bool filled) {
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
              onPressed: () {},
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
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  static Widget _image(String path, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(path, height: height, fit: BoxFit.cover),
    );
  }

  static Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(text),
    );
  }

  static Widget _topChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(text, style: const TextStyle(color: Colors.pink)),
    );
  }

  static Widget _musicCard(String title, String artist) {
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
                Text(artist, style: const TextStyle(color: Colors.grey))
              ])),
          const Icon(Icons.graphic_eq, color: Colors.pink)
        ],
      ),
    );
  }

  static Widget _essentialItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
              ])
        ],
      ),
    );
  }

  static Widget _divider() => Divider(color: Colors.grey.shade200);

  static Widget _deepDiveCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("“ $title",
              style: const TextStyle(
                  color: Colors.pink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}