import 'package:flutter/material.dart';
import 'package:resmart/widgets/policy_dialogs.dart';

class NicknameInputDialog extends StatefulWidget {
  final String? userName;
  final Function(String?, bool) onNicknameSubmitted;

  const NicknameInputDialog({
    super.key,
    this.userName,
    required this.onNicknameSubmitted,
  });

  static Future<void> show(
    BuildContext context,
    String? userName,
    Function(String?, bool) onNicknameSubmitted,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => NicknameInputDialog(
        userName: userName,
        onNicknameSubmitted: onNicknameSubmitted,
      ),
    );
  }

  @override
  State<NicknameInputDialog> createState() => _NicknameInputDialogState();
}

class _NicknameInputDialogState extends State<NicknameInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _scrollController = ScrollController();
  bool _allowAnalytics = true;

  Widget _buildAnalyticsConsent() {
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
            value: _allowAnalytics,
            onChanged: (value) => setState(() => _allowAnalytics = value!),
          ),
          Expanded(
            child: Wrap(
              children: [
                const Text('Help us to improve '),
                InkWell(
                  onTap: () => PolicyDialogs.showAnalyticsInfo(context),
                  child: Text(
                    'Know more',
                    style: TextStyle(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: colorScheme.onSurface),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Welcome to ReSmart${widget.userName != null ? ", ${widget.userName}!" : "!"}',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nicknameController,
                          maxLength: 20,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          decoration: InputDecoration(
                            labelText: 'Choose your nickname (Optional)',
                            helperText:
                                'A nickname helps personalize your experience',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: colorScheme.primary, width: 2),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.person_outline),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 52,
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.length > 20) {
                              return 'Nickname must be 20 characters or less';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You can update your nickname, date of birth, additional phone numbers, or email addresses anytime in settings to enhance security.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.security,
                            color: colorScheme.primary,
                          ),
                          title: Text(
                            'Why add more?',
                            style: textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            'More details means better security and personalization.',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAnalyticsConsent(),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            final nickname = _nicknameController.text.isEmpty
                                ? null
                                : _nicknameController.text;
                            widget.onNicknameSubmitted(
                                nickname, _allowAnalytics);
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(colorScheme.primary),
                            foregroundColor: MaterialStateProperty.all(
                                colorScheme.onPrimary),
                            minimumSize: MaterialStateProperty.all(
                              const Size(double.infinity, 48),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Ready to go!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
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
