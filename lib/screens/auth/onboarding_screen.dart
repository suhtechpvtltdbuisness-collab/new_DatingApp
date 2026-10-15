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
                      image: 'assets/images/boyimage.png',
                      networkImage:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=720&h=960&fit=crop&crop=faces&q=85',
                      name: 'Justin, 25',
                      location: 'New York',
                      rotation: -8,
                      bottom: 0,
                    ),
                    _buildCard(
                      image: 'assets/images/girlimage1.png',
                      networkImage:
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=720&h=960&fit=crop&crop=faces&q=85',
                      name: 'Julia, 23',
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

  /// Profile Card Widget. Loads a sharp network photo and falls back to the
  /// bundled asset when offline.
  static Widget _buildCard({
    required String image,
    required String networkImage,
    required String name,
    required String location,
    required double rotation,
    required double bottom,
  }) {
    final radius = BorderRadius.circular(AppTheme.radiusLg);

    return Positioned(
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation * 0.0174533,
        child: Container(
          width: 240,
          height: 320,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg + 4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.28),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  networkImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : Image.asset(image, fit: BoxFit.cover),
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset(image, fit: BoxFit.cover),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Colors.black.withOpacity(0.72), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 13, color: AppTheme.primaryColor),
                        SizedBox(width: 3),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            location,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
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
