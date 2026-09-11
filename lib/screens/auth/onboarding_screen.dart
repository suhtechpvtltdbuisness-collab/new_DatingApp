import 'package:dating_app/screens/auth/create_account.dart';
import 'package:dating_app/utils/constants.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';

class ModernOnboardingScreen extends StatelessWidget {
  const ModernOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 28),

              /// Logo
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.heroGradient.createShader(bounds),
                child: const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// Card Stack Section
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCard(
                      image: 'assets/images/girlimage1.png',
                      name: 'Justin, 25',
                      location: 'New York',
                      rotation: -8,
                      bottom: 0,
                    ),
                    _buildCard(
                      image: 'assets/images/boyimage.png',
                      name: 'Julia Lode, 23',
                      location: 'Los Angeles',
                      rotation: 8,
                      bottom: 20,
                    ),

                    /// Floating Icons
                    Positioned(
                      left: 40,
                      top: 80,
                      child: _circleIcon(Icons.card_giftcard, AppTheme.accentColor),
                    ),
                    Positioned(
                      right: 40,
                      top: 60,
                      child: _circleIcon(Icons.chat_bubble, AppTheme.superLikeColor),
                    ),
                    Positioned(
                      right: 50,
                      bottom: 30,
                      child: _circleIcon(Icons.favorite, AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),

              /// Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Find Your\n',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Perfect Match',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Meet new people, spark real connections, and see where it goes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 15.5, height: 1.4),
                ),
              ),

              const SizedBox(height: 28),

              /// Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GradientButton(
                  label: 'Get Started',
                  gradient: AppTheme.heroGradient,
                  height: 58,
                  icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile Card Widget (for Network/Asset Images)
  static Widget _buildCard({
    required String image,
    required String name,
    required String location,
    required double rotation,
    required double bottom,
  }) {
    return Positioned(
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation * 0.0174533,
        child: Container(
          width: 240,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.28),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black.withOpacity(0.65), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(location, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
