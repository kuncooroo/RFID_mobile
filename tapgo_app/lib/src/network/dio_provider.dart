import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/auth_session.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseOptions = BaseOptions(
    baseUrl: AppConfig.resolvedApiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    sendTimeout: AppConfig.sendTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: const {
      'Accept': Headers.jsonContentType,
    },
  );

  final dio = Dio(baseOptions);

  // Dedicated client for token refresh + single request retry (no interceptors).
  final refreshDio = Dio(baseOptions);

  dio.interceptors.add(RetryInterceptor(dio));
  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.watch(secureStorageServiceProvider),
      refreshDio: refreshDio,
      onSessionExpired: () {
        ref
            .read(authSessionProvider.notifier)
            .markUnauthenticated(hasSeenOnboarding: true);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    );
  }

  ref.onDispose(() {
    dio.close(force: true);
    refreshDio.close(force: true);
  });
  return dio;
});
