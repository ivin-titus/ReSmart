// otp verification screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:resmart/features/login/widgets/email_user_register.dart';


class OTPVerificationDialog extends StatefulWidget {
  final String contactInfo;
  final Function(String) onVerified;

  const OTPVerificationDialog({
    super.key,
    required this.contactInfo,
    required this.onVerified,
  });

  static Future<void> show(
    BuildContext context,
    String contactInfo,
    Function(String) onVerified,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => OTPVerificationDialog(
        contactInfo: contactInfo,
        onVerified: onVerified,
      ),
    );
  }

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog>
    with SingleTickerProviderStateMixin {
  final _otpLength = 6;
  final _mainController = TextEditingController();
  late final AnimationController _cursorController;
  late List<String> _displayValues;
  bool _isValid = false;
  bool _isResendActive = false;
  Timer? _resendTimer;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _displayValues = List.filled(_otpLength, '');
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
      _displayValues = List.filled(_otpLength, '');
      for (int i = 0; i < text.length && i < _otpLength; i++) {
        _displayValues[i] = text[i];
      }
      _isValid = text.length == _otpLength;
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
        _displayValues = List.filled(_otpLength, '');
        _isValid = false;
      });
      _startResendTimer();
    }
  }

  Widget _buildOTPBox(BuildContext context, int index, int currentLength) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 448 ? 400.0 : screenWidth - 48;
    final boxWidth = (maxWidth - 48 - (_otpLength - 1) * 8) / _otpLength;

    final isCurrent = index == currentLength;
    final isFilled = index < currentLength;

    return Container(
      width: boxWidth,
      height: 56,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: isFilled ? colorScheme.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.5),
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
    final textTheme = Theme.of(context).textTheme;
    final currentLength = _mainController.text.length;

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
                            icon:
                                Icon(Icons.close, color: colorScheme.onSurface),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Enter Verification Code',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Enter the 6-digit code sent to',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.contactInfo,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              _otpLength,
                              (index) =>
                                  _buildOTPBox(context, index, currentLength),
                            ),
                          ),
                          Positioned.fill(
                            child: TextField(
                              controller: _mainController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: _otpLength,
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isValid
                            ? () async {
                                widget.onVerified(_mainController.text);
                                await RegistrationDialog.show(
                                  context,
                                  widget.contactInfo,
                                  (userData) {
                                    debugPrint('Registration Data:');
                                    userData.forEach((key, value) =>
                                        debugPrint('$key: $value'));
                                  },
                                );
                                Navigator.pop(context);
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
                          'Verify',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isResendActive
                                  ? "Didn't receive the code?"
                                  : 'Resend code in $_resendCountdown seconds',
                              style: textTheme.bodyMedium,
                            ),
                            if (_isResendActive) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: _handleResend,
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
