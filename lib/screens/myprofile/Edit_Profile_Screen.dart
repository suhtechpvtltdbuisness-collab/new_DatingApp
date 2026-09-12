import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/utils/theme.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<dynamic> _uploadedImages = [
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
    "assets/images/editprofilegirl1.png",
  ];

  final List<String> _interests = [
    "Music",
    "Fitness",
    "Travel",
    "Art",
    "Cooking",
  ];

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

  // ── Courses & Communities ──
  final List<String> _courses = ["Feminism", "Human rights"];
  final List<String> _availableCourses = [
    "Feminism",
    "Human rights",
    "Climate change",
    "Mental health",
    "Education",
    "Animal rights",
    "LGBTQ+",
    "Sustainability",
    "Social justice",
  ];

  // ── Qualities ──
  final List<String> _qualities = [
    "Empathy",
    "Optimism",
    "Emotional intelligence",
  ];
  final List<String> _availableQualities = [
    "Empathy",
    "Optimism",
    "Emotional intelligence",
    "Honesty",
    "Humor",
    "Loyalty",
    "Kindness",
    "Ambition",
    "Creativity",
    "Patience",
  ];
  // ── Controllers for editable fields ──
  late final TextEditingController _bioController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _cityController;
  bool _isSaving = false;

  final UserController _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    final user = _userController.currentUser.value;

    _bioController = TextEditingController(text: user?.bio ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');

    // Pre-fill interests from API data if available
    if (user != null && user.interests.isNotEmpty) {
      _interests
        ..clear()
        ..addAll(user.interests);
    }

    // Pre-fill photos from API data if available
    if (user != null && user.photoUrls.isNotEmpty) {
      _uploadedImages
        ..clear()
        ..addAll(user.photoUrls);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── Save profile to backend ──
  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final updateData = <String, dynamic>{
      'bio': _bioController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'city': _cityController.text.trim(),
      'interests': _interests,
    };

    final success = await _userController.updateMyProfile(updateData);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated successfully!'
                : 'Failed to update profile.',
          ),
          backgroundColor: success ? AppTheme.primaryColor : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await _addImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
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
          _uploadedImages.add(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Photo added successfully!"),
              backgroundColor: AppTheme.primaryColor,
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

  void _deleteImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Photo removed"),
        backgroundColor: AppTheme.primaryColor,
        duration: Duration(seconds: 1),
      ),
    );
  }

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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            backgroundColor: AppTheme.primaryColor,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$interest removed"),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ── Add Course ──
  void _addCourse() {
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
              "Add Course or Community",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                itemCount: _availableCourses.length,
                itemBuilder: (context, index) {
                  final item = _availableCourses[index];
                  final isSelected = _courses.contains(item);
                  final maxReached = _courses.length >= 3;
                  return GestureDetector(
                    onTap: () {
                      if (!isSelected && !maxReached) {
                        setState(() {
                          _courses.add(item);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$item added!"),
                            backgroundColor: AppTheme.primaryColor,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } else if (maxReached && !isSelected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Max 3 causes allowed"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? AppTheme.primaryColor : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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

  void _removeCourse(String item) {
    setState(() {
      _courses.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$item removed"),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ── Add Quality ──
  void _addQuality() {
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
              "Add Quality",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                itemCount: _availableQualities.length,
                itemBuilder: (context, index) {
                  final item = _availableQualities[index];
                  final isSelected = _qualities.contains(item);
                  final maxReached = _qualities.length >= 3;
                  return GestureDetector(
                    onTap: () {
                      if (!isSelected && !maxReached) {
                        setState(() {
                          _qualities.add(item);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$item added!"),
                            backgroundColor: AppTheme.primaryColor,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      } else if (maxReached && !isSelected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Max 3 qualities allowed"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? AppTheme.primaryColor : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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

  void _removeQuality(String item) {
    setState(() {
      _qualities.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$item removed"),
        backgroundColor: AppTheme.primaryColor,
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
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          const Spacer(),
                          _isSaving
                              ? const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: _saveProfile,
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 20),

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

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          ...List.generate(_uploadedImages.length, (index) {
                            return _imageCard(_uploadedImages[index], index);
                          }),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: AppTheme.primaryColor,
                                ),
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
                                Icon(Icons.verified, color: AppTheme.primaryColor),
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
                              return _chip(
                                _interests[index],
                                () => _removeInterest(_interests[index]),
                              );
                            }),
                            _addChip(() => _addInterest()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Courses & Communities — now dynamic ──
                        _dynamicSectionCard(
                          title: "My courses and communities",
                          subtitle: "Add upto 3 causes close to your heart",
                          items: _courses,
                          onAdd: _addCourse,
                          onRemove: _removeCourse,
                        ),

                        const SizedBox(height: 20),

                        // ── Qualities — now dynamic ──
                        _dynamicSectionCard(
                          title: "Qualities I value",
                          subtitle:
                              "Choose up to 3 qualities you value in a person",
                          items: _qualities,
                          onAdd: _addQuality,
                          onRemove: _removeQuality,
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
                                  "What's the best piece of advice you've ever received?",
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

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _bioController,
                            maxLines: 4,
                            maxLength: 300,
                            textAlignVertical: TextAlignVertical.top,
                            cursorColor: AppTheme.primaryColor,
                            decoration: AppTheme.borderlessInputDecoration(
                              hintText: 'Write something about yourself...',
                              contentPadding: EdgeInsets.zero,
                              counterText: '',
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

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
                          "No, I don't drink",
                        ),
                        _aboutTile(
                          Icons.smoking_rooms,
                          "Smoking",
                          "No, I don't smoke",
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
                          "Don't have kids",
                        ),
                        _aboutTile(Icons.temple_hindu, "Religion", "Hindu"),
                        _aboutTile(Icons.gavel, "Politics", "Apolitical"),

                        const SizedBox(height: 25),

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
        currentIndex: 3,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Liked you",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "People"),
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

  /// Dynamic section card with add + remove chip support
  Widget _dynamicSectionCard({
    required String title,
    required String subtitle,
    required List<String> items,
    required VoidCallback onAdd,
    required void Function(String) onRemove,
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
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...items.map(
                (item) => _removableGreyChip(item, () => onRemove(item)),
              ),
              _addChip(onAdd),
            ],
          ),
        ),
      ],
    );
  }

  /// Grey chip with a remove (×) button
  Widget _removableGreyChip(String text, VoidCallback onRemove) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _brokenImagePlaceholder() => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );

  /// [_uploadedImages] mixes bundled asset paths, remote photo URLs from the
  /// API, and local paths from the image picker — and on web a picked path is
  /// a blob: URL that only Image.network can read (Image.file asserts there).
  /// Pick the right loader per source instead of assuming a local file.
  Widget _imageForPath(dynamic imagePath) {
    final path = imagePath.toString();

    Widget errorFallback(BuildContext context, Object error, StackTrace? stack) =>
        _brokenImagePlaceholder();

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: errorFallback,
      );
    }

    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: errorFallback,
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: errorFallback,
    );
  }

  Widget _imageCard(dynamic imagePath, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _imageForPath(imagePath),
        ),
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

  Widget _chip(String text, VoidCallback onRemove) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: const TextStyle(color: AppTheme.primaryColor)),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _addChip(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add more", style: TextStyle(color: AppTheme.primaryColor)),
            SizedBox(width: 6),
            Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

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
                  Icon(icon, color: AppTheme.primaryColor),
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
