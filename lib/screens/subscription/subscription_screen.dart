import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'all_features_screen.dart';
import 'package:dating_app/models/subscription_plan_model.dart';
import 'package:dating_app/network/api_client.dart';
import 'package:dating_app/network/api_endpoints.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/legal_links_text.dart';

/// Modern, attractive, and fully responsive Subscription Screen.
/// Follows high-converting dating app paywall design standards with glassmorphic cards,
/// luminous gradients, clear plan comparison, and multi-device adaptability.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedIndex = 0;
  List<SubscriptionPlan> _plans =
      List<SubscriptionPlan>.from(SubscriptionPlan.defaultPlans);

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await ApiClient().get(ApiEndpoints.getPlans);
      if (response.success && response.data != null) {
        final rawData = response.data;
        List<dynamic>? rawList;
        if (rawData is List) {
          rawList = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          rawList = rawData['data'] as List<dynamic>;
        }

        if (rawList != null && rawList.isNotEmpty) {
          final fetched = rawList
              .map((item) =>
                  SubscriptionPlan.fromJson(item as Map<String, dynamic>))
              .where((p) => p.isActive)
              .toList();
          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _plans = fetched;
              if (selectedIndex >= _plans.length) {
                selectedIndex = 0;
              }
            });
          }
        }
      }
    } catch (_) {
      // Graceful fallback: defaultPlans remain active
    }
  }

  void _startCheckout(BuildContext context, {bool restore = false}) {
    final planTitle = selectedIndex < _plans.length
        ? _plans[selectedIndex].title
        : "selected";

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (restore ? AppTheme.accentColor : AppTheme.primaryColor)
                    .withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                restore
                    ? Icons.restore_rounded
                    : Icons.info_outline_rounded,
                color: restore ? AppTheme.accentColor : AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                restore ? 'Restore purchase' : 'Checkout unavailable',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          restore
              ? 'Purchases cannot be restored yet because payments are not enabled in this version of the app.'
              : 'Payments for the $planTitle plan are not available in this version of the app yet. You have not been charged.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String rawPrice) {
    final trimmed = rawPrice.trim();
    if (trimmed.isEmpty) return '₹99.99';
    if (!trimmed.startsWith('₹') && !trimmed.startsWith('\$') && !trimmed.startsWith('€')) {
      return '₹$trimmed';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF2F6), Color(0xFFF7ECFF), Color(0xFFEFE8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 650;
              final horizontalPadding = isTablet ? 24.0 : 16.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    children: [
                      // Header Navigation Bar
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 6,
                        ),
                        child: _buildHeader(context),
                      ),

                      // Scrollable Paywall Body
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Title & Tier Badge
                              _buildHeroSection(),
                              const SizedBox(height: 20),

                              // Spotlight Feature Card ("See who liked you")
                              _buildSpotlightFeatureCard(),
                              const SizedBox(height: 14),

                              // Secondary Perks (Grid of 2)
                              _buildSecondaryPerksGrid(),
                              const SizedBox(height: 18),

                              // "See all perks" Button
                              _buildSeeAllPerksButton(context),
                              const SizedBox(height: 26),

                              // "Select Your Plan" Header
                              _buildPlanSectionHeader(),
                              const SizedBox(height: 12),

                              // Plan Cards
                              ...List.generate(_plans.length, (index) {
                                final plan = _plans[index];
                                return _buildPlanCard(
                                  index: index,
                                  title: plan.title,
                                  price: _formatPrice(plan.price),
                                  subtitle: plan.subtitle,
                                  period: plan.period,
                                  badge: plan.badge,
                                  isBest: plan.isBest || plan.badge.isNotEmpty,
                                );
                              }),

                              const SizedBox(height: 16),

                              // Legal Links & Restore Purchase
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: LegalLinksText(
                                  before:
                                      'Recurring billing, cancel anytime. By subscribing, you agree to our ',
                                  after: '.',
                                  style: TextStyle(
                                    color: AppTheme.textTertiaryColor,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      _startCheckout(context, restore: true),
                                  child: Text(
                                    "Restore Purchase",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // Extra padding so bottom button does not overlap
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),

                      // Floating Bottom CTA Button Bar
                      _buildBottomBar(context, horizontalPadding),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Frosted Glass Back Button
        Material(
          color: Colors.white.withOpacity(0.85),
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.04),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ),

        // Centered Title with Diamond Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.diamond_rounded,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              "Subscription",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),

        // Quick Restore Button
        TextButton(
          onPressed: () => _startCheckout(context, restore: true),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Restore",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Glowing EXCLUSIVE TIER Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.14),
                AppTheme.accentColor.withOpacity(0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 13,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 5),
              Text(
                "EXCLUSIVE TIER",
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Large Headline
        Text(
          "Elevate your\nexperience.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.8,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle
        Text(
          "Premium is designed for those who want to skip the line, match 3x faster, and connect with intention.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.45,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSpotlightFeatureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF3D77), Color(0xFFFF5E8A), Color(0xFFCC3AA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Decorative Watermark Icon
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.bolt_rounded,
              size: 110,
              color: Colors.white.withOpacity(0.12),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "See who liked you",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Like them back and match instantly without waiting.",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.92),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryPerksGrid() {
    return Row(
      children: [
        Expanded(
          child: _featureBox(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFF8A5C),
            title: "Unlimited\nLikes",
            subtitle: "Send likes to as many people as you want.",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _featureBox(
            icon: Icons.visibility_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: "Incognito\nMode",
            subtitle: "Only be shown to people you've liked.",
          ),
        ),
      ],
    );
  }

  Widget _featureBox({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.95),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              height: 1.2,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllPerksButton(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(30),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.03),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllFeaturesScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "See all perks",
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Select Your Plan",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimaryColor,
            letterSpacing: -0.3,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Cancel anytime",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F9D58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    String period = "PER WEEK",
    String badge = "",
    bool isBest = false,
  }) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppTheme.primaryColor
                : Colors.white.withOpacity(0.9),
            width: selected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppTheme.primaryColor.withOpacity(0.16)
                  : Colors.black.withOpacity(0.02),
              blurRadius: selected ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppTheme.heroGradient : null,
                color: selected ? null : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppTheme.disabledColor,
                  width: 1.8,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Plan Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textPrimaryColor,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (isBest || badge.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppTheme.heroGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            badge.isNotEmpty ? badge : "BEST VALUE",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: selected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryColor,
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Price & Period
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.plusJakartaSans(
                    color: selected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  period.isNotEmpty ? period.toUpperCase() : "PER WEEK",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double horizontalPadding) {
    final selectedPlan = selectedIndex < _plans.length
        ? _plans[selectedIndex]
        : _plans.first;

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.8),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _startCheckout(context),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Get Premium Now • ${selectedPlan.title}",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
