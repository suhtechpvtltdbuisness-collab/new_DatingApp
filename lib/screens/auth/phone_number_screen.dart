import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/screens/auth/otp_screen.dart';
// 👉 import your email signup screen
import 'package:dating_app/screens/auth/email_signup_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  final bool isLogin;

  const PhoneNumberScreen({super.key, required this.isLogin});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController phoneController = TextEditingController();

  String countryCode = "+91";
  bool isChecked = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendCode() async {
    String phone = phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 10 digit number")),
      );
      return;
    }

    String fullPhone = "$countryCode$phone";

    final dio = Dio();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await dio.get(
        "https://dating-backend-rust.vercel.app/users/otp/$fullPhone",
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTPScreen(phoneNumber: fullPhone, isLogin: widget.isLogin),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
      }
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                /// TITLE
                const Text(
                  "Enter your phone number",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                /// SUBTEXT
                Text(
                  "We’ll send you a verification code to your phone.",
                  style: TextStyle(color: Colors.black.withOpacity(0.5)),
                ),

                const SizedBox(height: 40),

                /// LABELS
                const Row(
                  children: [
                    Expanded(child: Text("Country")),
                    Expanded(child: Text("Phone Number")),
                  ],
                ),

                const SizedBox(height: 10),

                /// INPUT ROW
                Row(
                  children: [
                    /// COUNTRY CODE
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CountryCodePicker(
                                onChanged: (code) {
                                  setState(() {
                                    countryCode = code.dialCode!;
                                  });
                                },
                                initialSelection: 'IN',
                                showFlag: false,
                                alignLeft: true,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// PHONE FIELD
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "000-000-0000",
                          ),
                          style: const TextStyle(
                            fontSize: 17,
                            letterSpacing: 1.1,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// ✉️ USE EMAIL INSTEAD
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailSignupScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mail_outline,
                          color: Colors.purple,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Use email instead",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isChecked = !isChecked;
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.purple),
                          color: isChecked ? Colors.purple : Colors.transparent,
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "By clicking “Send Code”, you agree to our Terms of Service and Privacy Policy. Standard messaging rates may apply.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

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
                    onPressed: isChecked ? sendCode : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
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
