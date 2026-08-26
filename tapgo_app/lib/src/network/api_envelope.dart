import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Parses Laravel `{ success, message, data, meta, errors, code }` envelopes.
abstract final class ApiEnvelope {
  static dynamic dataOf(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) return body;
    final map = Map<String, dynamic>.from(body);
    if (map['success'] == false) {
      throw ApiException(
        map['message']?.toString() ?? 'Request failed',
        statusCode: response.statusCode,
        code: map['code']?.toString(),
        errors: map['errors'] is Map
            ? Map<String, dynamic>.from(map['errors'] as Map)
            : null,
      );
    }
    return map.containsKey('data') ? map['data'] : map;
  }

  static Map<String, dynamic> mapOf(Response<dynamic> response) {
    final data = dataOf(response);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Unexpected response shape');
  }

  static List<Map<String, dynamic>> listOf(Response<dynamic> response) {
    final data = dataOf(response);
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Map<String, dynamic>? metaOf(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) return null;
    final meta = body['meta'];
    if (meta is Map) return Map<String, dynamic>.from(meta);
    return null;
  }

  static ApiException fromDio(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return ApiException(
        error.message ?? 'Connection failed',
        isOffline: true,
        statusCode: error.response?.statusCode,
      );
    }

    final response = error.response;
    final body = response?.data;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      return ApiException(
        map['message']?.toString() ?? error.message ?? 'Request failed',
        statusCode: response?.statusCode,
        code: map['code']?.toString(),
        errors: map['errors'] is Map
            ? Map<String, dynamic>.from(map['errors'] as Map)
            : null,
      );
    }

    return ApiException(
      error.message ?? 'Request failed',
      statusCode: response?.statusCode,
    );
  }
}
