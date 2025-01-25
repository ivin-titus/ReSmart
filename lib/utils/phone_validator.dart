// phone_validator.dart
import 'package:resmart/models/countries.dart';

class PhoneValidator {
  static final Map<String, PhoneValidationRule> _phoneRules = {
    '+1': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '2125551234',
      format: 'XXX-XXX-XXXX'
    ),
    '+44': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '2012345678',
      format: 'XXXX XXX XXX'
    ),
    '+91': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '9876543210',
      format: 'XXXXX XXXXX'
    ),
    '+86': PhoneValidationRule(
      pattern: r'^\d{11}$',
      example: '13912345678',
      format: 'XXX XXXX XXXX'
    ),
    '+93': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '701234567',
      format: 'XXX XXX XXX'
    ),
    '+355': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '671234567',
      format: 'XXX XXX XXX'
    ),
    '+213': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '551234567',
      format: 'XXX XXX XXX'
    ),
    '+376': PhoneValidationRule(
      pattern: r'^\d{6}$',
      example: '123456',
      format: 'XXX XXX'
    ),
    '+244': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '923456789',
      format: 'XXX XXX XXX'
    ),
    '+54': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '91123456789',
      format: 'XX XXXX XXXX'
    ),
    '+43': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '6501234567',
      format: 'XXX XXX XXXX'
    ),
    '+61': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '412345678',
      format: 'XXX XXX XXX'
    ),
    '+32': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '471234567',
      format: 'XXX XX XX XX'
    ),
    '+55': PhoneValidationRule(
      pattern: r'^\d{11}$',
      example: '11987654321',
      format: 'XX XXXXX XXXX'
    ),
    '+359': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '888123456',
      format: 'XXX XXX XXX'
    ),
    '+855': PhoneValidationRule(
      pattern: r'^\d{8,9}$',
      example: '12345678',
      format: 'XXXX XXXX'
    ),
    '+237': PhoneValidationRule(
      pattern: r'^\d{8}$',
      example: '612345678',
      format: 'XXX XXXX XX'
    ),
    '+63': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '9171234567',
      format: 'XXX XXX XXXX'
    ),
    '+33': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '612345678',
      format: 'X XX XX XX XX'
    ),
    '+234': PhoneValidationRule(
      pattern: r'^\d{10}$',
      example: '8123456789',
      format: 'XXX XXX XXXX'
    ),
    '+94': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '712345678',
      format: 'XXX XXX XXX'
    ),
    '+971': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '501234567',
      format: 'XXX XXX XXX'
    ),
    '+84': PhoneValidationRule(
      pattern: r'^\d{9,10}$',
      example: '912345678',
      format: 'XXX XXX XXXX'
    ),
    '+263': PhoneValidationRule(
      pattern: r'^\d{9}$',
      example: '712345678',
      format: 'XXX XXX XXX'
    ),
  };

  static String? validatePhone(String? phone, String countryCode) {
    if (phone == null || phone.isEmpty) return null;

    final rule = _phoneRules[countryCode] ?? 
      PhoneValidationRule(pattern: r'^\d{7,15}$', example: '', format: '');
      
    if (!RegExp(rule.pattern).hasMatch(phone)) {
      return 'Invalid number for $countryCode\nFormat: ${rule.format}';
    }
    return null;
  }

  static bool isValidCountryCode(String code) {
    return countries.any((country) => country.dialCode == code);
  }

  static String? getPhonePattern(String countryCode) {
    return _phoneRules[countryCode]?.pattern;
  }
}

class PhoneValidationRule {
  final String pattern;
  final String example;
  final String format;

  PhoneValidationRule({
    required this.pattern,
    required this.example,
    required this.format,
  });
}
