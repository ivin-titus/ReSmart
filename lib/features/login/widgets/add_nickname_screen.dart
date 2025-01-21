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
  bool _agreedToTerms = false;
  final bool _isLoading = false;

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

  Widget _buildTermsCheckbox() {
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
            value: _agreedToTerms,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() => _agreedToTerms = value!);
                  },
          ),
          Expanded(
            child: Wrap(
              children: [
                const Text('I agree to the '),
                InkWell(
                  onTap: _isLoading
                      ? null
                      : () => PolicyDialogs.showPrivacyDialog(context),
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: _isLoading
                          ? Theme.of(context).disabledColor
                          : colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text(' and '),
                InkWell(
                  onTap: _isLoading
                      ? null
                      : () => PolicyDialogs.showTermsDialog(context),
                  child: Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      color: _isLoading
                          ? Theme.of(context).disabledColor
                          : colorScheme.primary,
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
                              icon: Icon(Icons.close, color: colorScheme.onSurface),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Welcome to ReSmart${widget.userName != null ? ", ${widget.userName}!" : "!"}',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
  
                                'Choose how we\'ll address you',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nicknameController,
                                maxLength: 20,
                                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                decoration: InputDecoration(
                                  hintText: 'Enter nickname',
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You can always change this later in settings',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Final steps',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildAnalyticsConsent(),
                              const SizedBox(height: 12),
                              _buildTermsCheckbox(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _agreedToTerms && !_isLoading
                              ? () {
                                  final nickname = _nicknameController.text.isEmpty ? null : _nicknameController.text;
                                  widget.onNicknameSubmitted(nickname, _allowAnalytics);
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.disabled)) {
                                return colorScheme.primary.withOpacity(0.5);
                              }
                              return colorScheme.primary;
                            }),
                            foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
                            minimumSize: MaterialStateProperty.all(
                              const Size(double.infinity, 48),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          child: Text(
                            _isLoading ? 'Setting up...' : 'Ready to go!',
                            style: const TextStyle(
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