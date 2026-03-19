import 'package:flutter/material.dart';
import 'package:dating_app/screens/auth/otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {

  final bool isLogin; // true = existing user, false = new user

  const PhoneNumberScreen({
    super.key,
    required this.isLogin,
  });

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {

  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendCode() {
  String phone = phoneController.text.trim();

  if (phone.isEmpty || phone.length < 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter valid phone number")),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OTPScreen(
        phoneNumber: phone,
        isLogin: widget.isLogin,
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
                const SizedBox(height: 10),

                /// Top Bar
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
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Phone number",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 40),

                /// Main Title
                const Text(
                  "Enter your phone\nnumber",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "We'll send you a verification code to your phone.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                /// Labels
                const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Country",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Phone Number",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Input Fields
                Row(
                  children: [
                    /// Country Code
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("+91"),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Phone Input
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "9876543210",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// Use Email Instead
                Center(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.mail_outline,
                      color: Colors.purple,
                      size: 18,
                    ),
                    label: const Text(
                      "Use email instead",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ),

                const Spacer(),

                /// Terms Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.check_circle,
                        color: Colors.purple, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'By clicking "Send Code", you agree to our Terms of '
                        'Service and Privacy Policy. Standard messaging '
                        'rates may apply.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Send Code Button
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
                    onPressed: sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Send Code",
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