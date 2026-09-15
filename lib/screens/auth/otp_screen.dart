import 'dart:async';

import 'package:dating_app/controllers/registration_controller.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/utils/post_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dating_app/utils/theme.dart';
import 'profile_setup_screen.dart';

class OTPScreen extends StatefulWidget {
  /// Full E.164 number, e.g. +919999999999.
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

  static const int _resendSeconds = 30;
  int _resendIn = _resendSeconds;
  Timer? _timer;
  bool _verifying = false;
  bool _resending = false;

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
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _resendIn = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resend() async {
    if (_resending || _resendIn > 0) return;
    setState(() => _resending = true);
    final response = await AuthService().sendPhoneOtp(widget.phoneNumber);
    if (!mounted) return;
    setState(() => _resending = false);
    if (response.success) {
      for (final c in controllers) {
        c.clear();
      }
      _startCooldown();
      _toast('A new code has been requested');
    } else {
      _toast(response.message.isNotEmpty ? response.message : "Couldn't resend the code");
    }
  }

  Future<void> verifyOtp() async {
    if (_verifying) return;
    String otp = getOtp();

    if (otp.length != 4) {
      _toast("Please enter 4 digit OTP");
      return;
    }

    setState(() => _verifying = true);

    if (widget.isLogin) {
      // POST /users/login { phoneNumber, otp } validates the code itself.
      final response = await AuthService().loginWithPhone(widget.phoneNumber, otp);
      if (!mounted) return;
      setState(() => _verifying = false);
      if (!response.success) {
        _toast(response.message.isNotEmpty ? response.message : 'Invalid or expired code');
        return;
      }
      await finishLogin(context);
      return;
    }

    final response = await AuthService().verifyPhoneOtp(widget.phoneNumber, otp);
    if (!mounted) return;
    setState(() => _verifying = false);
    if (!response.success) {
      _toast(response.message.isNotEmpty ? response.message : 'Invalid or expired code');
      return;
    }

    Get.find<RegistrationController>().setPhoneNumber(widget.phoneNumber);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
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
                          "Enter the 4-digit code sent to ${widget.phoneNumber}",
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
                            onPressed: _verifying ? null : verifyOtp,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),

                            child: Text(
                              _verifying ? "Verifying..." : "Verify & Proceed",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: TextButton(
                            onPressed: _resendIn > 0 || _resending ? null : _resend,
                            child: Text(
                              _resendIn > 0
                                  ? "Resend code in ${_resendIn}s"
                                  : (_resending ? "Sending..." : "Resend code"),
                            ),
                          ),
                        ),
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
