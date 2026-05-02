import 'package:flutter/material.dart';
import 'dart:io';
import 'location_screen.dart';
import 'package:get/get.dart';
import 'package:dating_app/controllers/registration_controller.dart';

class FinalStepScreen extends StatefulWidget {
  final File? image;

  const FinalStepScreen({super.key, this.image});

  @override
  State<FinalStepScreen> createState() => _FinalStepScreenState();
}

class _FinalStepScreenState extends State<FinalStepScreen> {
  final RegistrationController registrationController = Get.find<RegistrationController>();
  bool isLoading = false;

  void _startExploring() async {
    setState(() => isLoading = true);

    final response = await registrationController.registerUser();

    setState(() => isLoading = false);

    if (response.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LocationScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error ?? response.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E7FF), Color(0xFFFFE3EC)],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: Column(
              children: [
                const SizedBox(height: 80),

                /// Profile Image
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: ClipOval(
                    child: widget.image != null
                        ? Image.file(widget.image!, fit: BoxFit.cover)
                        : Image.network(
                            "https://i.pravatar.cc/300",
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                /// Title
                const Text(
                  "Looks Good!",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                /// Subtitle
                const Text(
                  "Your profile has been created.\nStart exploring now!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const Spacer(),

                /// Start Exploring Button
                Container(
                  width: double.infinity,
                  height: 55,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4E8A), Color(0xFF9B51E0)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: ElevatedButton(
                    onPressed: isLoading ? null : _startExploring,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),

                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Start Exploring  >",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
