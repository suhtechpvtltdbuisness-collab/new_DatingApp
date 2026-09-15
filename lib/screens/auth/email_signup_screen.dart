import 'package:flutter/material.dart';
import 'package:dating_app/screens/auth/email_signin_screen.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'email_otp_screen.dart';

class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isChecked = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendEmailCode() async {
    String email = emailController.text.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid email")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authService.sendEmailOtp(email);

      if (response.success) {
        // ✅ NAVIGATE TO OTP SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EmailOtpScreen(email: email)),
        );
      } else {
        // GET /users/otp/email/:email currently fails server-side (HTTP 500)
        // for every address; explain instead of a bare "Server error".
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (response.statusCode ?? 0) >= 500
                  ? "We couldn't send a verification code right now. Please try again later."
                  : response.message,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔙 BACK
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
                      "Sign up",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Create your account using email",
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    ),

                    const SizedBox(height: 40),

                    /// EMAIL LABEL
                    const Text("Email"),

                    const SizedBox(height: 10),

                    /// EMAIL FIELD
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: AppTheme.accentColor,
                          decoration: AppTheme.borderlessInputDecoration(
                            hintText: "Enter your email",
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// TERMS
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
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryColor),
                              color:
                                  isChecked
                                      ? const Color(0xFFFF3D77)
                                      : Colors.transparent,
                            ),
                            child:
                                isChecked
                                    ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "I agree to Terms of Service and Privacy Policy.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// SEND CODE BUTTON
                    GradientButton(
                      label: "Send Code",
                      isLoading: isLoading,
                      onPressed: isChecked ? sendEmailCode : null,
                    ),

                    const SizedBox(height: 30),

                    /// OR DIVIDER
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.black.withOpacity(0.2)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Or sign up with",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.black.withOpacity(0.2)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// GOOGLE BUTTON WITH REAL LOGO
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Google login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/google.png", height: 22),
                            const SizedBox(width: 10),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// LOGIN LINK
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmailSigninScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                            children: const [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
