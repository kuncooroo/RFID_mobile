import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rfid_verification.dart';
import '../repository/mock_rfid_repository.dart';
import '../repository/rfid_repository.dart';
import '../state/rfid_scan_state.dart';
import '../../../src/network/api_client.dart';
import '../repository/remote_rfid_repository.dart';

const bool kUseMockRfidRepository = bool.fromEnvironment(
  'USE_MOCK_RFID',
  defaultValue: false,
);

final rfidRepositoryProvider = Provider<RfidRepository>((ref) {
  if (kUseMockRfidRepository) {
    return MockRfidRepository();
  }
  return RemoteRfidRepository(api: ref.watch(apiClientProvider));
});

final rfidScanControllerProvider =
    NotifierProvider<RfidScanController, RfidScanState>(
  RfidScanController.new,
);

class RfidScanController extends Notifier<RfidScanState> {
  @override
  RfidScanState build() {
    return const RfidScanState();
  }

  void reset() {
    state = const RfidScanState();
  }

  /// Step 1 → Step 2: open camera viewfinder and wait for RFID tap.
  Future<void> getStarted() async {
    state = state.copyWith(
      step: FaceVerifyStep.holdStill,
      progress: 0,
      isSubmitting: false,
      clearError: true,
      clearRfid: true,
    );
    unawaited(_resolveMemberId());
  }

  Future<void> _resolveMemberId() async {
    try {
      final uid = await ref.read(rfidRepositoryProvider).waitForCardTap(
            timeout: const Duration(seconds: 8),
          );
      if (state.step != FaceVerifyStep.holdStill) return;
      state = state.copyWith(
        rfidUid: uid,
        memberId: uid,
        progress: 0.45,
      );
    } catch (_) {
      if (state.step != FaceVerifyStep.holdStill) return;
      state = state.copyWith(
        errorMessage: 'RFID card was not detected. Please try again.',
      );
    }
  }

  /// Capture face snapshot and submit verification (Capture & Save).
  Future<void> captureAndSave() async {
    if (!state.canCapture) return;

    state = state.copyWith(
      isSubmitting: true,
      progress: 0.7,
      clearError: true,
    );

    try {
      final repo = ref.read(rfidRepositoryProvider);
      final memberId = state.memberId ?? state.rfidUid;
      if (memberId == null || memberId.isEmpty) {
        state = state.copyWith(
          step: FaceVerifyStep.failure,
          isSubmitting: false,
          errorMessage: 'RFID card was not detected. Please try again.',
        );
        return;
      }

      final imagePath = await repo.captureFaceSnapshot();
      state = state.copyWith(progress: 0.9, capturedImagePath: imagePath);

      final result = await repo.submitVerification(
        RfidVerificationRequest(
          memberId: memberId,
          timestamp: DateTime.now(),
          capturedImagePath: imagePath,
        ),
      );

      if (!result.gateOpened) {
        state = state.copyWith(
          step: FaceVerifyStep.failure,
          isSubmitting: false,
          errorMessage: result.message,
          memberId: memberId,
          capturedImagePath: imagePath,
        );
        return;
      }

      state = state.copyWith(
        step: FaceVerifyStep.success,
        progress: 1,
        isSubmitting: false,
        memberId: memberId,
        capturedImagePath: imagePath,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        step: FaceVerifyStep.failure,
        isSubmitting: false,
        errorMessage: error.toString(),
      );
    }
  }
}
