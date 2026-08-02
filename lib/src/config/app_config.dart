import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const allowRuntimeFontFetching = bool.fromEnvironment(
    'ALLOW_RUNTIME_FONT_FETCHING',
    defaultValue: !kReleaseMode,
  );

  static const connectTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
}
