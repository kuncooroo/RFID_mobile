import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../config/kiosk_config.dart';
import '../models/kiosk_member.dart';

class KioskApiException implements Exception {
  KioskApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

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

  Future<KioskMember> verify(String code) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        KioskConfig.verifyPath,
        data: {'code': code},
      );
      final body = response.data ?? {};
      if (body['success'] != true) {
        throw KioskApiException(
          body['message']?.toString() ?? 'Verifikasi gagal',
          statusCode: response.statusCode,
        );
      }
      final data = Map<String, dynamic>.from(body['data'] as Map);
      return KioskMember.fromJson(data);
    } on DioException catch (e) {
      throw KioskApiException(_messageFromDio(e), statusCode: e.response?.statusCode);
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
        );
      }
    } on DioException catch (e) {
      throw KioskApiException(_messageFromDio(e), statusCode: e.response?.statusCode);
    }
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Koneksi ke server gagal';
  }
}
