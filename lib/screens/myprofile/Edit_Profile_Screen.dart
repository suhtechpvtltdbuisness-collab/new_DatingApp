import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E7FF), Color(0xFFFFE3EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= TOP SECTION =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP BAR
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "My Profile",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// PROFILE STRENGTH
                      const Text("Profile strength"),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("77% complete"),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// PHOTOS TITLE
                      const Text(
                        "Photos and videos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "Pick some that show the true you.",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      /// GRID (FIXED HEIGHT)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _imageCard("assets/images/editprofilegirl1.png"),
                          _imageCard("assets/images/editprofilegirl1.png"),
                          _imageCard("assets/images/editprofilegirl1.png"),
                          _imageCard("assets/images/editprofilegirl1.png"),
                          _imageCard("assets/images/editprofilegirl1.png"),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, size: 30),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Hold & drag to re-order",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 15),

                      /// VERIFICATION
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.verified, color: Colors.pink),
                                SizedBox(width: 10),
                                Text("Verification"),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Not ID Verified",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                /// ================= WHITE SECTION =================
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// INTERESTS
                        const Text(
                          "Interests",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Get specific about the things you love",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _chip("Music"),
                            _chip("Fitness"),
                            _chip("Travel"),
                            _chip("Art"),
                            _chip("Cooking"),
                            _addChip(),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _sectionCard(
                          title: "My courses and communities",
                          subtitle: "Add upto 3 causes close to your heart",
                          children: [
                            _greyChip("Feminism"),
                            _greyChip("Human rights"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _sectionCard(
                          title: "Qualities I value",
                          subtitle:
                              "Choose up to 3 qualities you value in a person",
                          children: [
                            _greyChip("Empathy"),
                            _greyChip("Optimism"),
                            _greyChip("Emotional intelligence"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Opening Moves",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Add first 3 messages your new matches can reply to.",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "What’s the best piece of advice you’ve ever received?",
                                ),
                              ),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Bio",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const SizedBox(height: 10),

                        /// BIO INPUT
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "I spend my time creating things & planning a life bigger than comfort zones.",
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// ================= ABOUT YOU =================
                        const Text(
                          "About you",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _aboutTile(Icons.cake, "Age", "25"),
                        _aboutTile(Icons.work, "Work", "Product Designer"),
                        _aboutTile(
                          Icons.school,
                          "Education",
                          "DY Patil University",
                        ),
                        _aboutTile(Icons.female, "Gender", "Woman"),
                        _aboutTile(Icons.location_on, "Location", "Pune"),
                        _aboutTile(Icons.home, "Hometown", "Nagpur"),

                        const SizedBox(height: 25),

                        /// ================= MORE ABOUT YOU =================
                        const Text(
                          "More about you",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Cover the things most people are curious about.",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 12),

                        _aboutTile(Icons.height, "Height", "5'5\""),
                        _aboutTile(Icons.fitness_center, "Exercise", "Active"),
                        _aboutTile(Icons.auto_awesome, "Star sign", "Taurus"),
                        _aboutTile(
                          Icons.school_outlined,
                          "Educational level",
                          "UG degree",
                        ),
                        _aboutTile(
                          Icons.local_bar,
                          "Drinking",
                          "No, I don’t drink",
                        ),
                        _aboutTile(
                          Icons.smoking_rooms,
                          "Smoking",
                          "No, I don’t smoke",
                        ),
                        _aboutTile(
                          Icons.favorite,
                          "Looking for",
                          "A long-term relationship",
                        ),
                        _aboutTile(Icons.child_care, "Kids", "Not sure"),
                        _aboutTile(
                          Icons.child_friendly,
                          "Have Kids",
                          "Don’t have kids",
                        ),
                        _aboutTile(Icons.temple_hindu, "Religion", "Hindu"),
                        _aboutTile(Icons.gavel, "Politics", "Apolitical"),

                        const SizedBox(height: 25),

                        /// ================= PRONOUNS =================
                        const Text(
                          "Pronouns",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Pick your pronouns",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("she/her"),
                              Icon(Icons.chevron_right),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// ================= LANGUAGES =================
                        const Text(
                          "Languages",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _langChip("English"),
                              const SizedBox(width: 8),
                              _langChip("Hindi"),
                              const SizedBox(width: 8),
                              _langChip("Marathi"),
                              const Spacer(),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: 3, // Profile selected
  selectedItemColor: Colors.pink,
  unselectedItemColor: Colors.black54,
  type: BottomNavigationBarType.fixed,
  onTap: (index) {
    // handle navigation here
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_border),
      label: "Liked you",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: "People",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      label: "Chat",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: "Profile",
    ),
  ],
),
      
    );
  }

  /// IMAGE CARD
  Widget _imageCard(String path) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        /// CLOSE BUTTON
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// PINK CHIP
  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(color: Colors.pink)),
          const SizedBox(width: 6),
          const Icon(Icons.close, size: 14, color: Colors.pink),
        ],
      ),
    );
  }

  /// ADD CHIP
  Widget _addChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Add more", style: TextStyle(color: Colors.pink)),
          SizedBox(width: 6),
          Icon(Icons.add, size: 16, color: Colors.pink),
        ],
      ),
    );
  }

  /// GREY CHIP
  Widget _greyChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  /// SECTION CARD
  Widget _sectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Wrap(spacing: 10, runSpacing: 10, children: children),
        ),
      ],
    );
  }

  /// ABOUT TILE (Reusable row)
  Widget _aboutTile(IconData icon, String title, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.pink),
                  const SizedBox(width: 12),
                  Text(title),
                ],
              ),
              Row(
                children: [
                  Text(value, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade200),
      ],
    );
  }

  /// LANGUAGE CHIP
  Widget _langChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text),
    );
  }
}
