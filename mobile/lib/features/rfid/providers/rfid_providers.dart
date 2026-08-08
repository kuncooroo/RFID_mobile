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
  Timer? _progressTimer;

  @override
  RfidScanState build() {
    ref.onDispose(() => _progressTimer?.cancel());
    return const RfidScanState();
  }

  void reset() {
    _progressTimer?.cancel();
    state = const RfidScanState();
  }

  /// Step 1 → Step 2: begin face scan + RFID member resolve in parallel.
  Future<void> getStarted() async {
    _progressTimer?.cancel();
    state = state.copyWith(
      step: FaceVerifyStep.holdStill,
      progress: 0,
      clearError: true,
    );

    // Resolve member id in the background (NFC / RFID simulation).
    unawaited(_resolveMemberId());

    // Animate hold-still progress, then submit verification.
    const tick = Duration(milliseconds: 50);
    const total = Duration(milliseconds: 2800);
    final steps = total.inMilliseconds / tick.inMilliseconds;
    var i = 0;

    _progressTimer = Timer.periodic(tick, (timer) async {
      i++;
      final next = (i / steps).clamp(0.0, 1.0);
      state = state.copyWith(progress: next);
      if (next < 1) return;

      timer.cancel();
      await _finishVerification();
    });
  }

  Future<void> _resolveMemberId() async {
    try {
      final memberId = await ref.read(rfidRepositoryProvider).waitForCardTap(
            timeout: const Duration(seconds: 3),
          );
      if (state.step != FaceVerifyStep.holdStill) return;
      state = state.copyWith(memberId: memberId);
    } catch (_) {
      // Keep scanning; member id falls back at submit time.
    }
  }

  Future<void> _finishVerification() async {
    try {
      final repo = ref.read(rfidRepositoryProvider);
      final memberId = state.memberId;
      if (memberId == null || memberId.isEmpty) {
        state = state.copyWith(
          step: FaceVerifyStep.failure,
          errorMessage: 'RFID card was not detected. Please try again.',
        );
        return;
      }
      final imagePath = await repo.captureFaceSnapshot();
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
          errorMessage: result.message,
          memberId: memberId,
          capturedImagePath: imagePath,
        );
        return;
      }
      state = state.copyWith(
        step: FaceVerifyStep.success,
        progress: 1,
        memberId: memberId,
        capturedImagePath: imagePath,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        step: FaceVerifyStep.failure,
        errorMessage: error.toString(),
      );
    }
  }
}
