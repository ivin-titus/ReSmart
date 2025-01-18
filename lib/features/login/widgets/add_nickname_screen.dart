import 'package:flutter/material.dart';

class NicknameInputDialog extends StatefulWidget {
  final String? userName;
  final Function(String?) onNicknameSubmitted;

  const NicknameInputDialog({
    super.key,
    this.userName,
    required this.onNicknameSubmitted,
  });

  static Future<void> show(
    BuildContext context,
    String? userName,
    Function(String?) onNicknameSubmitted,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to ReSmart${widget.userName != null ? ", ${widget.userName}!" : "!"}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: 'Choose your nickname (Optional)',
                            helperText:
                                'A nickname helps personalize your experience',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.person_outline),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 52,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You can always update your nickname, Date of Birth, additional phone numbers, or email addresses later in the settings for added security.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.security,
                            color: colorScheme.primary,
                          ),
                          title: Text(
                            'Why add more?',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            'More details means better security and personalization.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () {
                            final nickname = _nicknameController.text.isEmpty
                                ? null
                                : _nicknameController.text;
                            widget.onNicknameSubmitted(nickname);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              height: 45,
                              alignment: Alignment.center,
                              child: Text(
                                'Ready to go!',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
