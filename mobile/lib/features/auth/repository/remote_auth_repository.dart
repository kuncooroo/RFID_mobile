import 'dart:convert';

import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../../src/network/api_exception.dart';
import '../../../src/storage/secure_storage_service.dart';
import '../models/auth_exception.dart';
import '../models/auth_requests.dart';
import '../models/auth_result.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';
import 'auth_repository.dart';

/// Laravel Sanctum-backed auth repository.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({
    required ApiClient api,
    required SecureStorageService storage,
  }) : _api = api,
       _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;

  static const _userKey = 'auth_user';

  @override
  Future<AuthResult> login(LoginRequest request) async {
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password);
    try {
      final data = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: request.toJson(),
        parser: _asMap,
      );
      final result = _parseAuthResult(data);
      await _persistSession(result);
      return result;
    } on ApiException catch (e) {
      throw AuthException(e.displayMessage);
    }
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    AuthCredentialRules.ensureName(request.name);
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password, minLength: 8);
    try {
      final data = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: request.toJson(),
        parser: _asMap,
      );
      final result = _parseAuthResult(data);
      await _persistSession(result);
      return result;
    } on ApiException catch (e) {
      throw AuthException(e.displayMessage);
    }
  }

  @override
  Future<AuthResult> loginWithSocial(AuthSocialProvider provider) async {
    throw const AuthException('Social login is not available yet');
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    AuthCredentialRules.ensureIdentifier(request.identifier);
    try {
      await _api.post<dynamic>(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );
    } on ApiException catch (e) {
      throw AuthException(e.displayMessage);
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    AuthCredentialRules.ensureIdentifier(request.identifier);
    AuthCredentialRules.ensurePassword(request.password, minLength: 8);
    AuthCredentialRules.ensurePasswordMatch(
      request.password,
      request.passwordConfirmation,
    );
    try {
      await _api.post<dynamic>(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );
    } on ApiException catch (e) {
      throw AuthException(e.displayMessage);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post<dynamic>(ApiEndpoints.logout);
    } on ApiException {
      // Still clear local session.
    } finally {
      await _storage.delete(SecureStorageKeys.accessToken);
      await _storage.delete(SecureStorageKeys.refreshToken);
      await _storage.delete(_userKey);
    }
  }

  @override
  Future<User?> currentUser() async {
    final token = await _storage.read(SecureStorageKeys.accessToken);
    if (token == null || token.isEmpty) return _cachedUser();

    try {
      final data = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.user,
        parser: _asMap,
      );
      final user = User.fromJson(data);
      await _storage.write(_userKey, jsonEncode(user.toJson()));
      return user;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _storage.delete(SecureStorageKeys.accessToken);
        await _storage.delete(SecureStorageKeys.refreshToken);
        await _storage.delete(_userKey);
        return null;
      }
      return _cachedUser();
    }
  }

  Future<User?> _cachedUser() async {
    final raw = await _storage.read(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSession(AuthResult result) async {
    await _storage.write(
      SecureStorageKeys.accessToken,
      result.tokens.accessToken,
    );
    final refresh = result.tokens.refreshToken ?? result.tokens.accessToken;
    await _storage.write(SecureStorageKeys.refreshToken, refresh);
    await _storage.write(_userKey, jsonEncode(result.user.toJson()));
  }

  AuthResult _parseAuthResult(Map<String, dynamic> data) {
    final userJson = data['user'];
    if (userJson is! Map) {
      throw const AuthException('Invalid auth response');
    }
    return AuthResult(
      user: User.fromJson(Map<String, dynamic>.from(userJson)),
      tokens: AuthTokens.fromJson(data),
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Unexpected response shape');
  }
}
