import 'dart:convert';

import '../../../src/storage/secure_storage_service.dart';
import '../models/auth_exception.dart';
import '../models/auth_requests.dart';
import '../models/auth_result.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';
import 'auth_repository.dart';

/// Local auth stand-in until Laravel Sanctum endpoints are wired.
///
/// Persists tokens + cached user in secure storage so splash can restore
/// an authenticated session.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({
    required SecureStorageService storage,
    this.delay = const Duration(milliseconds: 400),
  }) : _storage = storage;

  static const _userKey = 'auth_user';

  final SecureStorageService _storage;
  final Duration delay;

  @override
  Future<AuthResult> login(LoginRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);

    final existing = await currentUser();
    final user =
        existing?.email.toLowerCase() == request.identifier.trim().toLowerCase()
        ? existing!
        : User(
            id: 'local-${request.identifier.hashCode.abs()}',
            name: existing?.name ?? 'Member',
            email: request.identifier.trim(),
            phone: _looksLikePhone(request.identifier)
                ? request.identifier.trim()
                : null,
          );

    return _persist(user);
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureName(request.name);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);

    final user = User(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: request.name.trim(),
      email: request.identifier.trim(),
      phone: _looksLikePhone(request.identifier)
          ? request.identifier.trim()
          : null,
      createdAt: DateTime.now(),
    );

    // Persist credentials for later login, but do not imply an active session
    // until the controller decides to authenticate (Kutuku: success → login).
    await _storage.write(_userKey, jsonEncode(user.toJson()));
    return AuthResult(
      user: user,
      tokens: AuthTokens(accessToken: 'pending-${user.id}', refreshToken: null),
    );
  }

  @override
  Future<AuthResult> loginWithSocial(AuthSocialProvider provider) async {
    await Future<void>.delayed(delay);
    final label = provider == AuthSocialProvider.google ? 'Google' : 'Facebook';
    final user = User(
      id: 'local-${provider.name}',
      name: '$label User',
      email: '${provider.name}@kutuku.app',
    );
    return _persist(user);
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureIdentifier(request.identifier);
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await Future<void>.delayed(delay);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);
    AuthCredentialRules.ensurePasswordMatch(
      request.password,
      request.passwordConfirmation,
    );
  }

  @override
  Future<void> logout() async {
    await _storage.delete(SecureStorageKeys.accessToken);
    await _storage.delete(SecureStorageKeys.refreshToken);
  }

  @override
  Future<User?> currentUser() async {
    final raw = await _storage.read(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const AuthException('Saved profile is corrupted');
    }
  }

  Future<AuthResult> _persist(User user) async {
    final tokens = AuthTokens(
      accessToken: 'local-token-${user.id}',
      refreshToken: 'local-refresh-${user.id}',
    );
    await _storage.write(SecureStorageKeys.accessToken, tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _storage.write(
        SecureStorageKeys.refreshToken,
        tokens.refreshToken!,
      );
    }
    await _storage.write(_userKey, jsonEncode(user.toJson()));
    await _storage.write(SecureStorageKeys.hasSeenOnboarding, 'true');
    return AuthResult(user: user, tokens: tokens);
  }

  bool _looksLikePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8 && !value.contains('@');
  }
}
