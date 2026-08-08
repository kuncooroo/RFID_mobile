import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

typedef OnSessionExpired = FutureOr<void> Function();

/// Attaches Bearer access token and refreshes once on HTTP 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required Dio refreshDio,
    this.onSessionExpired,
  }) : _storage = storage,
       _refreshDio = refreshDio;

  final SecureStorageService _storage;
  final Dio _refreshDio;
  final OnSessionExpired? onSessionExpired;

  static const _retriedKey = 'auth_retried';
  static const _authHeader = 'Authorization';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final isRefresh = path.contains(ApiEndpoints.refresh);

    if (!options.headers.containsKey(_authHeader)) {
      final token = await _storage.read(
        isRefresh
            ? SecureStorageKeys.refreshToken
            : SecureStorageKeys.accessToken,
      );
      if (token != null && token.isNotEmpty) {
        options.headers[_authHeader] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;
    final alreadyRetried = request.extra[_retriedKey] == true;
    final isAuthPath =
        request.path.contains(ApiEndpoints.login) ||
        request.path.contains(ApiEndpoints.register) ||
        request.path.contains(ApiEndpoints.refresh) ||
        request.path.contains(ApiEndpoints.forgotPassword) ||
        request.path.contains(ApiEndpoints.resetPassword);

    if (response?.statusCode != 401 || alreadyRetried || isAuthPath) {
      handler.next(err);
      return;
    }

    try {
      final refreshToken = await _storage.read(SecureStorageKeys.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        await _expireSession();
        handler.next(err);
        return;
      }

      // Bare client — no auth/retry interceptors — avoids recursion.
      final refreshResponse = await _refreshDio.post(
        ApiEndpoints.refresh,
        options: Options(
          headers: {_authHeader: 'Bearer $refreshToken'},
        ),
      );

      final data = ApiEnvelope.mapOf(refreshResponse);
      final access =
          data['access_token'] as String? ?? data['token'] as String? ?? '';
      final refresh = data['refresh_token'] as String? ?? access;

      if (access.isEmpty) {
        await _expireSession();
        handler.next(err);
        return;
      }

      await _storage.write(SecureStorageKeys.accessToken, access);
      await _storage.write(SecureStorageKeys.refreshToken, refresh);

      final retryOptions = request.copyWith(
        headers: Map<String, dynamic>.from(request.headers)
          ..[_authHeader] = 'Bearer $access',
        extra: Map<String, dynamic>.from(request.extra)..[_retriedKey] = true,
      );

      final retryResponse = await _refreshDio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      await _expireSession();
      handler.next(refreshError);
    } on ApiException catch (_) {
      await _expireSession();
      handler.next(err);
    }
  }

  Future<void> _expireSession() async {
    await _storage.delete(SecureStorageKeys.accessToken);
    await _storage.delete(SecureStorageKeys.refreshToken);
    await onSessionExpired?.call();
  }
}
