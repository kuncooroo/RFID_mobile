import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/experience.dart';

class ExperienceRepository {
  ExperienceRepository({required ApiClient api, required Dio dio})
    : _api = api,
      _dio = dio;

  final ApiClient _api;
  final Dio _dio;

  Future<List<GateExperience>> list() {
    return _api.get<List<GateExperience>>(
      ApiEndpoints.experiences,
      parser: (data) {
        final rows = data is List ? data : const [];
        return [
          for (final row in rows)
            if (row is Map)
              GateExperience.fromJson(Map<String, dynamic>.from(row)),
        ];
      },
    );
  }

  Future<Uint8List?> photo(int id) async {
    final response = await _api.raw(
      () => _dio.get<List<int>>(
        ApiEndpoints.experiencePhoto(id),
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'image/jpeg'},
        ),
      ),
    );
    final data = response.data;
    if (data is List<int>) return Uint8List.fromList(data);
    return null;
  }

  /// Exchanges [points] for checkout discount credit. Rate is server-side.
  Future<void> redeemPoints(int points) {
    return _api.post<void>(
      ApiEndpoints.redeemPoints,
      data: {'points': points},
      parser: (_) {},
    );
  }
}
