import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resmart/models/countries.dart';
import 'package:resmart/utils/phone_validator.dart';
import 'package:resmart/widgets/country_code_dialog.dart';

class PhoneInputDialog extends StatefulWidget {
  final Function(String?) onPhoneSubmitted;

  const PhoneInputDialog({super.key, required this.onPhoneSubmitted});

  static Future<void> show(BuildContext context, Function(String?) onPhoneSubmitted) {
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
        child: PhoneInputDialog(onPhoneSubmitted: onPhoneSubmitted),
      ),
    );
  }

  static DateTime? _lastBackPress;

  @override
  State<PhoneInputDialog> createState() => _PhoneInputDialogState();
}

class _PhoneInputDialogState extends State<PhoneInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  Country _selectedCountry = countries.firstWhere((c) => c.code == 'IN');
  String? _phoneError;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final error = PhoneValidator.validatePhone(
      _phoneController.text,
      _selectedCountry.dialCode,
    );

    setState(() {
      _phoneError = error;
      _isValid = error == null && _phoneController.text.isNotEmpty;
    });
  }

  Widget _buildPhoneInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 75,
          margin: const EdgeInsets.only(right: 12),
          child: Stack(
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.dialCode,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final result = await showDialog<Country>(
                      context: context,
                      builder: (context) => CountryCodeDialog(
                        countries: countries,
                        selectedCountry: _selectedCountry,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedCountry = result;
                        _validatePhone();
                      });
                    }
                  },
                  child: const SizedBox(height: 56, width: double.infinity),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Phone Number',
              errorText: _phoneError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return _phoneError;
            },
          ),
        ),
      ],
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
                              'Register with Phone',
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
                            _buildPhoneInput(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isValid
                                  ? () {
                                      if (_formKey.currentState!.validate()) {
                                        final phoneNumber =
                                            '${_selectedCountry.dialCode}${_phoneController.text}';
                                        Navigator.pop(context);
                                        widget.onPhoneSubmitted(phoneNumber);
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
                                  const Size(double.infinity, 48),
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                elevation: MaterialStateProperty.all(0),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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