import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:dating_app/widgets/common/gradient_button.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';

/// Full profile detail view. Pass a real [profile] (e.g. from the swipe
/// deck or a match) to show live data pulled from the backend; when none
/// is supplied it falls back to a polished sample profile so the screen
/// is always presentable in isolation (design previews, tests, etc.).
class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key, this.profile});

  final UserModel? profile;

  @override
  Widget build(BuildContext context) {
    return ProfileDetailsContent(profile: profile);
  }
}

class ProfileDetailsContent extends StatelessWidget {
  const ProfileDetailsContent({super.key, this.profile});

  final UserModel? profile;

  @override
  Widget build(BuildContext context) {
    final name = profile != null ? profile!.fullName.trim() : 'Akshat Sharma';
    final displayName = name.isEmpty ? 'Member' : name;
    final age = profile?.age;
    final bio = (profile?.bio?.isNotEmpty ?? false)
        ? profile!.bio!
        : "I'm a minimalist by profession but a maximalist at heart when it "
            'comes to experiences. By day, I design sustainable urban spaces '
            'that breathe life back into the city.\n\nBorn in Milan, refined in '
            'London, and now making Barcelona my canvas. Looking for someone who '
            'values intellectual curiosity and enjoys spontaneous weekend trips.';
    final images = (profile?.photoUrls.isNotEmpty ?? false)
        ? profile!.photoUrls
        : const ['assets/images/profile.png', 'assets/images/profile.png', 'assets/images/profile.png'];
    final interests = (profile?.interests.isNotEmpty ?? false)
        ? profile!.interests
        : const ['Active', 'Non-smoker', 'Virgo', 'Social Drinker', 'Wants Kids'];
    final locationLabel = [profile?.city, profile?.country]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(', ');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 64, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            age != null ? '$displayName, $age' : displayName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        if (profile?.isVerified ?? true)
                          const Icon(Icons.verified_rounded, color: AppTheme.superLikeColor, size: 22),
                      ],
                    ),
                    if (locationLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textTertiaryColor),
                          const SizedBox(width: 4),
                          Text(locationLabel, style: const TextStyle(color: AppTheme.textSecondaryColor)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Say Hello 👋',
                            height: 52,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatId: profile?.id ?? 'new',
                                    name: displayName,
                                    image: images.first,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GhostButton(
                            label: 'Like ❤️',
                            height: 52,
                            borderColor: AppTheme.primaryColor,
                            textColor: AppTheme.primaryColor,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),
                    _sectionTitle(Icons.info_outline_rounded, 'My Story'),
                    const SizedBox(height: 10),
                    GlassCard(child: Text(bio, style: const TextStyle(color: AppTheme.textSecondaryColor, height: 1.5))),

                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(Icons.photo_library_outlined, 'Life Highlights'),
                        Text('View all', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _image(images[0], 310)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              _image(images.length > 1 ? images[1] : images[0], 150),
                              const SizedBox(height: 10),
                              _image(images.length > 2 ? images[2] : images[0], 150),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),
                    _sectionTitle(Icons.bolt_rounded, 'The Vibe'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: interests.map(_chip).toList(),
                    ),

                    const SizedBox(height: 26),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.flag_outlined, color: AppTheme.textTertiaryColor, size: 18),
                        label: const Text('Report or Block Profile', style: TextStyle(color: AppTheme.textTertiaryColor)),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.textPrimaryColor)),
      ],
    );
  }

  Widget _image(String path, double height) {
    final provider = path.startsWith('http') ? NetworkImage(path) : AssetImage(path) as ImageProvider;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Image(image: provider, height: height, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w500)),
    );
  }
}
