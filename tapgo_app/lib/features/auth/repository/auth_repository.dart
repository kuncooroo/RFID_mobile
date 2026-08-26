import '../models/auth_exception.dart';
import '../models/auth_requests.dart';
import '../models/auth_result.dart';
import '../models/user.dart';

/// Contract for Sanctum auth operations.
abstract class AuthRepository {
  Future<AuthResult> login(LoginRequest request);

  Future<AuthResult> register(RegisterRequest request);

  Future<AuthResult> loginWithSocial(AuthSocialProvider provider);

  Future<void> forgotPassword(ForgotPasswordRequest request);

  Future<void> resetPassword(ResetPasswordRequest request);

  Future<void> logout();

  Future<User?> currentUser();
}

/// Shared credential checks used by local/mock repositories.
abstract final class AuthCredentialRules {
  static void ensureIdentifier(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const AuthException('Email or phone is required');
    }
  }

  static void ensurePassword(String value, {int minLength = 6}) {
    if (value.length < minLength) {
      throw AuthException('Password must be at least $minLength characters');
    }
  }

  static void ensureName(String value) {
    if (value.trim().isEmpty) {
      throw const AuthException('Name is required');
    }
  }

  static void ensurePasswordMatch(String password, String confirmation) {
    if (password != confirmation) {
      throw const AuthException('Passwords do not match');
    }
  }
}
