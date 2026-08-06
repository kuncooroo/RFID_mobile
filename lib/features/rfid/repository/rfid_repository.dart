import '../models/rfid_verification.dart';

/// RFID scan + face verification repository contract.
abstract class RfidRepository {
  /// Waits for (or simulates) an RFID card tap and returns the member id.
  Future<String> waitForCardTap({Duration timeout = const Duration(seconds: 8)});

  /// Captures a face snapshot path (camera or simulated file path).
  Future<String> captureFaceSnapshot();

  /// Sends verification payload to admin / gate backend.
  Future<RfidVerificationResult> submitVerification(
    RfidVerificationRequest request,
  );
}
