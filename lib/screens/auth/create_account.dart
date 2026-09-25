import 'package:dating_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/auth/phone_number_screen.dart';
import 'package:dating_app/screens/auth/have_account_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/couple.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(133, 4, 4, 4), Color(0x00FFFFFF)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  /// Logo Section
                  /// Logo Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/heart_icon.png",
                            width: 36,
                            height: 36,
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            "Vellora",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF3D77),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Destined connections",
                        style: TextStyle(
                          color: Color(0xFFFF3D77),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// Main Title — "perfect match" carries the brand gradient
                  /// so the promise reads as the hero of the screen.
                  Column(
                    children: [
                      const Text(
                        "Find your",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.heroGradient.createShader(bounds),
                        child: const Text(
                          "perfect match",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            height: 1.15,
                            // ShaderMask paints over this; it only has to be
                            // opaque for the gradient to show through.
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 26,
                            height: 1,
                            color: Colors.white.withOpacity(0.45),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Written in the stars",
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 1.6,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 26,
                            height: 1,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// Create Account Button
                  Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3D77), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PhoneNumberScreen(isLogin: false),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// Login Button
                  /// Login Button
                  Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HaveAccountScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        "I have an account",
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Terms Text
                  const Text(
                    "By signing up, you agree to our Terms.\nSee how we use your data in our Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
