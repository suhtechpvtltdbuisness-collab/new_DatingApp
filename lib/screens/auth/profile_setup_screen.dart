import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'package:dating_app/utils/theme.dart';
import 'birthday_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final RegistrationController registrationController =
      Get.find<RegistrationController>();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void continueNext() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your name")));
      return;
    }

    // Store name in controller
    registrationController.setName(nameController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BirthdayScreen()),
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
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
          ),
        ),
        child: SafeArea(
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
                  "STEP 3 OF 8",
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: 3 / 8,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.15),
                  color: AppTheme.accentColor,
                ),

                const SizedBox(height: 40),

                const Text(
                  "What's your name?",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.accentColor),
                  ),
                  // Center wraps the collapsed field so it sits exactly
                  // mid-pill instead of hugging the bottom.
                  child: Center(
                    child: TextField(
                      controller: nameController,
                      cursorColor: AppTheme.accentColor,
                      // Names go on the profile, so capitalise each word and
                      // let the keyboard offer the device's saved name.
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.name],
                      onSubmitted: (_) => continueNext(),
                      decoration: AppTheme.borderlessInputDecoration(
                        hintText: "e.g. Priya Sharma",
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "This is how you'll appear on your profile.\nYou can't change it later.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const Spacer(),

                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3D77), Color(0xFF8B5CF6)],
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
      ),
    );
  }
}
