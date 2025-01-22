class UsernameValidation {
  static final RegExp _usernameRegex = RegExp(r'^[a-z0-9_-]+$');

  static Future<String?> validateWithServer(String username) async {
    // TODO: Implement API call to check username availability
    // return 'Username already taken' if exists
    // return null if available
    return null;
  }

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }

    if (!_usernameRegex.hasMatch(value)) {
      return 'Username can only contain  [a - z], [0 - 9], _ , - ';
    }

    return null;
  }
}
