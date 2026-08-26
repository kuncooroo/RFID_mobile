enum FaceVerifyStep {
  getStarted,
  holdStill,
  success,
  failure,
}

class RfidScanState {
  const RfidScanState({
    this.step = FaceVerifyStep.getStarted,
    this.progress = 0,
    this.memberId,
    this.rfidUid,
    this.capturedImagePath,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final FaceVerifyStep step;
  final double progress;
  final String? memberId;
  /// Raw RFID UID shown on the camera badge after a successful tap.
  final String? rfidUid;
  final String? capturedImagePath;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isScanning => step == FaceVerifyStep.holdStill;
  bool get isSuccess => step == FaceVerifyStep.success;
  bool get hasRfid => rfidUid != null && rfidUid!.trim().isNotEmpty;
  bool get canCapture =>
      step == FaceVerifyStep.holdStill && hasRfid && !isSubmitting;

  RfidScanState copyWith({
    FaceVerifyStep? step,
    double? progress,
    String? memberId,
    String? rfidUid,
    String? capturedImagePath,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool clearRfid = false,
    bool clearMember = false,
    bool clearCapturedImage = false,
  }) {
    return RfidScanState(
      step: step ?? this.step,
      progress: progress ?? this.progress,
      memberId: clearMember ? null : (memberId ?? this.memberId),
      rfidUid: clearRfid ? null : (rfidUid ?? this.rfidUid),
      capturedImagePath: clearCapturedImage
          ? null
          : (capturedImagePath ?? this.capturedImagePath),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
