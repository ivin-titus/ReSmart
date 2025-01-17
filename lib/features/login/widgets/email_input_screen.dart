import 'package:flutter/material.dart';
import 'package:resmart/features/login/widgets/otp_verification_screen.dart';

class EmailInputDialog extends StatefulWidget {
  final Function(String) onEmailSubmitted;

  const EmailInputDialog({super.key, required this.onEmailSubmitted});

  static Future<void> show(
      BuildContext context, Function(String) onEmailSubmitted) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) =>
          EmailInputDialog(onEmailSubmitted: onEmailSubmitted),
    );
  }

  @override
  State<EmailInputDialog> createState() => _EmailInputDialogState();
}

class _EmailInputDialogState extends State<EmailInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isValid = false;

  void _validateEmail(String value) {
    setState(() {
      _isValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      'Continue with Email',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.email_outlined),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 52,
                          ),
                        ),
                        onChanged: _validateEmail,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!_isValid) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        // test: Actual implimentation needed
                        onPressed: _isValid
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  final email = _emailController.text;
                                  Navigator.pop(context);
                                  await OTPVerificationDialog.show(
                                    context,
                                    email,
                                    (otp) {
                                      print('OTP verified: $otp');
                                      // Handle verification
                                    },
                                  );
                                }
                              }
                            : null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return colorScheme.primary.withOpacity(0.3);
                            }
                            return colorScheme.primary;
                          }),
                          foregroundColor:
                              MaterialStateProperty.all(colorScheme.onPrimary),
                          minimumSize: MaterialStateProperty.all(
                              const Size(double.infinity, 45)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        child: const Text('Next'),
                      )
                    ],
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
