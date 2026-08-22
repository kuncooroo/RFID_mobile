import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../config/kiosk_config.dart';
import '../models/kiosk_member.dart';
import '../models/presence.dart';

class KioskApiException implements Exception {
  KioskApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class KioskApi {
  KioskApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: KioskConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                  if (KioskConfig.apiKey.isNotEmpty)
                    'X-Kiosk-Key': KioskConfig.apiKey,
                },
              ),
            );

  final Dio _dio;

  Future<void> health() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        KioskConfig.healthPath,
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Backend tidak siap',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<RfidLookup> lookupRfid(String uid) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.rfidVerifyPath,
        data: {'rfid_uid': uid},
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Verifikasi kartu gagal',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
      final data = Map<String, dynamic>.from(body['data'] as Map);
      return RfidLookup.fromJson(
        data,
        message: body['message']?.toString(),
      );
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<RfidLookup> registerVisitor({
    required String rfidUid,
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.registerPath,
        data: {
          'rfid_uid': rfidUid,
          'name': name,
          if (email != null && email.isNotEmpty) 'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Registrasi gagal',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
      final data = Map<String, dynamic>.from(body['data'] as Map);
      return RfidLookup.fromJson(
        data,
        message: body['message']?.toString(),
      );
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<void> enrollFace({
    required String rfidUid,
    required List<int> front,
    required List<int> right,
    required List<int> left,
  }) async {
    try {
      final form = FormData.fromMap({
        'rfid_uid': rfidUid,
        'front': MultipartFile.fromBytes(
          front,
          filename: 'front.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
        'right': MultipartFile.fromBytes(
          right,
          filename: 'right.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
        'left': MultipartFile.fromBytes(
          left,
          filename: 'left.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.faceEnrollmentPath,
        data: form,
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Face enrollment gagal',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<CheckInRecord> recordVisit({
    required String rfidUid,
    String? deviceId,
    int? locationId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.visitPath,
        data: {
          'rfid_uid': rfidUid,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
          if (locationId != null && locationId > 0) 'location_id': locationId,
        },
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Kunjungan gagal',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
      return CheckInRecord.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<void> uploadPhoto({
    required String code,
    required int userId,
    required List<int> bytes,
    String filename = 'kiosk_capture.jpg',
  }) async {
    try {
      final form = FormData.fromMap({
        'code': code,
        'rfid_uid': code,
        'user_id': userId,
        'photo': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.uploadPath,
        data: form,
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Upload gagal',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<PresenceRecord> recordPresence({
    required String rfidUid,
    required List<int> bytes,
    String? deviceId,
    int? locationId,
    String filename = 'presence.jpg',
  }) async {
    try {
      final form = FormData.fromMap({
        'rfid_uid': rfidUid,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        if (locationId != null && locationId > 0) 'location_id': locationId,
        'captured_at': DateTime.now().toUtc().toIso8601String(),
        'photo': MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.presencePath,
        data: form,
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Presence gagal dicatat',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
      return PresenceRecord.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  Future<CheckInRecord> checkIn({
    required int presenceId,
    required String rfidUid,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.checkInPath,
        data: {
          'presence_id': presenceId,
          'rfid_uid': rfidUid,
        },
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Check-in gagal',
          statusCode: response.statusCode,
          code: body['code']?.toString(),
        );
      }
      return CheckInRecord.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (e) {
      throw KioskApiException(
        _messageFromDio(e),
        statusCode: e.response?.statusCode,
        code: _codeFromDio(e),
      );
    }
  }

  String? _codeFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['code'] != null) {
      return data['code'].toString();
    }
    return null;
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Koneksi ke server habis waktu. Coba lagi.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server.';
    }
    return e.message ?? 'Koneksi ke server gagal';
  }
}
