import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/utils/validators.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';

enum _Step { email, otp, password }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  late final TextEditingController _emailController =
      TextEditingController(text: widget.initialEmail);
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  _Step _step = _Step.email;
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (Validators.validateEmail(email) != null) {
      _toast('Please enter a valid email address.');
      return;
    }
    await _run(() async {
      final response = await _authService.resetPassword(email);
      if (!mounted) return;
      if (response.success) {
        _otpController.clear();
        setState(() => _step = _Step.otp);
        _toast('If an account exists for $email, a code has been sent.');
      } else {
        _toast(response.message);
      }
    });
  }

  Future<void> _verifyCode() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _toast('Enter the code sent to your email.');
      return;
    }
    await _run(() async {
      final response =
          await _authService.verifyResetOtp(_emailController.text.trim(), otp);
      if (!mounted) return;
      if (response.success) {
        setState(() => _step = _Step.password);
      } else {
        _toast(response.message);
      }
    });
  }

  Future<void> _savePassword() async {
    final password = _passwordController.text;
    if (password.length < 6) {
      _toast('Password must be at least 6 characters.');
      return;
    }
    if (password != _confirmController.text) {
      _toast('Passwords do not match.');
      return;
    }
    await _run(() async {
      final response = await _authService.confirmPasswordReset(
        _emailController.text.trim(),
        _otpController.text.trim(),
        password,
      );
      if (!mounted) return;
      if (response.success) {
        _toast('Password updated. Please log in with your new password.');
        Navigator.pop(context);
      } else {
        _toast(response.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      _Step.email => ('Forgot password', 'Enter your email and we will send you a code.'),
      _Step.otp => ('Enter code', 'We sent a code to ${_emailController.text.trim()}.'),
      _Step.password => ('New password', 'Choose a new password for your account.'),
    };

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
                  onPressed: () => _step == _Step.email
                      ? Navigator.pop(context)
                      : setState(() => _step = _Step.values[_step.index - 1]),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),
                if (_step == _Step.email) ...[
                  _field(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 30),
                  GradientButton(
                    label: 'Send code',
                    isLoading: _isLoading,
                    onPressed: _sendCode,
                  ),
                ],
                if (_step == _Step.otp) ...[
                  _field(
                    controller: _otpController,
                    hintText: 'Enter code',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  GradientButton(
                    label: 'Verify',
                    isLoading: _isLoading,
                    onPressed: _verifyCode,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _sendCode,
                      child: const Text(
                        'Resend code',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (_step == _Step.password) ...[
                  _field(
                    controller: _passwordController,
                    hintText: 'New password',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    controller: _confirmController,
                    hintText: 'Confirm new password',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  const SizedBox(height: 30),
                  GradientButton(
                    label: 'Save password',
                    isLoading: _isLoading,
                    onPressed: _savePassword,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.inputBorderColor),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: obscure && _obscure,
          keyboardType: keyboardType,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: AppTheme.primaryColor,
          decoration: AppTheme.borderlessInputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppTheme.textTertiaryColor, size: 20),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textTertiaryColor,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
      ),
    );
  }
}
