import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'upload_photo_screen.dart';

class ProfileTextScreen extends StatefulWidget {
  const ProfileTextScreen({super.key});

  @override
  State<ProfileTextScreen> createState() => _ProfileTextScreenState();
}

class _ProfileTextScreenState extends State<ProfileTextScreen> {
  final TextEditingController profileController = TextEditingController();
  final RegistrationController registrationController = Get.find<RegistrationController>();
  int charCount = 0;

  @override
  void initState() {
    super.initState();
    profileController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      charCount = profileController.text.length;
    });
  }

  @override
  void dispose() {
    profileController.removeListener(_updateCharCount);
    profileController.dispose();
    super.dispose();
  }

  void continueNext() {
    String profileText = profileController.text.trim();
    if (profileText.isEmpty) {
      profileText = "Hi, I am using DatingApp."; // Default profile text
    }

    // Store profile text in controller
    registrationController.setProfile(profileText);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UploadPhotoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E7FF),
              Color(0xFFFFE3EC),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "STEP 7 OF 8",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: 7 / 8,
                          backgroundColor: Colors.purple.shade100,
                          color: Colors.purple,
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          "Tell us about yourself",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Write a short bio to introduce yourself",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Container(
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: profileController,
                            maxLines: 4,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              hintText: "Write something about yourself...",
                              border: InputBorder.none,
                              counterText: "",
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "$charCount/200",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 40),

                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF4E8A),
                                Color(0xFF9B51E0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: continueNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}