import 'package:dating_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:dating_app/utils/theme.dart';
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
  final List<TextEditingController> controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (final focusNode in focusNodes) {
      focusNode.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

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

  void verifyOtp() async {
    String otp = getOtp();

    if (otp.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter 4 digit OTP")));
      return;
    }

    final dio = Dio();

    try {
      /// 🔄 LOADER
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await dio.post(
        "${AppConstants.baseUrl}/users/otp/validate",
        data: {"otp": otp, "number": widget.phoneNumber},
      );

      Navigator.pop(context);

      print("VERIFY RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        if (widget.isLogin) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LocationScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
      }
    } catch (e) {
      Navigator.pop(context);

      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP verification failed")));
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
      backgroundColor: Colors.transparent,
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
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
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

                          children: List.generate(4, (index) {
                            final isFocused = focusNodes[index].hasFocus;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 65,
                              height: 65,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isFocused
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFFE7D9FF),
                                  width: 1.4,
                                ),
                                color: Colors.white.withOpacity(0.55),
                                boxShadow: isFocused
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF8B5CF6,
                                          ).withOpacity(0.22),
                                          blurRadius: 14,
                                          spreadRadius: 1.5,
                                        ),
                                      ]
                                    : const [],
                              ),
                              child: TextField(
                                controller: controllers[index],
                                focusNode: focusNodes[index],
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                cursorColor: const Color(0xFF8B5CF6),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: AppTheme.borderlessInputDecoration(
                                  counterText: "",
                                  isCollapsed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                onChanged: (value) => onChanged(value, index),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 40),

                        /// Verify Button
                        Container(
                          width: double.infinity,
                          height: 55,

                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3D77), Color(0xFF8B5CF6)],
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
              );
            },
          ),
        ),
      ),
    );
  }
}
