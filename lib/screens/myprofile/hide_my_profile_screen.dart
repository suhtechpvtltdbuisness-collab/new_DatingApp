import 'package:dating_app/services/user_service.dart';
import 'package:flutter/material.dart';

class HideMyProfileScreen extends StatefulWidget {
  const HideMyProfileScreen({super.key});

  @override
  State<HideMyProfileScreen> createState() => _HideMyProfileScreenState();
}

class _HideMyProfileScreenState extends State<HideMyProfileScreen> {
  final UserService _userService = UserService();
  bool _isProfileHidden = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final response = await _userService.getMyProfile();
    if (!mounted || !response.success || response.data == null) return;
    setState(() => _isProfileHidden = response.data!.isHidden);
  }

  // ─── CONFIRMATION MODAL ──────────────────────────────────────────────────────
  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.45),
          builder: (ctx) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.visibility_off_outlined,
                        color: Color(0xFF9B6AAA), size: 26),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hide your profile?',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1A2A)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your profile will be hidden from other users. They won't be able to find or view you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF7A5A6E),
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD9EA).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: const Color(0xFFE7D9FF), width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7A5A6E)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3D77), Color(0xFFD81159)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  // ─── TOGGLE HANDLER ──────────────────────────────────────────────────────────
  Future<void> _handleToggle(bool value) async {
    if (_isSaving) return;
    if (value) {
      final confirmed = await _showConfirmDialog();
      if (!confirmed) return;
    }
    setState(() {
      _isProfileHidden = value;
      _isSaving = true;
    });
    final response = await _userService.updateMyProfile({'isHidden': value});
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (!response.success) _isProfileHidden = !value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !response.success
                ? 'Could not update your profile visibility. Please try again.'
                : value
                ? 'Your profile is now hidden'
                : 'Your profile is now visible',
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
          backgroundColor: const Color(0xFF9B6AAA),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────
  Widget _bulletPoint(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF3D77), Color(0xFF9B6AAA)],
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF5A3A5A),
                    height: 1.5),
              ),
            ),
          ],
        ),
      );

  Widget _card(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: const [
                  BackButton(color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Hide My Profile',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Edge Banner (shown when hidden) ───────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isProfileHidden
                    ? Container(
                        key: const ValueKey('banner'),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3D77).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFFF3D77).withOpacity(0.35),
                              width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline,
                                color: Color(0xFFD81159), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your profile is currently hidden from others',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFD81159),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no-banner')),
              ),

              // ── Primary Toggle Card ───────────────────────────────────────
              _card([
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hide My Profile',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D1A2A)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'When enabled, your profile will not be visible to others.',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: const Color(0xFF7A5A6E),
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: _isProfileHidden,
                        onChanged: _handleToggle,
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF9B6AAA),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor:
                            const Color(0xFFE7D9FF).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ]),

              // ── What Happens Section ──────────────────────────────────────
              _card([
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD9EA), Color(0xFFE7D9FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.visibility_off_outlined,
                          color: Color(0xFF9B6AAA), size: 17),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'What happens when you hide your profile?',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D1A2A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: const Color(0xFFFFD9EA).withOpacity(0.8),
                  margin: const EdgeInsets.only(bottom: 14),
                ),
                _bulletPoint('Your profile will not appear in search results'),
                _bulletPoint(
                    'Other users will not be able to view your profile'),
                _bulletPoint(
                    'You may not receive new connection requests or messages'),
                _bulletPoint(
                    'Your existing conversations will remain unchanged'),
              ]),

              // ── Status Indicator ──────────────────────────────────────────
              _card([
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isProfileHidden
                            ? const Color(0xFFD81159)
                            : const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isProfileHidden
                          ? 'Profile is currently hidden'
                          : 'Profile is currently visible',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: _isProfileHidden
                            ? const Color(0xFFD81159)
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isProfileHidden
                            ? const Color(0xFFD81159).withOpacity(0.1)
                            : const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isProfileHidden ? 'Hidden' : 'Visible',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isProfileHidden
                              ? const Color(0xFFD81159)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}