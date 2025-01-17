import 'package:flutter/material.dart';
import 'dart:async';

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
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => OTPVerificationDialog(
          contactInfo: contactInfo, onVerified: onVerified),
    );
  }

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
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
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
                        return SizedBox(
                          width: boxWidth,
                          height: 56,
                          child: Stack(
                            children: [
                              TextField(
                                enabled: false,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: isFilled
                                      ? colorScheme.primary.withOpacity(0.1)
                                      : null,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isCurrent
                                          ? colorScheme.primary
                                          : Colors.grey.withOpacity(0.5),
                                      width: isCurrent ? 2 : 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isCurrent
                                          ? colorScheme.primary
                                          : Colors.grey.withOpacity(0.5),
                                      width: isCurrent ? 2 : 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: isCurrent
                                          ? colorScheme.primary
                                          : Colors.grey.withOpacity(0.5),
                                      width: isCurrent ? 2 : 1,
                                    ),
                                  ),
                                ),
                                controller: TextEditingController(
                                    text: _displayValues[index]),
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (isCurrent)
                                Center(
                                  child: FadeTransition(
                                    opacity: _cursorController,
                                    child: Container(
                                      width: 2,
                                      height: 24,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _mainController,
                        keyboardType: TextInputType.number,
                        maxLength: otpLength,
                        autofocus: true,
                        decoration: const InputDecoration(counterText: ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          widget.onVerified(_mainController.text);
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
