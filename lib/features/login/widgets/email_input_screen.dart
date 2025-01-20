import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resmart/features/login/widgets/otp_verification_screen.dart';
import 'package:resmart/utils/email_validator.dart';

class EmailInputDialog extends StatefulWidget {
  final Function(String) onEmailSubmitted;

  const EmailInputDialog({super.key, required this.onEmailSubmitted});

  static Future<void> show(
      BuildContext context, Function(String) onEmailSubmitted) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (context.mounted && 
              Navigator.of(context).userGestureInProgress) {
            return false;
          }
          
          if (_lastBackPress == null || 
              now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
            _lastBackPress = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
            return false;
          }
          return true;
        },
        child: EmailInputDialog(onEmailSubmitted: onEmailSubmitted),
      ),
    );
  }

  static DateTime? _lastBackPress;

  @override
  State<EmailInputDialog> createState() => _EmailInputDialogState();
}

class _EmailInputDialogState extends State<EmailInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isValid = false;

  void _validateEmail(String value) {
    setState(() {
      _isValid = ValidationUtils.isValidEmail(value);
    });
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
                              'Continue with Email',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: colorScheme.primary,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 52,
                                ),
                              ),
                              onChanged: _validateEmail,
                              validator: ValidationUtils.getEmailError,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isValid
                                  ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        final email = _emailController.text;
                                        Navigator.pop(context);
                                        await OTPVerificationDialog.show(
                                          context,
                                          email,
                                          (otp) {
                                            debugPrint('OTP verified: $otp');
                                          },
                                        );
                                      }
                                    }
                                  : null,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  return states.contains(MaterialState.disabled)
                                      ? colorScheme.primary.withOpacity(0.3)
                                      : colorScheme.primary;
                                }),
                                foregroundColor:
                                    MaterialStateProperty.all(colorScheme.onPrimary),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(double.infinity, 48)),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                elevation: MaterialStateProperty.all(0),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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
    );
  }
}