import 'package:intl/intl.dart';

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});
}

class LegalDocument {
  final String id;
  final String title;
  final DateTime lastUpdated;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.id,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  String get lastUpdatedLabel =>
      'Last updated: ${DateFormat('MMMM yyyy').format(lastUpdated)}';
}

class LegalDocuments {
  static final privacyPolicy = LegalDocument(
    id: 'privacy_policy',
    title: 'Privacy Policy',
    lastUpdated: DateTime(2026, 9, 1),
    sections: const [
      LegalSection(
        heading: '1. Information we collect',
        body:
            'We collect account details you provide (such as name, email, date of birth, photos, and profile preferences), usage data from the app, and location information when you allow it so we can show nearby matches.',
      ),
      LegalSection(
        heading: '2. How we use your information',
        body:
            'We use your information to create and personalise your dating experience, recommend profiles, enable messaging with matches, improve safety and security, and send important service updates.',
      ),
      LegalSection(
        heading: '3. Sharing and disclosure',
        body:
            'We do not sell your personal information. We may share limited data with trusted service providers who help us operate the app, or when required by law. Other members only see the profile information you choose to show.',
      ),
      LegalSection(
        heading: '4. Your choices',
        body:
            'You can update or delete profile information, hide your profile, block users, and request account deletion. You can also manage notification and location permissions in your device settings.',
      ),
      LegalSection(
        heading: '5. Data retention and security',
        body:
            'We keep your data only as long as needed to provide the service or meet legal obligations. We use industry-standard measures to protect your account, but no method of transmission is 100% secure.',
      ),
      LegalSection(
        heading: '6. Contact',
        body:
            'If you have privacy questions or want to exercise your rights, contact us through Help and Support in the app.',
      ),
    ],
  );

  static final termsOfService = LegalDocument(
    id: 'terms_of_service',
    title: 'Terms of Service',
    lastUpdated: DateTime(2026, 9, 1),
    sections: const [
      LegalSection(
        heading: '1. Acceptance of terms',
        body:
            'By creating an account or using Velora, you agree to these Terms of Service and our Privacy Policy. If you do not agree, do not use the app.',
      ),
      LegalSection(
        heading: '2. Eligibility',
        body:
            'You must be at least 18 years old to use Velora. You are responsible for keeping your login details secure and for activity on your account.',
      ),
      LegalSection(
        heading: '3. Community rules',
        body:
            'Be respectful and honest. Do not harass, scam, impersonate others, post illegal content, or share contact details that violate our community guidelines. We may remove content or restrict accounts that break these rules.',
      ),
      LegalSection(
        heading: '4. Matches and messaging',
        body:
            'Matching and messaging features are provided for personal, non-commercial use. We may limit or moderate messaging to protect member safety.',
      ),
      LegalSection(
        heading: '5. Subscriptions',
        body:
            'Optional premium features may renew automatically until cancelled through your app store or account settings. Fees already charged are generally non-refundable except where required by law.',
      ),
      LegalSection(
        heading: '6. Termination',
        body:
            'You may delete your account at any time. We may suspend or terminate accounts that violate these terms or put other members at risk.',
      ),
      LegalSection(
        heading: '7. Contact',
        body:
            'For questions about these terms, reach us through Help and Support in the app.',
      ),
    ],
  );

  static LegalDocument? byId(String id) {
    switch (id) {
      case 'privacy_policy':
        return privacyPolicy;
      case 'terms_of_service':
        return termsOfService;
      default:
        return null;
    }
  }
}
