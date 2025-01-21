import 'package:flutter/material.dart';
import 'package:resmart/widgets/policy_dialogs.dart';

class ConsentCheckbox extends StatelessWidget {
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;
  final ConsentType type;

  const ConsentCheckbox({
    super.key,
    required this.value,
    this.isLoading = false,
    required this.onChanged,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: isLoading ? null : (value) => onChanged(value!),
          ),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (type) {
      case ConsentType.analytics:
        return Wrap(
          children: [
            const Text('Help us to improve '),
            InkWell(
              onTap: () => PolicyDialogs.showAnalyticsInfo(context),
              child: Text(
                'Know more',
                style: TextStyle(
                  color: isLoading ? Theme.of(context).disabledColor : colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );

      case ConsentType.terms:
        return Wrap(
          children: [
            const Text('I agree to the '),
            InkWell(
              onTap: isLoading ? null : () => PolicyDialogs.showPrivacyDialog(context),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: isLoading ? Theme.of(context).disabledColor : colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Text(' and '),
            InkWell(
              onTap: isLoading ? null : () => PolicyDialogs.showTermsDialog(context),
              child: Text(
                'Terms and Conditions',
                style: TextStyle(
                  color: isLoading ? Theme.of(context).disabledColor : colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
    }
  }
}

enum ConsentType {
  analytics,
  terms,
}