import 'dart:io';

import 'package:dio/dio.dart';

import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/rfid_verification.dart';
import 'mock_rfid_repository.dart';
import 'rfid_repository.dart';

/// Hardware tap/capture stays local/simulated; verification hits Laravel.
class RemoteRfidRepository implements RfidRepository {
  RemoteRfidRepository({
    required ApiClient api,
    RfidRepository? hardware,
  }) : _api = api,
       _hardware = hardware ?? MockRfidRepository();

  final ApiClient _api;
  final RfidRepository _hardware;

  @override
  Future<String> waitForCardTap({
    Duration timeout = const Duration(seconds: 8),
  }) {
    return _hardware.waitForCardTap(timeout: timeout);
  }

  @override
  Future<String> captureFaceSnapshot() {
    return _hardware.captureFaceSnapshot();
  }

  @override
  Future<RfidVerificationResult> submitVerification(
    RfidVerificationRequest request,
  ) async {
    final hasFile =
        request.capturedImagePath.isNotEmpty &&
        File(request.capturedImagePath).existsSync();

    final Object payload;
    if (hasFile) {
      payload = FormData.fromMap({
        'member_id': request.memberId,
        'timestamp': request.timestamp.toIso8601String(),
        'captured_image': await MultipartFile.fromFile(
          request.capturedImagePath,
          filename: 'capture.jpg',
        ),
      });
    } else {
      payload = {
        'member_id': request.memberId,
        'timestamp': request.timestamp.toIso8601String(),
      };
    }

    final data = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.rfidVerify,
      data: payload,
      parser: (d) =>
          d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{},
    );

    return RfidVerificationResult(
      memberId: data['member_id']?.toString() ?? request.memberId,
      gateOpened: data['gate_opened'] as bool? ?? false,
      message:
          data['message']?.toString() ??
          'Verification Successful! Gate Opening. Happy Shopping!',
    );
  }
}
