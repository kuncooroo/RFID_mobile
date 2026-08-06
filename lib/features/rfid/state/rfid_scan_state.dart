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
    this.capturedImagePath,
    this.errorMessage,
  });

  final FaceVerifyStep step;
  final double progress;
  final String? memberId;
  final String? capturedImagePath;
  final String? errorMessage;

  bool get isScanning => step == FaceVerifyStep.holdStill;
  bool get isSuccess => step == FaceVerifyStep.success;

  RfidScanState copyWith({
    FaceVerifyStep? step,
    double? progress,
    String? memberId,
    String? capturedImagePath,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RfidScanState(
      step: step ?? this.step,
      progress: progress ?? this.progress,
      memberId: memberId ?? this.memberId,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
