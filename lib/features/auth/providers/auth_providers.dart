import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_session.dart';
import '../../../src/storage/secure_storage_service.dart';
import '../models/auth_exception.dart';
import '../models/auth_requests.dart';
import '../models/auth_result.dart';
import '../models/user.dart';
import '../repository/auth_repository.dart';
import '../repository/local_auth_repository.dart';
import '../repository/mock_auth_repository.dart';
import '../state/auth_form_state.dart';

/// Use mock repository when `true` (tests / UI demos).
///
/// Pass `--dart-define=USE_MOCK_AUTH=true` to enable.
const bool kUseMockAuthRepository = bool.fromEnvironment(
  'USE_MOCK_AUTH',
  defaultValue: false,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (kUseMockAuthRepository) {
    return MockAuthRepository();
  }
  return LocalAuthRepository(storage: ref.watch(secureStorageServiceProvider));
});

final currentUserProvider = FutureProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser();
});

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);

final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );

final resetPasswordControllerProvider =
    NotifierProvider<ResetPasswordController, ResetPasswordState>(
      ResetPasswordController.new,
    );

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

void _applyAuthenticatedSession(Ref ref) {
  ref
      .read(authSessionProvider.notifier)
      .markAuthenticated(hasSeenOnboarding: true);
}

String _messageOf(Object error) {
  if (error is AuthException) return error.message;
  return error.toString();
}

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      ref
          .read(authSessionProvider.notifier)
          .markUnauthenticated(hasSeenOnboarding: true);
    });
  }

  Future<AuthResult> loginWithSocial(AuthSocialProvider provider) async {
    final result = await ref
        .read(authRepositoryProvider)
        .loginWithSocial(provider);
    _applyAuthenticatedSession(ref);
    ref.invalidate(currentUserProvider);
    return result;
  }
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<bool> submit({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthFormStatus.submitting, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(identifier: identifier, password: password));
      _applyAuthenticatedSession(ref);
      ref.invalidate(currentUserProvider);
      state = state.copyWith(status: AuthFormStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: _messageOf(error),
      );
      return false;
    }
  }

  Future<bool> submitSocial(AuthSocialProvider provider) async {
    state = state.copyWith(status: AuthFormStatus.submitting, clearError: true);
    try {
      await ref.read(authControllerProvider.notifier).loginWithSocial(provider);
      state = state.copyWith(status: AuthFormStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: _messageOf(error),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, status: AuthFormStatus.idle);
  }
}

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  Future<bool> submit({
    required String name,
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthFormStatus.submitting, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            RegisterRequest(
              name: name,
              identifier: identifier,
              password: password,
            ),
          );
      state = state.copyWith(status: AuthFormStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: _messageOf(error),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, status: AuthFormStatus.idle);
  }
}

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> submit({required String identifier}) async {
    state = state.copyWith(status: AuthFormStatus.submitting, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .forgotPassword(ForgotPasswordRequest(identifier: identifier));
      state = state.copyWith(
        status: AuthFormStatus.success,
        submittedIdentifier: identifier.trim(),
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: _messageOf(error),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, status: AuthFormStatus.idle);
  }
}

class ResetPasswordController extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  Future<bool> submit({
    required String identifier,
    required String password,
    required String passwordConfirmation,
    String? token,
  }) async {
    state = state.copyWith(status: AuthFormStatus.submitting, clearError: true);

    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            ResetPasswordRequest(
              identifier: identifier,
              password: password,
              passwordConfirmation: passwordConfirmation,
              token: token,
            ),
          );
      state = state.copyWith(status: AuthFormStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthFormStatus.failure,
        errorMessage: _messageOf(error),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true, status: AuthFormStatus.idle);
  }
}
