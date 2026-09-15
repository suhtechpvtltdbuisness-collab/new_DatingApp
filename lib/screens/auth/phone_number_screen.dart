import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/screens/auth/otp_screen.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
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

  bool _sending = false;

  Future<void> sendCode() async {
    if (_sending) return;
    String phone = phoneController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 10 digit number")),
      );
      return;
    }

    final e164 = '$countryCode$phone';
    setState(() => _sending = true);
    final response = await AuthService().sendPhoneOtp(e164);
    if (!mounted) return;
    setState(() => _sending = false);

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message.isNotEmpty
              ? response.message
              : "Couldn't send the code. Please try again."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          phoneNumber: e164,
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
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        /// BACK
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// TITLE
                        const Text(
                          "Enter your phone number",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// SUBTEXT
                        Text(
                          "We'll use this to keep your account secure.",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                          ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
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
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                    ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                // Center wraps the collapsed field so it sits
                                // exactly mid-pill instead of hugging the top.
                                child: Center(
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    cursorColor: AppTheme.accentColor,
                                    decoration:
                                        AppTheme.borderlessInputDecoration(
                                          hintText: "000-000-0000",
                                          isCollapsed: true,
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
                                  builder: (context) =>
                                      const EmailSignupScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline,
                                  color: AppTheme.accentColor,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Use email instead",
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 20
                              : 40,
                        ),

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
                                  border: Border.all(color: AppTheme.accentColor),
                                  color: isChecked
                                      ? AppTheme.accentColor
                                      : Colors.transparent,
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
                                'By clicking "Send Code", you agree to our Terms of Service and Privacy Policy. Standard messaging rates may apply.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        GradientButton(
                          label: "Send Code",
                          onPressed: isChecked && !_sending ? sendCode : null,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
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
