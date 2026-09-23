import 'package:dating_app/app/app_routes.dart';
import 'package:dating_app/controllers/auth_controller.dart';
import 'package:dating_app/screens/auth/email_signup_screen.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/utils/validators.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/utils/post_login.dart';
import 'package:get/get.dart';

class EmailSigninScreen extends StatefulWidget {
  const EmailSigninScreen({super.key});

  @override
  State<EmailSigninScreen> createState() => _EmailSigninScreenState();
}

class _EmailSigninScreenState extends State<EmailSigninScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Use AuthController (GetX) so isLoggedIn / userId observables stay in sync
  final AuthController _authController = Get.find<AuthController>();

  bool showEmailForm = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (Validators.validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password is required.')));
      return;
    }

    final success = await _authController.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      await finishLogin(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authController.errorMessage.value.isNotEmpty
                ? _authController.errorMessage.value
                : 'Login failed. Please check your credentials.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed:
                      () =>
                          Navigator.canPop(context)
                              ? Navigator.pop(context)
                              : AppRoutes.toOnboarding(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showEmailForm
                      ? 'Enter your email and password to continue.'
                      : 'Choose how you want to sign in.',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),
                if (!showEmailForm) ...[
                  _buildSignInOption(
                    icon: Icons.email_outlined,
                    label: 'Continue with Email',
                    onTap: () {
                      setState(() {
                        showEmailForm = true;
                      });
                    },
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSignInOption(
                    icon: null,
                    imageAsset: 'assets/images/google.png',
                    label: 'Continue with Google',
                    onTap: () => continueWithGoogle(context),
                  ),
                ] else ...[
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      color: AppTheme.textTertiaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.textTertiaryColor,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textTertiaryColor,
                        size: 20,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => GradientButton(
                      label: 'Login',
                      isLoading: _authController.isLoading.value,
                      onPressed: _loginWithEmail,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          showEmailForm = false;
                        });
                      },
                      child: const Text(
                        'Back to sign in options',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Divider(color: AppTheme.dividerColor),
                const SizedBox(height: 18),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const EmailSignupScreen()),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInOption({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    String? imageAsset,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color:
                isPrimary
                    ? AppTheme.primaryColor
                    : Colors.black.withOpacity(0.08),
            width: isPrimary ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(isPrimary ? 0.14 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
            ],
            if (imageAsset != null) ...[
              Image.asset(imageAsset, height: 22),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isPrimary
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.inputBorderColor),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: AppTheme.primaryColor,
          decoration: AppTheme.borderlessInputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ),
    );
  }
}
