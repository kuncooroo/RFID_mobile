/// Form validators for auth screens (used with [Form] / [AppTextField]).
abstract final class AuthValidators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? name(String? value) => required(value, field: 'Name');

  static String? identifier(String? value) {
    final empty = required(value, field: 'Email or phone');
    if (empty != null) return empty;

    final trimmed = value!.trim();
    if (trimmed.contains('@')) {
      final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
      if (!emailOk) return 'Enter a valid email';
      return null;
    }

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final empty = required(value, field: 'Password');
    if (empty != null) return empty;
    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final empty = required(value, field: 'Confirm password');
    if (empty != null) return empty;
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
