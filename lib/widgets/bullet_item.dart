import 'package:flutter/material.dart';

/// Shared bullet-point widget used by privacy_policy_screen and
/// help_and_support_screen (QUALITY-03: deduplicated).
class BulletItem extends StatelessWidget {
  const BulletItem(this.text, {super.key});

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
