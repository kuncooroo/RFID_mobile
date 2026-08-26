import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src/network/api_client.dart';
import '../models/rfid_verification.dart';
import '../repository/mock_rfid_repository.dart';
import '../repository/remote_rfid_repository.dart';
import '../repository/rfid_repository.dart';
import '../state/rfid_scan_state.dart';

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

  /// Step 1 → Step 2: open camera viewfinder and wait for a real RFID tap.
  void getStarted() {
    state = state.copyWith(
      step: FaceVerifyStep.holdStill,
      progress: 0,
      isSubmitting: false,
      clearError: true,
      clearRfid: true,
      clearMember: true,
      clearCapturedImage: true,
    );
  }

  /// Called only after USB RFID reader finishes a scan (Enter key).
  void setRfidUid(String uid) {
    final cleaned = uid.trim();
    if (cleaned.isEmpty || state.step != FaceVerifyStep.holdStill) return;

    state = state.copyWith(
      rfidUid: cleaned,
      memberId: cleaned,
      progress: 0.45,
      clearError: true,
    );
  }

  /// Capture face snapshot path + submit verification (Capture & Save).
  Future<void> captureAndSave({
    required String imagePath,
    required String rfidUid,
  }) async {
    if (state.step != FaceVerifyStep.holdStill || state.isSubmitting) return;

    final cleanedUid = rfidUid.trim();
    if (cleanedUid.isEmpty || imagePath.trim().isEmpty) return;

    state = state.copyWith(
      isSubmitting: true,
      progress: 0.7,
      rfidUid: cleanedUid,
      memberId: cleanedUid,
      capturedImagePath: imagePath,
      clearError: true,
    );

    try {
      final result = await ref.read(rfidRepositoryProvider).submitVerification(
            RfidVerificationRequest(
              memberId: cleanedUid,
              timestamp: DateTime.now(),
              capturedImagePath: imagePath,
            ),
          );

      if (!result.gateOpened) {
        state = state.copyWith(
          step: FaceVerifyStep.failure,
          isSubmitting: false,
          errorMessage: result.message,
          memberId: cleanedUid,
          capturedImagePath: imagePath,
        );
        return;
      }

      state = state.copyWith(
        step: FaceVerifyStep.success,
        progress: 1,
        isSubmitting: false,
        memberId: cleanedUid,
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
