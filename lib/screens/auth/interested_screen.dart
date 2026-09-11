import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'profile_text_screen.dart';
import 'package:dating_app/utils/theme.dart';

class InterestedScreen extends StatefulWidget {
  const InterestedScreen({super.key});

  @override
  State<InterestedScreen> createState() => _InterestedScreenState();
}

class _InterestedScreenState extends State<InterestedScreen> {

  String? selected;
  final RegistrationController registrationController = Get.find<RegistrationController>();

  void goNext() {
    if (selected == null) return;

    // Store interestedIn in controller
    registrationController.setInterestedIn(selected!.toLowerCase());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileTextScreen(),
      ),
    );
  }

  Widget option(String value, IconData icon) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => setState(() => selected = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.grey.shade300,
            width: 1.5,
          ),
          color: Colors.white.withOpacity(0.7),
        ),
        child: Row(
          children: [

            CircleAvatar(
              radius: 22,
              backgroundColor:
                  isSelected ? AppTheme.accentColor : Colors.grey.shade200,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),

            const SizedBox(width: 16),

            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: AppTheme.accentColor,
            )
          ],
        ),
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
              Color(0xFFFFD9EA),
              Color(0xFFE7D9FF),
            ],
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
                  "STEP 6 OF 8",
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: 6 / 8,
                  backgroundColor: AppTheme.accentColor.withOpacity(0.15),
                  color: AppTheme.accentColor,
                ),

                const SizedBox(height: 40),

                const Text(
                  "Who are you",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  "interested in?",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                option("Men", Icons.male),
                option("Women", Icons.female),
                option("Gay", Icons.group),
                option("Other", Icons.person),

                const Spacer(),

                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF3D77),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: goNext,
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