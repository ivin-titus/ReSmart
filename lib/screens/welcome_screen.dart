// welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:resmart/widgets/policy_dialogs.dart';
import 'package:resmart/features/login/widgets/email_input_screen.dart';
import 'package:resmart/features/login/widgets/phone_input_screen.dart';
// import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.1),
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to Resmart',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _LoginButton(
                      icon: Icons.email_outlined,
                      text: 'Continue with Email',
                      onPressed: () {
                        EmailInputDialog.show(context, (email) {
                          debugPrint('Email submitted: $email');
                          // Handle email submission
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _LoginButton(
                      icon: FontAwesomeIcons.google,
                      text: 'Continue with Google',
                      onPressed: () {
                        PhoneInputDialog.show(context, (phone) {
                          debugPrint('Phone submitted: $phone');
                          // Handle phone submission
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _LoginButton(
                      icon: FontAwesomeIcons.github,
                      text: 'Continue with GitHub',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    _LoginButton(
                      icon: Icons.person_outline,
                      text: 'Continue without an Account',
                      isOutlined: true,
                      onPressed: () {},
                    ),
                    SizedBox(height: constraints.maxHeight * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () =>
                              PolicyDialogs.showPrivacyDialog(context),
                          child: const Text('Privacy Policy'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () =>
                              PolicyDialogs.showTermsDialog(context),
                          child: const Text('Terms and Conditions'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;

  const _LoginButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Common button style properties
    final ButtonStyle baseStyle = ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
      minimumSize: MaterialStateProperty.all(const Size(double.infinity, 45)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (isOutlined) {
          return states.contains(MaterialState.pressed)
              ? colorScheme.primary.withOpacity(0.12)
              : states.contains(MaterialState.hovered)
                  ? colorScheme.primary.withOpacity(0.08)
                  : Colors.transparent;
        } else {
          return states.contains(MaterialState.pressed)
              ? colorScheme.onPrimary.withOpacity(0.12)
              : states.contains(MaterialState.hovered)
                  ? colorScheme.onPrimary.withOpacity(0.08)
                  : Colors.transparent;
        }
      }),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (!isOutlined) {
          if (states.contains(MaterialState.pressed)) {
            return 0;
          }
          if (states.contains(MaterialState.hovered)) {
            return 2;
          }
          return 1;
        }
        return 0;
      }),
    );

    if (isOutlined) {
      return OutlinedButton.icon(
        icon: Icon(
          icon,
          color: colorScheme.primary,
          size: 18,
        ),
        label: Text(text),
        onPressed: onPressed,
        style: baseStyle.copyWith(
          foregroundColor: MaterialStateProperty.all(colorScheme.primary),
          side: MaterialStateProperty.all(
            BorderSide(color: colorScheme.primary),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: colorScheme.onPrimary,
        size: 18,
      ),
      label: Text(text),
      onPressed: onPressed,
      style: baseStyle.copyWith(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return colorScheme.primary.withOpacity(0.9);
          }
          if (states.contains(MaterialState.hovered)) {
            return colorScheme.primary.withOpacity(0.95);
          }
          return colorScheme.primary;
        }),
        foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
      ),
    );
  }
}
