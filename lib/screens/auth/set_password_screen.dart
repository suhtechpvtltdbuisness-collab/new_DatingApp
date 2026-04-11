import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';
import 'profile_setup_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email;

  const SetPasswordScreen({super.key, required this.email});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final RegistrationController registrationController = Get.find<RegistrationController>();

  bool obscure1 = true;
  bool obscure2 = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set email in controller
    registrationController.setEmail(widget.email);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> continueOnboarding() async {
    String pass = passwordController.text.trim();
    String confirm = confirmController.text.trim();

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Store password in controller
    registrationController.setPassword(pass);

    // Navigate to name screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(),
      ),
    );
  }

  Widget inputField({
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
          GestureDetector(
            onTap: toggle,
            child: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// UI
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF3E7FF),
                  Color(0xFFFFE3EC),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Set Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text("Create a secure password"),

                    const SizedBox(height: 40),

                    const Text("Password"),
                    const SizedBox(height: 10),
                    inputField(
                      hint: "Enter password",
                      controller: passwordController,
                      obscure: obscure1,
                      toggle: () => setState(() => obscure1 = !obscure1),
                    ),

                    const SizedBox(height: 20),

                    const Text("Confirm Password"),
                    const SizedBox(height: 10),
                    inputField(
                      hint: "Confirm password",
                      controller: confirmController,
                      obscure: obscure2,
                      toggle: () => setState(() => obscure2 = !obscure2),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: continueOnboarding,
                        child: const Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔄 LOADER
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}