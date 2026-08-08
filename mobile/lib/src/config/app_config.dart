import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  /// Laravel API base including `/api/v1`.
  ///
  /// Pass explicitly:
  /// `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1`
  ///
  /// Release builds require an explicit HTTPS base URL.
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get resolvedApiBaseUrl {
    if (apiBaseUrl.isNotEmpty) return apiBaseUrl;
    assert(
      !kReleaseMode,
      'API_BASE_URL must be provided in release builds via --dart-define.',
    );
    // Debug-only emulator default (cleartext HTTP).
    return 'http://10.0.2.2:8000/api/v1';
  }

  static const allowRuntimeFontFetching = bool.fromEnvironment(
    'ALLOW_RUNTIME_FONT_FETCHING',
    defaultValue: !kReleaseMode,
  );

  static const connectTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);

  static const maxRetries = 2;
  static const retryBaseDelay = Duration(milliseconds: 400);
}
