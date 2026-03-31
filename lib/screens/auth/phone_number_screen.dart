import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/screens/auth/otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  final bool isLogin;

  const PhoneNumberScreen({
    super.key,
    required this.isLogin,
  });

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController phoneController = TextEditingController();

  String countryCode = "+91";

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendCode() {
    String phone = phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 10 digit number")),
      );
      return;
    }

    String fullPhone = "$countryCode$phone";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          phoneNumber: fullPhone,
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
                const SizedBox(height: 40),

                const Text(
                  "Enter your phone number",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                /// Labels
                const Row(
                  children: [
                    Expanded(child: Text("Country")),
                    Expanded(flex: 1, child: Text("Phone Number")),
                  ],
                ),

                const SizedBox(height: 10),

                /// ✅ INPUT ROW (FIXED)
                Row(
                  children: [
                    /// 🌍 COUNTRY CODE
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
                            /// COUNTRY PICKER
                            Expanded(
                              child: CountryCodePicker(
                                onChanged: (code) {
                                  setState(() {
                                    countryCode = code.dialCode!;
                                  });
                                },
                                initialSelection: 'IN',

                                showFlag: false,
                                showCountryOnly: false,
                                showOnlyCountryWhenClosed: false,

                                alignLeft: true,

                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),

                                padding: EdgeInsets.zero,
                              ),
                            ),

                            /// DROPDOWN ICON
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// 📱 PHONE FIELD
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 55,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,

                          textAlignVertical: TextAlignVertical.center,

                          decoration: const InputDecoration(
                            isCollapsed: true,
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

                const Spacer(),

                /// 🚀 BUTTON
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