import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dating_app/services/auth_service.dart';
import 'email_verified_screen.dart';

class EmailOtpScreen extends StatefulWidget {
  final String email;

  const EmailOtpScreen({super.key, required this.email});

  @override
  State<EmailOtpScreen> createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  final AuthService _authService = AuthService();
  bool isLoading = false;

  int seconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    seconds = 30;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  Future<void> verifyOtp() async {
    String otp = controllers.map((e) => e.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authService.verifyEmail(widget.email, otp);

      if (response.success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerifiedScreen(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendCode() async {
    startTimer();

    try {
      final response = await _authService.sendEmailOtp(widget.email);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    }
  }

  Widget otpBox(int index) {
    return Container(
      width: 55,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
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
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// BACK
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),

                const SizedBox(height: 10),

                /// TITLE
                const Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "OTP sent to ${widget.email}",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 40),

                /// OTP BOXES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) => otpBox(index)),
                ),

                const SizedBox(height: 20),

                /// TIMER
                Center(
                  child: Text(
                    seconds > 0
                        ? "Resend code in 00:${seconds.toString().padLeft(2, '0')}"
                        : "You can resend code",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// VERIFY BUTTON
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
                    onPressed: isLoading ? null : verifyOtp,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Verify",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                /// RESEND TEXT
                Center(
                  child: GestureDetector(
                    onTap: seconds == 0 ? resendCode : null,
                    child: RichText(
                      text: TextSpan(
                        text: "Didn't receive the code? ",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        ),
                        children: [
                          TextSpan(
                            text: "Send again",
                            style: TextStyle(
                              color: seconds == 0 ? Colors.purple : Colors.grey,
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
    );
  }
}