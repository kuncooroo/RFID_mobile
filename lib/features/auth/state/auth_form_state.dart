/// Shared async status for auth form screens.
enum AuthFormStatus { idle, submitting, success, failure }

class LoginState {
  const LoginState({this.status = AuthFormStatus.idle, this.errorMessage});

  final AuthFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == AuthFormStatus.submitting;

  LoginState copyWith({
    AuthFormStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RegisterState {
  const RegisterState({this.status = AuthFormStatus.idle, this.errorMessage});

  final AuthFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == AuthFormStatus.submitting;

  RegisterState copyWith({
    AuthFormStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ForgotPasswordState {
  const ForgotPasswordState({
    this.status = AuthFormStatus.idle,
    this.errorMessage,
    this.submittedIdentifier,
  });

  final AuthFormStatus status;
  final String? errorMessage;
  final String? submittedIdentifier;

  bool get isSubmitting => status == AuthFormStatus.submitting;
  bool get isSuccess => status == AuthFormStatus.success;

  ForgotPasswordState copyWith({
    AuthFormStatus? status,
    String? errorMessage,
    String? submittedIdentifier,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submittedIdentifier: submittedIdentifier ?? this.submittedIdentifier,
    );
  }
}

class ResetPasswordState {
  const ResetPasswordState({
    this.status = AuthFormStatus.idle,
    this.errorMessage,
  });

  final AuthFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == AuthFormStatus.submitting;
  bool get isSuccess => status == AuthFormStatus.success;

  ResetPasswordState copyWith({
    AuthFormStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
