import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _content = '''
Last updated: September 2026

Vellora respects your privacy. This Privacy Policy explains what information we collect, how we use it, and the choices available to you when you use Vellora.

1. Information We Collect

Depending on how you use Vellora, we may collect:
• Account information: name, email address, phone number, date of birth, and login information.
• Profile information: profile photos, bio, interests, preferences, location, and other information you choose to add.
• Dating activity: likes, matches, interactions, and profile preferences.
• Messages: information associated with communications sent through Vellora.
• Safety information: reports, blocks, complaints, verification information, and information needed to investigate safety issues.
• Technical information: device information, IP address, browser/app information, and basic usage data.
• Payment information: subscription and transaction information processed through the applicable payment provider.

2. How We Use Your Information

We use information to:
• Create and manage your account.
• Display and personalize your dating profile.
• Provide matching and discovery features.
• Enable likes, matches, and messaging.
• Verify profiles where verification is available.
• Prevent spam, fraud, abuse, and misuse.
• Process reports and safety complaints.
• Provide customer support.
• Process subscriptions and payments.
• Maintain, improve, and secure Vellora.

3. Location Information

If you enable location-related features, Vellora may use location information to provide features such as distance-based discovery.

4. Photos and Profile Content

Photos, bios, interests, and other information you choose to add to your profile may be visible to other Vellora members according to your account and discovery settings.

Do not upload information that you do not want other members to see.

5. Messages and Safety Reports

Messages and safety reports may be processed to provide the messaging and safety features of Vellora and to investigate violations of our Terms or Community Guidelines.

Safety reports and verification information may be reviewed by authorized team members when necessary for safety, moderation, or support.

6. Sharing of Information

We do not make your personal information publicly available except where you choose to display information through your Vellora profile or where disclosure is otherwise permitted or required by applicable law.

We may share information with service providers that help us operate Vellora, such as hosting, authentication, analytics, customer support, payment, and security providers.

7. Data Security

We use reasonable technical and organizational measures designed to protect personal information against unauthorized access, loss, misuse, or disclosure.

However, no online service can guarantee complete security.

8. Your Choices and Privacy Rights

Depending on applicable law, you may be able to request access to, correction of, or deletion of your personal information and may have other rights regarding your data.

Where we rely on your consent to process your information, you may withdraw that consent at any time by contacting us.

9. Account Deletion

You can request deletion of your Vellora account through the available account settings or by contacting support.

Some information may need to be retained for legitimate purposes such as legal compliance, fraud prevention, dispute resolution, or security.

10. Children's Privacy

Vellora is intended only for users aged 18 and above. We do not knowingly allow individuals under 18 to create or maintain dating accounts.

If we become aware that an account belongs to someone under 18, we may take appropriate action, including removing the account.

11. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. When we make material changes, we may provide additional notice where appropriate.

The Last Updated date at the top of this page will indicate when the policy was most recently changed.

12. Contact Us

If you have questions about this Privacy Policy, your account, or your personal information, contact Vellora through the support/contact option provided within the app or website.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
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
