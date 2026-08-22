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

  static const healthPath = '/kiosk/health';
  static const rfidVerifyPath = '/kiosk/rfid/verify';
  static const verifyPath = '/kiosk/verify';
  static const registerPath = '/kiosk/register';
  static const faceEnrollmentPath = '/kiosk/face-enrollment';
  static const visitPath = '/kiosk/visit';
  static const uploadPath = '/kiosk/upload-photo';
  static const presencePath = '/kiosk/presence';
  static const checkInPath = '/kiosk/check-in';

  static const locationId = int.fromEnvironment('LOCATION_ID', defaultValue: 0);
  static const deviceId = String.fromEnvironment(
    'DEVICE_ID',
    defaultValue: 'kiosk-main',
  );

  static const countdownSeconds = 3;
  static const memberFoundHold = Duration(milliseconds: 1400);
  static const healthPoll = Duration(seconds: 12);
  static const previewHold = Duration(seconds: 3);
  static const errorHold = Duration(seconds: 4);
  static const successHold = Duration(seconds: 8);
  static const lookupTimeout = Duration(seconds: 20);
  static const sessionTimeout = Duration(seconds: 90);
  static const timeoutHold = Duration(seconds: 5);
}
