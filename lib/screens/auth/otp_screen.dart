import 'package:flutter/material.dart';
import 'profile_setup_screen.dart';
import 'location_screen.dart';

class OTPScreen extends StatefulWidget {

  final String phoneNumber;
  final bool isLogin;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.isLogin,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

  final List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  void verifyOtp() {

  if (getOtp().length != 4) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter 4 digit OTP")),
    );
    return;
  }

  if (widget.isLogin) {

    // Existing user → Location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationScreen(),
      ),
    );

  } else {

    // New user → Profile setup
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(),
      ),
    );
  }
}

  void onChanged(String value, int index) {

    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }
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
            colors: [
              Color(0xFFF3E7FF),
              Color(0xFFFFE3EC),
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

                /// Back Button
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

                const SizedBox(height: 30),

                /// Title
                const Text(
                  "Verify your number",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                /// Subtitle
                Text(
                  "Enter the 4-digit code sent to +91 ${widget.phoneNumber}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                /// OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 65,
                      height: 65,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.purple, width: 1.5),
                        color: Colors.white.withOpacity(0.5),
                      ),

                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],

                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),

                        decoration: const InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                        ),

                        onChanged: (value) => onChanged(value, index),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                /// Verify Button
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
                    onPressed: verifyOtp,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),

                    child: const Text(
                      "Verify & Proceed",
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