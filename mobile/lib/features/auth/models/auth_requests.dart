/// Credentials for email/phone login.
class LoginRequest {
  const LoginRequest({required this.identifier, required this.password});

  /// Email or phone number.
  final String identifier;
  final String password;

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'password': password,
      };
}

/// Payload for Create Account.
class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.identifier,
    required this.password,
  });

  final String name;
  final String identifier;
  final String password;

  Map<String, dynamic> toJson() {
    final isPhone = !identifier.contains('@');
    return {
      'name': name,
      if (isPhone) 'phone': identifier else 'email': identifier,
      'password': password,
      'password_confirmation': password,
    };
  }
}

/// Forgot-password request.
class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.identifier});

  final String identifier;

  Map<String, dynamic> toJson() => {'email': identifier};
}

/// Reset / new-password request.
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.identifier,
    required this.password,
    required this.passwordConfirmation,
    this.token,
  });

  final String identifier;
  final String password;
  final String passwordConfirmation;
  final String? token;

  Map<String, dynamic> toJson() => {
    'email': identifier,
    'password': password,
    'password_confirmation': passwordConfirmation,
    if (token != null) 'token': token,
  };
}

/// Supported social providers from the Kutuku kit.
enum AuthSocialProvider { google, facebook }
