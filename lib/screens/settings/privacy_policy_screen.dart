import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fulminant – Privacy Policy (Draft)',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: 23 August 2025',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('1. Overview'),
                const _BodyText(
                  'Fulminant is a gamified online learning app. This easy‑to‑read draft explains what data we collect, how we use it, and your choices. It is not a legal document and may be refined before release.',
                ),
                const _SectionTitle('2. Data we collect'),
                const _BodyText(
                    'We only collect a small set of personal details you enter yourself. All other information is created by the app as you learn.'),
                const _Bullet('Full name (you provide)'),
                const _Bullet('Email address (you provide)'),
                const _Bullet('Date of birth (you provide)'),
                const _Bullet('Password (you provide)'),
                const _Bullet(
                    'Learning activity generated in the app (e.g., enrolled courses, progress, quiz scores, badges, leaderboard status).'),
                const _SectionTitle('3. How we use your data'),
                const _Bullet('Create and manage your Fulminant account.'),
                const _Bullet('Let you sign in securely and recover access.'),
                const _Bullet(
                    'Show your courses, progress, achievements and leaderboards.'),
                const _Bullet(
                    'Improve app features based on aggregated, de‑identified usage patterns.'),
                const _Bullet(
                    'Send essential service messages (e.g., account or security notices).'),
                const _SectionTitle('4. What we do not do'),
                const _Bullet('We do not sell your personal data.'),
                const _Bullet(
                    'We do not show third‑party targeted ads based on your personal data.'),
                const _SectionTitle('5. Legal basis (plain English)'),
                const _BodyText(
                  'We process your data to run the app you asked for (account + learning features) and to keep the service secure. Where required, we rely on your consent (which you can withdraw in the app settings once available).',
                ),
                const _SectionTitle('6. Sharing'),
                const _BodyText(
                  'We may share limited data with service providers strictly to operate the app (for example, secure hosting). These partners must follow confidentiality and security obligations. We may also share anonymised statistics (that cannot identify you) to help us understand app performance.',
                ),
                const _SectionTitle('7. Storage & retention'),
                const _Bullet(
                    'Your account data is kept while your account is active.'),
                const _Bullet(
                    'If you delete your account, we will delete or irreversibly de‑identify your personal data within a reasonable period unless the law requires us to keep it longer (e.g., to resolve disputes or meet audit needs).'),
                const _SectionTitle('8. Security (summary)'),
                const _BodyText(
                  'We use industry‑standard safeguards to protect your information in transit and at rest. Passwords are stored securely using appropriate one‑way protection methods. No system is perfectly secure, but we work to minimise risks and respond quickly if issues arise.',
                ),
                const _SectionTitle('9. Children & learners'),
                const _BodyText(
                  'Fulminant is intended for learners who are legally allowed to use online services in their country. If you are under the minimum age in your region, a parent or guardian should review this policy and help manage your account.',
                ),
                const _SectionTitle('10. Your choices & controls'),
                const _Bullet(
                    'View and update your profile details inside the app (where available).'),
                const _Bullet(
                    'Request account deletion from inside the app or by contacting us.'),
                const _Bullet(
                    'Control email preferences for non‑essential messages (when settings are available).'),
                const _SectionTitle('11. International transfers'),
                const _BodyText(
                  'If we move or store data in other countries, we will use reasonable measures to protect it and follow applicable data‑transfer rules.',
                ),
                const _SectionTitle('12. Changes to this policy'),
                const _BodyText(
                  'We may revise this draft as features evolve. We will update the date at the top and, where changes are significant, we will provide a clear in‑app notice.',
                ),
                const _SectionTitle('13. Contact'),
                const _BodyText(
                  'Questions or requests about privacy? Use the in‑app support option or the contact information shown on our app store listing. We will do our best to help.',
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Thank you for learning with Fulminant!',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
