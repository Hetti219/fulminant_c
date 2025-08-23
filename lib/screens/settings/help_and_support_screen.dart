import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'privacy_policy_screen.dart'; // Adjust the path if your file lives elsewhere

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static const String _supportEmail =
      'support@fulminant.app'; // ← change to your real inbox
  static const String _feedbackFormUrl =
      'https://example.com/fulminant-feedback'; // ← optional: Google Form

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const HelpAndSupportScreen());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'We\'re here to help',
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to Fulminant\'s Help & Support. Find quick fixes, FAQs, and ways to contact us.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Quick actions',
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.email_outlined,
                      title: 'Copy support email',
                      subtitle: _supportEmail,
                      onTap: () => _copyToClipboard(context, _supportEmail,
                          label: 'Support email copied'),
                    ),
                    const Divider(height: 0),
                    _ActionTile(
                      icon: Icons.feedback_outlined,
                      title: 'Copy feedback form link',
                      subtitle: _feedbackFormUrl,
                      onTap: () => _copyToClipboard(context, _feedbackFormUrl,
                          label: 'Feedback link copied'),
                    ),
                    const Divider(height: 0),
                    _ActionTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'View Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () => Navigator.of(context)
                          .push(PrivacyPolicyScreen.route()),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Troubleshooting',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Bullet('Check your internet connection and try again.'),
                    _Bullet(
                        'Pull to refresh the Courses screen to reload data.'),
                    _Bullet(
                        'If progress looks wrong, sign out and sign back in.'),
                    _Bullet(
                        'Still stuck? Copy the support email above and contact us.'),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Frequently asked questions',
                child: const _FaqList(
                  items: [
                    FaqItem(
                      q: 'How do I reset my password?',
                      a: 'From the Sign In screen, choose “Forgot password”. We\'ll send a reset link to your registered email.',
                    ),
                    FaqItem(
                      q: 'Why can\'t I see my course progress?',
                      a: 'Make sure you\'re online, then pull to refresh on the Courses screen. If the issue persists, sign out/in to resync.',
                    ),
                    FaqItem(
                      q: 'How do I report a bug?',
                      a: 'Use the “Copy support email” quick action and email us with steps to reproduce, screenshots (if possible), and your device model.',
                    ),
                    FaqItem(
                      q: 'What data does Fulminant collect?',
                      a: 'Only your name, email, date of birth, and password as provided by you, plus learning activity generated inside the app. See the Privacy Policy for details.',
                    ),
                    FaqItem(
                      q: 'Is there a way to give feedback or feature requests?',
                      a: 'Yes—copy the feedback form link above and share your thoughts. We value your ideas!',
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Report a problem (template)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tap to copy the template below, then paste it into your email to us.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    _OutlinedBox(
                      child: SelectableText(
                        _bugTemplate,
                        style: textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _copyToClipboard(context, _bugTemplate,
                            label: 'Template copied'),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy template'),
                      ),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'About Fulminant',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _KeyValueRow('App', 'Fulminant'),
                    _KeyValueRow('Version', '0.1.0-UAT.2'),
                    // TODO: wire with package_info_plus
                    _KeyValueRow('Purpose', 'Online Gamified mobile learning'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _copyToClipboard(BuildContext context, String value,
      {String? label}) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label ?? 'Copied to clipboard')),
    );
  }
}

// ——— Widgets ———

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
      onTap: onTap,
      horizontalTitleGap: 12,
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
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList({required this.items});

  final List<FaqItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((i) => _FaqTile(question: i.q, answer: i.a))
          .toList(growable: false),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        title:
            Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(answer),
            ),
          )
        ],
      ),
    );
  }
}

class FaqItem {
  const FaqItem({required this.q, required this.a});

  final String q;
  final String a;
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow(this.keyLabel, this.valueLabel);

  final String keyLabel;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
              width: 120,
              child: Text(keyLabel,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(valueLabel)),
        ],
      ),
    );
  }
}

class _OutlinedBox extends StatelessWidget {
  const _OutlinedBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

const String _bugTemplate = 'Subject: Bug report — Fulminant\n\n'
    'What happened?\n'
    '- Describe the issue briefly.\n\n'
    'Steps to reproduce:\n'
    '1) ...\n'
    '2) ...\n'
    '3) ...\n\n'
    'Expected result:\n'
    '- What did you expect to happen?\n\n'
    'Actual result:\n'
    '- What happened instead?\n\n'
    'Device details (optional):\n'
    '- Phone model / OS version\n'
    '- App version (see About Fulminant)\n\n'
    'Screenshots / screen recording (optional):\n'
    '- Attach if available.\n\n'
    'Contact email:\n'
    '- So we can reach you if needed.';
