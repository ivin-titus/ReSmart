import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:resmart/features/login/widgets/email_user_register.dart';
import 'package:resmart/features/login/widgets/email_input_screen.dart';
import 'package:resmart/features/login/widgets/phone_input_screen.dart';
import 'package:resmart/utils/email_validator.dart';

class OTPVerificationDialog extends StatefulWidget {
  final String contactInfo;
  final Function(String) onVerified;

  const OTPVerificationDialog({
    super.key,
    required this.contactInfo,
    required this.onVerified,
  });

  static Future<void> show(
      BuildContext context, String contactInfo, Function(String) onVerified) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (context.mounted && Navigator.of(context).userGestureInProgress) {
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
        child: OTPVerificationDialog(
            contactInfo: contactInfo, onVerified: onVerified),
      ),
    );
  }

  static DateTime? _lastBackPress;

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog>
    with SingleTickerProviderStateMixin {
  final otpLength = 6;
  final TextEditingController _mainController = TextEditingController();
  late List<String> _displayValues;
  bool _isValid = false;
  bool _isResendActive = false;
  Timer? _resendTimer;
  int _resendCountdown = 60;
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _displayValues = List.filled(otpLength, '');
    _mainController.addListener(_handleMainControllerChange);
    _startResendTimer();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  void _handleMainControllerChange() {
    final text = _mainController.text;
    setState(() {
      _displayValues = List.filled(otpLength, '');
      for (int i = 0; i < text.length && i < otpLength; i++) {
        _displayValues[i] = text[i];
      }
      _isValid = text.length == otpLength;
    });
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _isResendActive = true);
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    if (_isResendActive) {
      setState(() {
        _isResendActive = false;
        _resendCountdown = 60;
        _mainController.clear();
        _displayValues = List.filled(otpLength, '');
        _isValid = false;
      });
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _resendTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLength = _mainController.text.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 448 ? 400.0 : screenWidth - 48;
    final boxWidth = (maxWidth - 48 - (otpLength - 1) * 8) / otpLength;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: maxWidth),
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
                      icon:
                          Icon(Icons.arrow_back, color: colorScheme.onSurface),
                      onPressed: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (ValidationUtils.isValidEmail(
                              widget.contactInfo)) {
                            EmailInputDialog.show(context, (email) {
                              debugPrint('Email submitted: $email');
                            });
                          } else {
                            PhoneInputDialog.show(context, (phone) {
                              debugPrint('Phone submitted: $phone');
                            });
                          }
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verification',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'OTP sent to "${widget.contactInfo}"',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(otpLength, (index) {
                        final isCurrent = index == currentLength;
                        final isFilled = index < currentLength;
                        return Container(
                          width: boxWidth,
                          height: 56,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFilled
                                  ? colorScheme.primary.withOpacity(0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? colorScheme.primary
                                    : Colors.grey.withOpacity(0.5),
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  _displayValues[index],
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (isCurrent && !isFilled)
                                  FadeTransition(
                                    opacity: _cursorController,
                                    child: Container(
                                      width: 2,
                                      height: 24,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    Positioned.fill(
                      child: TextField(
                        controller: _mainController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        maxLength: otpLength,
                        autofocus: true,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.transparent,
                        ),
                        cursorWidth: 0,
                        showCursor: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isValid
                      ? () async {
                          widget.onVerified(_mainController.text);
                          await RegistrationDialog.show(
                              context, widget.contactInfo, (userData) {
                            debugPrint('Registration Data:');
                            userData.forEach(
                                (key, value) => debugPrint('$key: $value'));
                          });
                          Navigator.pop(context);
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
                        const Size(double.infinity, 48)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: const Text('Verify',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _handleResend,
                    child: Text(
                      _isResendActive
                          ? 'Resend OTP'
                          : 'Resend OTP in $_resendCountdown seconds',
                      style: TextStyle(
                        color: _isResendActive
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.5),
                      ),
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
