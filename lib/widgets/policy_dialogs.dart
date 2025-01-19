// lib/widgets/policy_dialogs.dart
import 'package:flutter/material.dart';
import 'package:resmart/services/launch_urls.dart';

class PolicyDialogs {
  static Future<void> showTermsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PolicyPopup(
          title: 'Terms and Conditions (Summary)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BulletPoint(
                  'The app is provided "as-is" without any guarantees.'),
              _BulletPoint(
                  'Users must ensure compatibility with their devices.'),
              _BulletPoint(
                  'Unauthorized use, reproduction, or redistribution is prohibited.'),
              _BulletPoint(
                  'The app\'s source code is available under the MIT license.'),
            ],
          ),
          onReadMore: () {
            Navigator.of(context).pop();
            UrlLauncherUtil.launchURL(
              'https://github.com/ivin-titus/ReSmart/blob/master/privacy_policy_and_terms_and_conditions.md#detailed-terms-and-conditions',
            );
          },
        );
      },
    );
  }

  static Future<void> showPrivacyDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PolicyPopup(
          title: 'Privacy Policy (Summary)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BulletPoint(
                  'User data is only collected with consent and is securely stored.'),
              _BulletPoint(
                  'Collected data is strictly used to improve app functionality.'),
              _BulletPoint(
                  'No user data is shared with third parties without explicit consent.'),
              _BulletPoint(
                'User privacy is prioritized above regional laws, wherever permissible.',
                isBold: true,
              ),
              _BulletPoint(
                  'The app\'s source code is available under the MIT license for transparency.'),
            ],
          ),
          onReadMore: () {
            Navigator.of(context).pop();
            UrlLauncherUtil.launchURL(
              'https://github.com/ivin-titus/ReSmart/blob/master/privacy_policy_and_terms_and_conditions.md#detailed-privacy-policy',
            );
          },
        );
      },
    );
  }

  static Future<void> showAnalyticsInfo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PolicyPopup(
          title: 'Analytics Information',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BulletPoint(
                'We collect anonymous data to improve your app experience, including device info, usage metrics, performance data, and crash reports.',
              ),
              _BulletPoint(
                'This data is anonymized, non-personally identifiable, and used only for app improvements.',
              ),
              _BulletPoint(
                'You can view, delete, or opt out of analytics at any time in the Manage Account section.',
                isBold: true,
              ),
              _BulletPoint(
                'No data is shared with third parties without your consent.',
              ),
            ],
          ),
          onReadMore: () {
            Navigator.of(context).pop();
            UrlLauncherUtil.launchURL(
              'https://github.com/ivin-titus/ReSmart/blob/master/privacy_policy_and_terms_and_conditions.md#analytics-information',
            );
          },
        );
      },
    );
  }
}

class _PolicyPopup extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onReadMore;

  const _PolicyPopup({
    required this.title,
    required this.content,
    required this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onReadMore,
                  child: const Text('Read More'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final bool isBold;

  const _BulletPoint(
    this.text, {
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
