import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dating_app/utils/profile_theme.dart';

/// Pink→purple filled pill button.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ProfileTheme.buttonHeight,
      decoration: BoxDecoration(
        gradient: ProfileTheme.brand,
        borderRadius: BorderRadius.circular(ProfileTheme.radiusPill),
        boxShadow: ProfileTheme.brandShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusPill),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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

/// White pill button with a purple outline.
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = ProfileTheme.buttonHeight,
    this.color = ProfileTheme.purple,
    this.loading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final double height;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ProfileTheme.radiusPill),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ProfileTheme.radiusPill),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, color: color, size: 20),
                if (loading || icon != null) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: height < 48 ? 12.5 : 15,
                      fontWeight: FontWeight.w600,
                    ),
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

/// White pill chip with a light-purple border, icon and label.
class InterestChip extends StatelessWidget {
  const InterestChip({super.key, required this.label});

  final String label;

  static IconData iconFor(String interest) {
    final k = interest.toLowerCase();
    if (k.contains('travel') || k.contains('trip') || k.contains('adventure')) {
      return Icons.flight_takeoff_rounded;
    }
    if (k.contains('music') || k.contains('sing') || k.contains('concert')) {
      return Icons.music_note_rounded;
    }
    if (k.contains('food') || k.contains('cook') || k.contains('cafe') ||
        k.contains('coffee')) {
      return Icons.restaurant_rounded;
    }
    if (k.contains('fit') || k.contains('gym') || k.contains('yoga') ||
        k.contains('sport')) {
      return Icons.fitness_center_rounded;
    }
    if (k.contains('movie') || k.contains('film')) return Icons.movie_outlined;
    if (k.contains('read') || k.contains('book')) return Icons.menu_book_rounded;
    if (k.contains('art') || k.contains('paint')) return Icons.palette_outlined;
    if (k.contains('game')) return Icons.sports_esports_outlined;
    if (k.contains('dance')) return Icons.celebration_outlined;
    return Icons.favorite_border_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ProfileTheme.chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ProfileTheme.radiusPill),
        border: Border.all(color: ProfileTheme.chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(label), size: 16, color: ProfileTheme.purple),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ProfileTheme.navy,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded card with the standard soft shadow.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = ProfileTheme.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ProfileTheme.radiusCard),
        boxShadow: ProfileTheme.cardShadow,
      ),
      child: child,
    );
  }
}

/// "Profile Vibe Strength" card: label, percent, gradient progress, hint.
class VibeStrengthCard extends StatelessWidget {
  const VibeStrengthCard({super.key, required this.score, required this.hint});

  final int score;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final pct = score.clamp(0, 100) / 100;
    return ProfileCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: ProfileTheme.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profile Vibe Strength',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ProfileTheme.navy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$score% Complete',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ProfileTheme.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(ProfileTheme.radiusPill),
            child: Container(
              height: 8,
              color: ProfileTheme.track,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: ProfileTheme.brand,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(hint, style: ProfileTheme.small),
        ],
      ),
    );
  }
}

/// 3:4 photo tile. Shows the photo with an optional "Main" label.
class PhotoTile extends StatelessWidget {
  const PhotoTile({super.key, required this.url, this.isMain = false, this.onTap});

  final String url;
  final bool isMain;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ProfileTheme.radiusTile),
        child: Material(
          color: ProfileTheme.tileFill,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (_, child, progress) =>
                          progress == null
                              ? child
                              : const SkeletonBox(radius: 0),
                  errorBuilder:
                      (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: ProfileTheme.purple,
                        ),
                      ),
                ),
                if (isMain)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ProfileTheme.radiusPill,
                        ),
                      ),
                      child: Text(
                        'Main',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ProfileTheme.navy,
                        ),
                      ),
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

/// Dashed "+ Add photo" tile for empty photo slots.
class AddPhotoTile extends StatelessWidget {
  const AddPhotoTile({super.key, required this.onTap, this.loading = false});

  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DottedBorder(
        color: ProfileTheme.tileBorder,
        strokeWidth: 1.5,
        dashPattern: const [6, 5],
        borderType: BorderType.RRect,
        radius: const Radius.circular(ProfileTheme.radiusTile),
        child: Material(
          color: ProfileTheme.tileFill,
          borderRadius: BorderRadius.circular(ProfileTheme.radiusTile),
          child: InkWell(
            borderRadius: BorderRadius.circular(ProfileTheme.radiusTile),
            onTap: onTap,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ProfileTheme.purple.withOpacity(0.14),
                    ),
                    child:
                        loading
                            ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ProfileTheme.purple,
                              ),
                            )
                            : const Icon(
                              Icons.add_rounded,
                              color: ProfileTheme.purple,
                              size: 24,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add photo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ProfileTheme.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing placeholder block used for loading skeletons.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
    this.circle = false,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder:
          (_, __) => Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color:
                  Color.lerp(
                    ProfileTheme.track,
                    ProfileTheme.tileFill,
                    _c.value,
                  ),
              shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  widget.circle ? null : BorderRadius.circular(widget.radius),
            ),
          ),
    );
  }
}

/// Loading skeleton for the whole profile body.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SkeletonBox(
              width: ProfileTheme.avatarSize,
              height: ProfileTheme.avatarSize,
              circle: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 150, height: 22),
                  SizedBox(height: 10),
                  SkeletonBox(width: 90, height: 14),
                  SizedBox(height: 10),
                  SkeletonBox(width: 110, height: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SkeletonBox(height: ProfileTheme.chipHeight, radius: 17),
        const SizedBox(height: 20),
        const SkeletonBox(height: 96, radius: ProfileTheme.radiusCard),
        const SizedBox(height: 24),
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                child: const AspectRatio(
                  aspectRatio: 3 / 4,
                  child: SkeletonBox(radius: ProfileTheme.radiusTile),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
