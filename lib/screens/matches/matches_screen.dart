import 'package:dating_app/controllers/swipe_controller.dart';
import 'package:dating_app/utils/theme.dart';
import 'package:dating_app/widgets/common/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final swipeController = Get.find<SwipeController>();

  @override
  void initState() {
    super.initState();
    swipeController.getMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Your Matches'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Obx(
            () => swipeController.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : swipeController.matches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: const BoxDecoration(gradient: AppTheme.heroGradient, shape: BoxShape.circle),
                                child: const Icon(Icons.favorite_rounded, size: 36, color: Colors.white),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                swipeController.errorMessage.value.isEmpty
                                    ? 'No matches yet — keep swiping!'
                                    : swipeController.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                        itemCount: swipeController.matches.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final match = swipeController.matches[index];
                          return GlassCard(
                            radius: 20,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                                  child: const Icon(Icons.person, color: AppTheme.primaryColor),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(match.userId, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimaryColor)),
                                      const SizedBox(height: 2),
                                      Text(
                                        match.status.name,
                                        style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                if (match.isPending)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _iconAction(
                                        icon: Icons.close_rounded,
                                        color: AppTheme.rejectColor,
                                        onTap: () => swipeController.rejectMatch(match.id),
                                      ),
                                      const SizedBox(width: 8),
                                      _iconAction(
                                        icon: Icons.check_rounded,
                                        color: AppTheme.acceptColor,
                                        onTap: () => swipeController.acceptMatch(match.id),
                                      ),
                                    ],
                                  )
                                else
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.acceptColor),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }

  Widget _iconAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
