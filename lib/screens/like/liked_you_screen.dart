import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
import '../subscription/subscription_screen.dart';

class LikedYouScreen extends StatefulWidget {
  final Function(int)? onTabTapped;

  const LikedYouScreen({super.key, this.onTabTapped});

  @override
  State<LikedYouScreen> createState() => _LikedYouScreenState();
}

class _LikedYouScreenState extends State<LikedYouScreen> {
  int _selectedFilter = 0; // 0 = All, 1 = New, 2 = Nearby

  void _onFilterSelected(int index) {
    setState(() {
      _selectedFilter = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Liked You',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryColor),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Check out people who liked your profile!',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ),

              const SizedBox(height: 20),

              /// MUST SEE PROFILES
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Must-see profiles',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimaryColor),
                ),
              ),

              const SizedBox(height: 12),

              /// HORIZONTAL CARDS
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildProfileCard('SK, 25', '95% MATCH'),
                    _buildProfileCard('Alex, 24', 'NEW'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FILTER BUTTONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildChip('All 42', _selectedFilter == 0, () => _onFilterSelected(0)),
                    _buildChip('New 12', _selectedFilter == 1, () => _onFilterSelected(1)),
                    _buildChip('Nearby 8', _selectedFilter == 2, () => _onFilterSelected(2)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// PREMIUM BOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Someone already likes you.',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimaryColor),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upgrade to Premium to see your full list of likes and match instantly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        label: 'Upgrade to Premium',
                        gradient: AppTheme.goldGradient,
                        height: 50,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// PROFILE CARD
  Widget _buildProfileCard(String name, String tag) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softShadow(),
        image: const DecorationImage(
          image: AssetImage('assets/images/profile.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(tag, style: const TextStyle(color: AppTheme.warmAccentColor, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  /// CHIP
  Widget _buildChip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.heroGradient : null,
          color: active ? null : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
