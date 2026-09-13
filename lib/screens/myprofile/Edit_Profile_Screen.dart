import 'dart:io';

import 'package:dating_app/controllers/user_controller.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final UserController _userController = Get.find<UserController>();

  final List<String> _uploadedImages = [];
  final List<String> _interests = [];
  final List<String> _courses = [];
  final List<String> _qualities = [];
  final List<String> _languages = [];
  final List<String> _openingMoves = [];

  final List<String> _availableInterests = const [
    'Reading',
    'Gaming',
    'Photography',
    'Dancing',
    'Cooking',
    'Travel',
    'Music',
    'Fitness',
    'Art',
    'Movies',
    'Shopping',
    'Yoga',
  ];
  final List<String> _availableCourses = const [
    'Feminism',
    'Human rights',
    'Climate change',
    'Mental health',
    'Education',
    'Animal rights',
    'LGBTQ+',
    'Sustainability',
    'Social justice',
  ];
  final List<String> _availableQualities = const [
    'Empathy',
    'Optimism',
    'Emotional intelligence',
    'Honesty',
    'Humor',
    'Loyalty',
    'Kindness',
    'Ambition',
    'Creativity',
    'Patience',
  ];
  final List<String> _availableLanguages = const [
    'English',
    'Hindi',
    'Marathi',
    'Spanish',
    'French',
    'German',
    'Tamil',
    'Telugu',
    'Bengali',
  ];

  late final TextEditingController _bioController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _hometownController;
  late final TextEditingController _workController;
  late final TextEditingController _educationController;

  String _gender = 'other';
  String _height = '';
  String _exercise = '';
  String _starSign = '';
  String _educationLevel = '';
  String _drinking = '';
  String _smoking = '';
  String _lookingFor = '';
  String _kids = '';
  String _haveKids = '';
  String _religion = '';
  String _politics = '';
  String _pronouns = '';
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = _userController.currentUser.value;
    _bioController = TextEditingController(text: user?.bio ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _hometownController = TextEditingController(text: user?.hometown ?? '');
    _workController = TextEditingController(text: user?.work ?? '');
    _educationController = TextEditingController(text: user?.education ?? '');

    if (user != null) {
      _gender = user.gender.name;
      _height = user.height ?? '';
      _exercise = user.exercise ?? '';
      _starSign = user.starSign ?? '';
      _educationLevel = user.educationLevel ?? '';
      _drinking = user.drinking ?? '';
      _smoking = user.smoking ?? '';
      _lookingFor = user.lookingFor ?? '';
      _kids = user.kids ?? '';
      _haveKids = user.haveKids ?? '';
      _religion = user.religion ?? '';
      _politics = user.politics ?? '';
      _pronouns = user.pronouns ?? '';
      _interests.addAll(user.interests);
      _courses.addAll(user.courses);
      _qualities.addAll(user.qualities);
      _languages.addAll(user.languages);
      _openingMoves.addAll(user.openingMoves);
      _uploadedImages.addAll(user.photoUrls);
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _hometownController.dispose();
    _workController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  int get _strength {
    final draft = UserModel(
      id: _userController.currentUser.value?.id ?? '',
      email: _userController.currentUser.value?.email ?? '',
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dateOfBirth:
          _userController.currentUser.value?.dateOfBirth ?? DateTime(2000),
      gender: Gender.values.firstWhere(
        (g) => g.name == _gender,
        orElse: () => Gender.other,
      ),
      photoUrls: _uploadedImages,
      bio: _bioController.text,
      interests: _interests,
      latitude: 0,
      longitude: 0,
      city: _cityController.text,
      work: _workController.text,
      education: _educationController.text,
      lookingFor: _lookingFor,
      height: _height,
      languages: _languages,
      qualities: _qualities,
      relationshipStatus: RelationshipStatus.single,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
    return draft.profileCompleteness;
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final updateData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'gender': _gender,
      'bio': _bioController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'hometown': _hometownController.text.trim(),
      'work': _workController.text.trim(),
      'education': _educationController.text.trim(),
      'educationLevel': _educationLevel,
      'height': _height,
      'exercise': _exercise,
      'starSign': _starSign,
      'drinking': _drinking,
      'smoking': _smoking,
      'lookingFor': _lookingFor,
      'kids': _kids,
      'haveKids': _haveKids,
      'religion': _religion,
      'politics': _politics,
      'pronouns': _pronouns,
      'interests': _interests,
      'courses': _courses,
      'qualities': _qualities,
      'languages': _languages,
      'openingMoves': _openingMoves,
      if (_uploadedImages.any((p) => p.startsWith('http')))
        'photoUrls': _uploadedImages.where((p) => p.startsWith('http')).toList(),
    };

    final success = await _userController.updateMyProfile(updateData);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated successfully!'
                : (_userController.errorMessage.value.isNotEmpty
                    ? _userController.errorMessage.value
                    : 'Failed to update profile.'),
          ),
          backgroundColor: success ? AppTheme.primaryColor : Colors.red,
        ),
      );
      if (success) Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _addImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Take a Photo'),
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
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _isUploadingPhoto = true);
      final success = await _userController.uploadProfilePhoto(image.path);
      if (success) {
        final photos = _userController.currentUser.value?.photoUrls ?? [];
        setState(() {
          _uploadedImages
            ..clear()
            ..addAll(photos);
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _userController.errorMessage.value.isNotEmpty
                  ? _userController.errorMessage.value
                  : 'Failed to upload photo',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding photo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _deleteImage(int index) async {
    final path = _uploadedImages[index];
    if (path.startsWith('http')) {
      final success = await _userController.deleteProfilePhoto(path);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _userController.errorMessage.value.isNotEmpty
                  ? _userController.errorMessage.value
                  : 'Failed to delete photo',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await _userController.refreshProfile();
      final photos = _userController.currentUser.value?.photoUrls ?? [];
      setState(() {
        _uploadedImages
          ..clear()
          ..addAll(photos);
      });
    } else {
      setState(() => _uploadedImages.removeAt(index));
    }
  }

  Future<void> _editTextField({
    required String title,
    required TextEditingController controller,
  }) async {
    final draft = TextEditingController(text: controller.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: draft,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true) {
      setState(() => controller.text = draft.text.trim());
    }
    draft.dispose();
  }

  Future<void> _pickOption({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                trailing: option == current
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => onSelected(selected));
  }

  Future<void> _multiSelect({
    required String title,
    required List<String> available,
    required List<String> selected,
    int? maxItems,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final temp = List<String>.from(selected);
        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selected
                                ..clear()
                                ..addAll(temp);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.4,
                      ),
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final item = available[index];
                        final isSelected = temp.contains(item);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                temp.remove(item);
                              } else if (maxItems == null || temp.length < maxItems) {
                                temp.add(item);
                              }
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                              ),
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.08)
                                  : Colors.white,
                            ),
                            child: Text(
                              item,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? AppTheme.primaryColor : Colors.black,
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
          ),
        );
      },
    );
  }

  Future<void> _editOpeningMove(int? index) async {
    final draft = TextEditingController(
      text: index == null ? '' : _openingMoves[index],
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add opening move' : 'Edit opening move'),
        content: TextField(
          controller: draft,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Write a conversation starter...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved == true) {
      final text = draft.text.trim();
      if (text.isEmpty) return;
      setState(() {
        if (index == null) {
          if (_openingMoves.length < 3) _openingMoves.add(text);
        } else {
          _openingMoves[index] = text;
        }
      });
    }
    draft.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _userController.currentUser.value;
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
                            'Edit Profile',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 12),
                      const Text('Profile strength'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _strength / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('$_strength% complete'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Photos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add photos that show the real you.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      if (_isUploadingPhoto)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(color: AppTheme.primaryColor),
                        ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          ...List.generate(
                            _uploadedImages.length,
                            (index) => _imageCard(_uploadedImages[index], index),
                          ),
                          if (_uploadedImages.length < 6)
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, size: 30, color: AppTheme.primaryColor),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified, color: AppTheme.primaryColor),
                                SizedBox(width: 10),
                                Text('Verification'),
                              ],
                            ),
                            Text(
                              (user?.isVerified ?? false) ? 'ID Verified' : 'Not ID Verified',
                              style: const TextStyle(color: Colors.grey),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Basic info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _aboutTile(
                          Icons.person,
                          'First name',
                          _firstNameController.text.isEmpty ? 'Add' : _firstNameController.text,
                          () => _editTextField(title: 'First name', controller: _firstNameController),
                        ),
                        _aboutTile(
                          Icons.person_outline,
                          'Last name',
                          _lastNameController.text.isEmpty ? 'Add' : _lastNameController.text,
                          () => _editTextField(title: 'Last name', controller: _lastNameController),
                        ),
                        _aboutTile(
                          Icons.wc,
                          'Gender',
                          _gender.isEmpty ? 'Add' : _gender,
                          () => _pickOption(
                            title: 'Gender',
                            options: const ['male', 'female', 'other'],
                            current: _gender,
                            onSelected: (v) => _gender = v,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ..._interests.map(
                              (item) => _chip(item, () => setState(() => _interests.remove(item))),
                            ),
                            _addChip(
                              () => _multiSelect(
                                title: 'Interests',
                                available: _availableInterests,
                                selected: _interests,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _dynamicSectionCard(
                          title: 'My courses and communities',
                          subtitle: 'Add up to 3 causes close to your heart',
                          items: _courses,
                          onAdd: () => _multiSelect(
                            title: 'Courses & communities',
                            available: _availableCourses,
                            selected: _courses,
                            maxItems: 3,
                          ),
                          onRemove: (item) => setState(() => _courses.remove(item)),
                        ),
                        const SizedBox(height: 20),
                        _dynamicSectionCard(
                          title: 'Qualities I value',
                          subtitle: 'Choose up to 3 qualities',
                          items: _qualities,
                          onAdd: () => _multiSelect(
                            title: 'Qualities',
                            available: _availableQualities,
                            selected: _qualities,
                            maxItems: 3,
                          ),
                          onRemove: (item) => setState(() => _qualities.remove(item)),
                        ),
                        const SizedBox(height: 20),
                        const Text('Opening Moves', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text(
                          'Add up to 3 messages new matches can reply to.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_openingMoves.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () => _editOpeningMove(index),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(_openingMoves[index])),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => setState(() => _openingMoves.removeAt(index)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_openingMoves.length < 3)
                          TextButton.icon(
                            onPressed: () => _editOpeningMove(null),
                            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
                            label: const Text('Add opening move', style: TextStyle(color: AppTheme.primaryColor)),
                          ),
                        const SizedBox(height: 16),
                        const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            onChanged: (_) => setState(() {}),
                            decoration: AppTheme.borderlessInputDecoration(
                              hintText: 'Write something about yourself...',
                              contentPadding: EdgeInsets.zero,
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('About you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _aboutTile(
                          Icons.cake,
                          'Age',
                          user == null ? '—' : '${user.age}',
                          null,
                        ),
                        _aboutTile(
                          Icons.work,
                          'Work',
                          _workController.text.isEmpty ? 'Add' : _workController.text,
                          () => _editTextField(title: 'Work', controller: _workController),
                        ),
                        _aboutTile(
                          Icons.school,
                          'Education',
                          _educationController.text.isEmpty ? 'Add' : _educationController.text,
                          () => _editTextField(title: 'Education', controller: _educationController),
                        ),
                        _aboutTile(
                          Icons.location_on,
                          'City',
                          _cityController.text.isEmpty ? 'Add' : _cityController.text,
                          () => _editTextField(title: 'City', controller: _cityController),
                        ),
                        _aboutTile(
                          Icons.public,
                          'Country',
                          _countryController.text.isEmpty ? 'Add' : _countryController.text,
                          () => _editTextField(title: 'Country', controller: _countryController),
                        ),
                        _aboutTile(
                          Icons.home,
                          'Hometown',
                          _hometownController.text.isEmpty ? 'Add' : _hometownController.text,
                          () => _editTextField(title: 'Hometown', controller: _hometownController),
                        ),
                        const SizedBox(height: 24),
                        const Text('More about you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _aboutTile(
                          Icons.height,
                          'Height',
                          _height.isEmpty ? 'Add' : _height,
                          () => _pickOption(
                            title: 'Height',
                            options: const ["5'0\"", "5'2\"", "5'4\"", "5'5\"", "5'6\"", "5'8\"", "5'10\"", "6'0\"", "6'2\""],
                            current: _height,
                            onSelected: (v) => _height = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.fitness_center,
                          'Exercise',
                          _exercise.isEmpty ? 'Add' : _exercise,
                          () => _pickOption(
                            title: 'Exercise',
                            options: const ['Active', 'Sometimes', 'Almost never'],
                            current: _exercise,
                            onSelected: (v) => _exercise = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.auto_awesome,
                          'Star sign',
                          _starSign.isEmpty ? 'Add' : _starSign,
                          () => _pickOption(
                            title: 'Star sign',
                            options: const [
                              'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                              'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
                            ],
                            current: _starSign,
                            onSelected: (v) => _starSign = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.school_outlined,
                          'Educational level',
                          _educationLevel.isEmpty ? 'Add' : _educationLevel,
                          () => _pickOption(
                            title: 'Educational level',
                            options: const ['High school', 'UG degree', 'PG degree', 'PhD', 'Trade school'],
                            current: _educationLevel,
                            onSelected: (v) => _educationLevel = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.local_bar,
                          'Drinking',
                          _drinking.isEmpty ? 'Add' : _drinking,
                          () => _pickOption(
                            title: 'Drinking',
                            options: const ["No, I don't drink", 'Socially', 'Frequently'],
                            current: _drinking,
                            onSelected: (v) => _drinking = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.smoking_rooms,
                          'Smoking',
                          _smoking.isEmpty ? 'Add' : _smoking,
                          () => _pickOption(
                            title: 'Smoking',
                            options: const ["No, I don't smoke", 'Socially', 'Regularly'],
                            current: _smoking,
                            onSelected: (v) => _smoking = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.favorite,
                          'Looking for',
                          _lookingFor.isEmpty ? 'Add' : _lookingFor,
                          () => _pickOption(
                            title: 'Looking for',
                            options: const [
                              'A long-term relationship',
                              'Something casual',
                              'New friends',
                              'Not sure yet',
                            ],
                            current: _lookingFor,
                            onSelected: (v) => _lookingFor = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.child_care,
                          'Kids',
                          _kids.isEmpty ? 'Add' : _kids,
                          () => _pickOption(
                            title: 'Kids',
                            options: const ['Want kids', "Don't want kids", 'Not sure', 'Open to kids'],
                            current: _kids,
                            onSelected: (v) => _kids = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.child_friendly,
                          'Have kids',
                          _haveKids.isEmpty ? 'Add' : _haveKids,
                          () => _pickOption(
                            title: 'Have kids',
                            options: const ["Don't have kids", 'Have kids', 'Prefer not to say'],
                            current: _haveKids,
                            onSelected: (v) => _haveKids = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.temple_hindu,
                          'Religion',
                          _religion.isEmpty ? 'Add' : _religion,
                          () => _pickOption(
                            title: 'Religion',
                            options: const ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Buddhist', 'Atheist', 'Spiritual', 'Other'],
                            current: _religion,
                            onSelected: (v) => _religion = v,
                          ),
                        ),
                        _aboutTile(
                          Icons.gavel,
                          'Politics',
                          _politics.isEmpty ? 'Add' : _politics,
                          () => _pickOption(
                            title: 'Politics',
                            options: const ['Apolitical', 'Liberal', 'Moderate', 'Conservative'],
                            current: _politics,
                            onSelected: (v) => _politics = v,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Pronouns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _aboutTile(
                          Icons.chat_bubble_outline,
                          'Pronouns',
                          _pronouns.isEmpty ? 'Add' : _pronouns,
                          () => _pickOption(
                            title: 'Pronouns',
                            options: const ['she/her', 'he/him', 'they/them', 'she/they', 'he/they'],
                            current: _pronouns,
                            onSelected: (v) => _pronouns = v,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Languages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._languages.map(
                              (lang) => _chip(lang, () => setState(() => _languages.remove(lang))),
                            ),
                            _addChip(
                              () => _multiSelect(
                                title: 'Languages',
                                available: _availableLanguages,
                                selected: _languages,
                              ),
                            ),
                          ],
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
    );
  }

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
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              ...items.map((item) => _chip(item, () => onRemove(item))),
              _addChip(onAdd),
            ],
          ),
        ),
      ],
    );
  }

  Widget _brokenImagePlaceholder() => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );

  Widget _imageForPath(String path) {
    Widget errorFallback(BuildContext context, Object error, StackTrace? stack) =>
        _brokenImagePlaceholder();

    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: errorFallback);
    }
    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: errorFallback);
    }
    return Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: errorFallback);
  }

  Widget _imageCard(String imagePath, int index) {
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
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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
            Text('Add', style: TextStyle(color: AppTheme.primaryColor)),
            SizedBox(width: 6),
            Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _aboutTile(IconData icon, String title, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
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
                    Text(
                      value,
                      style: TextStyle(
                        color: value == 'Add' ? AppTheme.primaryColor : Colors.grey,
                        fontWeight: value == 'Add' ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade200),
        ],
      ),
    );
  }
}
