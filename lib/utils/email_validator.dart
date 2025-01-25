// lib/utils/email_validation.dart

class ValidationUtils {
  static final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  /// Validates if the given string is a properly formatted email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Returns an error message if email is invalid, null if valid
  static String? getEmailError(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}
