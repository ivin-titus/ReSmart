class UsernameValidation {
  static final RegExp _usernameRegex = RegExp(r'^[a-z0-9_-]+$');

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }

    if (!_usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, underscores and hyphens';
    }

    return null;
  }
}
