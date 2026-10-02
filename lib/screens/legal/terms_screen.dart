import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const String _content = '''
Last updated: September 2026

Welcome to Vellora. By creating an account or using Vellora, you agree to these Terms of Service. Please read them carefully before using the platform.

1. Using Vellora

Vellora is a dating and social connection platform that allows users to create profiles, discover other members, like profiles, match, and communicate through the app.

You agree to:
• Provide accurate and truthful information.
• Keep your account information secure.
• Use Vellora respectfully and responsibly.
• Follow applicable laws and Vellora's Community Guidelines.
• Interact with other members respectfully.

2. Eligibility

You must be 18 or older to use Vellora.

You must not create an account using someone else's identity or information.

3. Your Profile

You are responsible for the information, photos, prompts, and other content you add to your profile.

Do not upload:
• Fake or misleading information
• Someone else's photos without permission
• Harassing, hateful, or abusive content
• Illegal or harmful content
• Content that violates another person's privacy or rights

4. Matching & Messaging

Vellora allows members to like profiles, match with other members, and communicate through available messaging features.

A match does not guarantee that another member will respond or meet you offline. Use good judgment when communicating or meeting someone you met through Vellora.

Never share sensitive personal information with someone you do not trust.

5. Safety, Reporting & Blocking

You can use Vellora's Report and Block features when you encounter inappropriate, abusive, suspicious, or unwanted behavior.

We may review reported activity and take appropriate action, including restricting, suspending, or removing an account when necessary.

For more information, visit the Vellora Safety Centre.

6. Prohibited Activities

You must not use Vellora to:
• Harass, threaten, stalk, or intimidate others.
• Impersonate another person.
• Scam, defraud, or deceive other members.
• Send spam or unwanted promotional messages.
• Attempt to gain unauthorized access to another account.
• Use Vellora for illegal activities.
• Circumvent account restrictions or safety measures.

7. Account Suspension or Removal

We may limit, suspend, or remove accounts that violate these Terms, Community Guidelines, safety requirements, or applicable laws.

We may also take action when necessary to protect users, the platform, or the integrity of our services.

8. Subscriptions & Payments

Some Vellora features may require a paid subscription.

If you purchase a subscription, charges and renewals are handled through the applicable app store or payment provider. Subscriptions may automatically renew until cancelled according to the terms of the provider used for the purchase.

Please review the applicable billing provider's cancellation and refund policies.

9. Privacy

Your use of Vellora is also subject to our Privacy Policy, which explains how we collect, use, store, and protect your information.

10. Changes to These Terms

We may update these Terms from time to time. When changes are made, we may update the Last Updated date and provide additional notice where appropriate.

11. Contact Us

If you have questions about these Terms or your Vellora account, contact us through the support/contact option provided within Vellora.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            _content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ),
    );
  }
}
