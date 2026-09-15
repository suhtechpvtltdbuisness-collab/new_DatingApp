import 'package:flutter/material.dart';
class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  int? _expanded;

  static const List<({String q, String a})> _faqs = [
    (
      q: "How matching works?",
      a: "Browse people in the People tab. Swipe right (or tap Like) if you're "
          "interested and left to pass. When you both like each other it's a "
          "match and you can start chatting. Use Filters to choose who you "
          "want to date, their age range and distance.",
    ),
    (
      q: "How to report/block ?",
      a: "Open someone's profile and tap \"Report or Block Profile\", or use "
          "the menu in a chat. Blocked people can't message you or see you in "
          "People. You can unblock anyone from Profile → Block List.",
    ),
    (
      q: "Subscription & billing help ?",
      a: "See plans under Profile → My Wallet & Plans. For payment or billing "
          "issues, go to Help and Support → Contact support and choose "
          "\"Billing & Payments\".",
    ),
    (
      q: "Account & privacy info ?",
      a: "Your email and phone number are never shown on your profile. You can "
          "hide your profile, take a break, deactivate your account (it can be "
          "restored by logging back in) or delete it permanently from the "
          "Profile tab.",
    ),
  ];

  Widget buildTile(int index) {
    final faq = _faqs[index];
    final open = _expanded == index;
    return GestureDetector(
      onTap: () => setState(() => _expanded = open ? null : index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(faq.q)),
                AnimatedRotation(
                  turns: open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  faq.a,
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
              ),
              crossFadeState:
                  open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  children: const [
                    BackButton(color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      "FAQs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                for (var i = 0; i < _faqs.length; i++) buildTile(i),
              ],
            ),
          ),
        ),
      ),
    );
  }
}