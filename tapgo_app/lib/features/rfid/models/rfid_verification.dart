/// RFID member verification payload sent to admin / gate system.
class RfidVerificationRequest {
  const RfidVerificationRequest({
    required this.memberId,
    required this.timestamp,
    required this.capturedImagePath,
  });

  final String memberId;
  final DateTime timestamp;
  final String capturedImagePath;

  Map<String, dynamic> toJson() => {
        'member_id': memberId,
        'timestamp': timestamp.toIso8601String(),
        'captured_image_path': capturedImagePath,
      };
}

/// Result of a successful RFID + face verification.
class RfidVerificationResult {
  const RfidVerificationResult({
    required this.memberId,
    required this.gateOpened,
    this.message = 'Verification Successful! Gate Opening. Happy Shopping!',
  });

  final String memberId;
  final bool gateOpened;
  final String message;
}
