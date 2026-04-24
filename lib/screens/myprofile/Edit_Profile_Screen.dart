import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  // List of uploaded images - now stores actual file paths
  final List<dynamic> _uploadedImages = [
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
  ];

  // List of interests
  final List<String> _interests = [
    "Music",
    "Fitness",
    "Travel",
    "Art",
    "Cooking",
  ];

  // Available interests to add
  final List<String> _availableInterests = [
    "Reading",
    "Gaming",
    "Photography",
    "Dancing",
    "Cooking",
    "Travel",
    "Music",
    "Fitness",
    "Art",
    "Movies",
    "Shopping",
    "Yoga",
  ];

  // Method to pick image from gallery/camera
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.pink),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await _addImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.pink),
              title: const Text("Take a Photo"),
              onTap: () async {
                Navigator.pop(context);
                await _addImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          // Store the actual image file path
          _uploadedImages.add(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Photo added successfully!"),
              backgroundColor: Colors.pink,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding photo: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to delete image
  void _deleteImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Photo removed"),
        backgroundColor: Colors.pink,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Method to add interest
  void _addInterest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Interest",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: _availableInterests.length,
                itemBuilder: (context, index) {
                  final interest = _availableInterests[index];
                  final isSelected = _interests.contains(interest);
                  return GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        setState(() {
                          _interests.add(interest);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$interest added!"),
                            backgroundColor: Colors.pink,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.pink : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? Colors.pink.shade50 : Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.pink : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to remove interest
  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$interest removed"),
        backgroundColor: Colors.pink,
        duration: const Duration(seconds: 1),
      ),
    );
  }

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

                      /// GRID (FIXED HEIGHT) - DYNAMIC
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          // Uploaded images
                          ...List.generate(_uploadedImages.length, (index) {
                            return _imageCard(_uploadedImages[index], index);
                          }),
                          // Add button
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, size: 30, color: Colors.pink),
                              ),
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
                        /// INTERESTS - DYNAMIC
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
                            ...List.generate(_interests.length, (index) {
                              return _chip(_interests[index], () => _removeInterest(_interests[index]));
                            }),
                            _addChip(() => _addInterest()),
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

  /// IMAGE CARD - WITH DELETE FUNCTIONALITY
  Widget _imageCard(dynamic imagePath, int index) {
    // Check if it's an asset or a file path
    final bool isAsset = imagePath.toString().startsWith('assets/');
    
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: isAsset
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if file doesn't exist
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
        ),

        /// CLOSE BUTTON - FUNCTIONAL
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => _deleteImage(index),
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
        ),
      ],
    );
  }

  /// PINK CHIP - WITH REMOVE FUNCTIONALITY
  Widget _chip(String text, VoidCallback onRemove) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
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
      ),
    );
  }

  /// ADD CHIP - WITH ONTAP
  Widget _addChip(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
