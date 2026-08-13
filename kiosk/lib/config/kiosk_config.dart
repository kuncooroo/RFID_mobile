/// Runtime config for the field kiosk receiver.
abstract final class KioskConfig {
  /// Laravel API base including `/api/v1`.
  ///
  /// Example:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.2:8000/api/v1`
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// Optional shared secret (must match backend KIOSK_API_KEY when set).
  static const apiKey = String.fromEnvironment('KIOSK_API_KEY');

  static const verifyPath = '/kiosk/verify';
  static const uploadPath = '/kiosk/upload-photo';

  static const countdownSeconds = 3;
  static const previewHold = Duration(seconds: 3);
  static const errorHold = Duration(seconds: 3);
}
