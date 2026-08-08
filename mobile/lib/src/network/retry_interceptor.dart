import 'dart:math';

import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Retries idempotent / transient failures with exponential backoff.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = AppConfig.maxRetries,
    this.baseDelay = AppConfig.retryBaseDelay,
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  static const _retryCountKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final retryCount = (request.extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err) || retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    final delay = baseDelay * pow(2, retryCount).toInt();
    await Future<void>.delayed(delay);

    final next = request.copyWith(
      extra: Map<String, dynamic>.from(request.extra)
        ..[_retryCountKey] = retryCount + 1,
    );

    try {
      final response = await _dio.fetch(next);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    final isIdempotent =
        method == 'GET' || method == 'HEAD' || method == 'OPTIONS';
    if (!isIdempotent) return false;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode ?? 0;
        return code == 408 || code == 429 || code >= 500;
      default:
        return false;
    }
  }
}
