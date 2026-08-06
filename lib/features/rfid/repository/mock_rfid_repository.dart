import '../models/rfid_verification.dart';
import 'rfid_repository.dart';

/// Local / demo RFID repository — simulates NFC tap, capture, and API save.
class MockRfidRepository implements RfidRepository {
  MockRfidRepository({
    this.demoMemberId = 'ID-MB-2026-00192',
    this.detectDelay = const Duration(milliseconds: 900),
    this.verifyDelay = const Duration(milliseconds: 500),
  });

  final String demoMemberId;
  final Duration detectDelay;
  final Duration verifyDelay;

  @override
  Future<String> waitForCardTap({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    await Future<void>.delayed(detectDelay);
    return demoMemberId;
  }

  @override
  Future<String> captureFaceSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return '/simulated/captures/rfid_face_$stamp.jpg';
  }

  @override
  Future<RfidVerificationResult> submitVerification(
    RfidVerificationRequest request,
  ) async {
    await Future<void>.delayed(verifyDelay);
    return RfidVerificationResult(
      memberId: request.memberId,
      gateOpened: true,
    );
  }
}
