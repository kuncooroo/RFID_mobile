import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../config/kiosk_config.dart';
import '../l10n/kiosk_strings.dart';
import '../models/kiosk_member.dart';
import '../models/presence.dart';
import '../services/kiosk_api.dart';
import '../services/rfid_keyboard_buffer.dart';
import '../services/visit_service.dart';
import '../theme/app_colors.dart';
import '../widgets/kiosk_app_header.dart';
import 'idle_page.dart';
import 'photo_preview_page.dart';
import 'register_pages.dart';
import 'status_pages.dart';

enum KioskStep {
  idle,
  awaitingRfidVisit,
  awaitingRfidRegister,
  verifyingRfid,
  rfidUnregistered,
  registration,
  faceEnrollmentIntro,
  faceCapture,
  facePosePreview,
  faceReview,
  faceUploading,
  faceCompleted,
  visitCreating,
  visitSuccess,
  duplicateVisit,
  cameraError,
  sessionTimeout,
  offline,
  error,
  help,
}

const _enrollPoses = ['front', 'right', 'left'];

class KioskFlowPage extends StatefulWidget {
  const KioskFlowPage({super.key, required this.api});

  final KioskApi api;

  @override
  State<KioskFlowPage> createState() => _KioskFlowPageState();
}

class _KioskFlowPageState extends State<KioskFlowPage> {
  final _rfidFocus = FocusNode(debugLabel: 'kioskRfid');
  final _rfidBuffer = RfidKeyboardBuffer();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.front,
    autoStart: false,
  );

  late final VisitService _visits = VisitService(widget.api);
  Future<void> _cameraGate = Future<void>.value();

  KioskStep _step = KioskStep.idle;
  KioskLang _lang = KioskLang.en;
  String? _errorMessage;
  final bool _rfidReady = true;
  bool _serverOnline = true;
  bool _rfidLocked = false;
  bool _registerFlow = false;

  RfidLookup? _lookup;
  RegisterDraft? _draft;
  Uint8List? _photoBytes;
  CheckInRecord? _checkIn;

  int _enrollIndex = 0;
  final Map<String, Uint8List> _enrollPhotos = {};
  bool _enrollmentForExisting = false;

  CameraController? _cameraController;
  /// True for this capture session when using placeholder instead of hardware.
  bool _usingMockCamera = false;
  Timer? _countdownTimer;
  Timer? _healthTimer;
  Timer? _holdTimer;
  Timer? _sessionTimer;
  int _countdown = KioskConfig.countdownSeconds;

  KioskStrings get _s => KioskStrings(_lang);
  bool get _hardwareReady => _rfidReady && _serverOnline;
  bool get _awaitingRfid =>
      _step == KioskStep.awaitingRfidVisit ||
      _step == KioskStep.awaitingRfidRegister;
  bool get _listenRfid => _awaitingRfid && _hardwareReady && !_rfidLocked;
  bool get _onScanSurface => _awaitingRfid;

  String get _currentPose => _enrollPoses[_enrollIndex.clamp(0, 2)];

  (String, String) get _poseCopy {
    return switch (_currentPose) {
      'right' => (_s.turnFaceRight, _s.turnFaceRightBody),
      'left' => (_s.turnFaceLeft, _s.turnFaceLeftBody),
      _ => (_s.lookStraight, _s.lookStraightBody),
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rfidFocus.requestFocus();
      // RFID only listens after user chooses Tap Member Card / Register.
      _startHealthPoll();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _healthTimer?.cancel();
    _holdTimer?.cancel();
    _sessionTimer?.cancel();
    _rfidFocus.dispose();
    unawaited(_disposeCamera());
    _scannerController.dispose();
    super.dispose();
  }

  void _bumpSession() {
    _sessionTimer?.cancel();
    if (_step == KioskStep.idle ||
        _step == KioskStep.sessionTimeout ||
        _step == KioskStep.visitSuccess ||
        _step == KioskStep.faceCompleted ||
        _step == KioskStep.duplicateVisit) {
      return;
    }
    _sessionTimer = Timer(KioskConfig.sessionTimeout, _onSessionTimeout);
  }

  void _onSessionTimeout() {
    if (!mounted) return;
    unawaited(_timeoutSession());
  }

  Future<void> _timeoutSession() async {
    _countdownTimer?.cancel();
    _holdTimer?.cancel();
    await _disposeCamera();
    await _stopScannerFully();
    if (!mounted) return;
    setState(() {
      _step = KioskStep.sessionTimeout;
      _clearSessionFields();
    });
    _holdTimer = Timer(KioskConfig.timeoutHold, () {
      if (!mounted) return;
      unawaited(_goIdle());
    });
  }

  void _clearSessionFields() {
    _lookup = null;
    _draft = null;
    _photoBytes = null;
    _checkIn = null;
    _enrollIndex = 0;
    _enrollPhotos.clear();
    _errorMessage = null;
    _enrollmentForExisting = false;
    _registerFlow = false;
    _rfidLocked = false;
    _usingMockCamera = false;
    _countdown = KioskConfig.countdownSeconds;
  }

  /// Explicit dart-define, or auto on Flutter web debug (no webcam needed).
  bool get _preferMockCamera =>
      KioskConfig.mockCamera || (kDebugMode && kIsWeb);

  bool get _mockCaptureActive =>
      _usingMockCamera || KioskConfig.mockCamera;

  void _startHealthPoll() {
    _healthTimer?.cancel();
    unawaited(_pollHealth());
    _healthTimer = Timer.periodic(KioskConfig.healthPoll, (_) {
      unawaited(_pollHealth());
    });
  }

  Future<void> _pollHealth() async {
    try {
      await widget.api.health().timeout(const Duration(seconds: 6));
      if (!mounted) return;
      final wasOffline = !_serverOnline;
      setState(() => _serverOnline = true);
      if (wasOffline && _onScanSurface) {
        unawaited(_startScannerSafely());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _serverOnline = false);
      if (_onScanSurface) {
        unawaited(_stopScannerFully());
      }
    }
  }

  Future<T> _withCameraGate<T>(Future<T> Function() action) {
    final run = _cameraGate.then((_) => action());
    _cameraGate = run.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[kiosk] cameraGate $error\n$stackTrace');
      },
    );
    return run;
  }

  Future<void> _startScannerSafely() {
    return _withCameraGate(() async {
      if (!mounted || !_onScanSurface || !_hardwareReady) return;
      await _disposeCameraUnlocked();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted || !_onScanSurface || !_hardwareReady) return;
      try {
        await _scannerController.start();
      } catch (e) {
        debugPrint('[kiosk] scanner start failed: $e');
      }
    });
  }

  Future<void> _stopScannerFully() {
    return _withCameraGate(() async {
      try {
        await _scannerController.stop();
      } catch (e) {
        debugPrint('[kiosk] scanner stop failed: $e');
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
    });
  }

  void _onKey(KeyEvent event) {
    if (!_listenRfid) return;
    final code = _rfidBuffer.handleKeyEvent(event);
    if (code != null) {
      unawaited(_handleDetectedCode(code));
    }
  }

  void _onQrDetect(BarcodeCapture capture) {
    if (!_listenRfid) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;
      unawaited(_handleDetectedCode(raw));
      break;
    }
  }

  Future<void> _handleDetectedCode(String code) async {
    if (!_awaitingRfid || !_hardwareReady || _rfidLocked) return;
    _rfidLocked = true;
    final registerFlow = _registerFlow;
    setState(() {
      _step = KioskStep.verifyingRfid;
      _errorMessage = null;
    });
    _bumpSession();

    await WidgetsBinding.instance.endOfFrame;
    await _stopScannerFully();

    try {
      final lookup = await widget.api
          .lookupRfid(code)
          .timeout(KioskConfig.lookupTimeout);
      if (!mounted) return;

      switch (lookup.resultCode) {
        case RfidLookupCode.memberFound:
          setState(() => _lookup = lookup);
          if (registerFlow) {
            _showError(_s.cardAlreadyRegistered);
            return;
          }
          if (lookup.needsFaceEnrollment) {
            _enrollmentForExisting = true;
            setState(() => _step = KioskStep.faceEnrollmentIntro);
            _bumpSession();
          } else {
            unawaited(_recordVisit());
          }
        case RfidLookupCode.rfidNotRegistered:
          setState(() => _lookup = lookup);
          if (registerFlow) {
            setState(() => _step = KioskStep.registration);
            _bumpSession();
          } else {
            setState(() => _step = KioskStep.rfidUnregistered);
            _bumpSession();
          }
        case RfidLookupCode.rfidInactive:
          _showError(_s.rfidInactive);
        case RfidLookupCode.rfidInvalid:
          _showError(_s.rfidInvalid);
        case RfidLookupCode.serverError:
          _showError(_s.genericError);
      }
    } on TimeoutException {
      _showError(_s.lookupTimeout);
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _startVisitScan() async {
    if (!_serverOnline) {
      setState(() => _step = KioskStep.offline);
      return;
    }
    setState(() {
      _registerFlow = false;
      _lookup = null;
      _step = KioskStep.awaitingRfidVisit;
    });
    _bumpSession();
    await _startScannerSafely();
    _rfidFocus.requestFocus();
  }

  Future<void> _startRegisterRfidScan() async {
    if (!_serverOnline) {
      setState(() => _step = KioskStep.offline);
      return;
    }
    setState(() {
      _registerFlow = true;
      _step = KioskStep.awaitingRfidRegister;
    });
    _bumpSession();
    await _startScannerSafely();
    _rfidFocus.requestFocus();
  }

  void _beginEnrollment() {
    setState(() {
      _enrollIndex = 0;
      _enrollPhotos.clear();
      _photoBytes = null;
      _step = KioskStep.faceEnrollmentIntro;
    });
    _bumpSession();
  }

  String _customerMessage(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '');
    final lower = raw.toLowerCase();
    if (lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('dio') ||
        lower.contains('timed out') ||
        lower.contains('timeout') ||
        lower.contains('network')) {
      return _s.networkError;
    }
    if (raw.length > 140 ||
        lower.contains('stack') ||
        lower.contains('exception') ||
        lower.contains('error:')) {
      return _s.genericError;
    }
    return raw;
  }

  void _showError(String message, {bool camera = false}) {
    if (!mounted) return;
    _holdTimer?.cancel();
    setState(() {
      _errorMessage = message;
      _step = camera ? KioskStep.cameraError : KioskStep.error;
      _rfidLocked = false;
    });
    _bumpSession();
  }

  Future<void> _goIdle() async {
    _countdownTimer?.cancel();
    _holdTimer?.cancel();
    _sessionTimer?.cancel();
    await _disposeCamera();
    if (!mounted) return;
    setState(() {
      _step = KioskStep.idle;
      _clearSessionFields();
    });
    await _stopScannerFully();
    _rfidFocus.requestFocus();
  }

  Future<void> _retryFromError() async {
    if (_photoBytes != null && _lookup != null) {
      setState(() => _step = KioskStep.facePosePreview);
      _bumpSession();
      return;
    }
    if (_registerFlow && _lookup != null && !_lookup!.isRegistered) {
      setState(() => _step = KioskStep.registration);
      _bumpSession();
      return;
    }
    if (_registerFlow) {
      unawaited(_startRegisterRfidScan());
      return;
    }
    if (_lookup != null && _lookup!.isRegistered) {
      if (_lookup!.needsFaceEnrollment) {
        _beginEnrollment();
        return;
      }
      unawaited(_recordVisit());
      return;
    }
    if (_lookup != null && !_lookup!.isRegistered) {
      setState(() => _step = KioskStep.rfidUnregistered);
      _bumpSession();
      return;
    }
    await _goIdle();
  }

  Future<void> _recordVisit() async {
    final lookup = _lookup;
    if (lookup == null || !lookup.isRegistered) {
      _showError(_s.genericError);
      return;
    }

    setState(() => _step = KioskStep.visitCreating);
    _bumpSession();

    try {
      final checkIn = await _visits.recordVisit(rfidUid: lookup.rfidUid);
      if (!mounted) return;
      if (!checkIn.succeeded) {
        _showError(_s.checkInFailed);
        return;
      }

      setState(() => _checkIn = checkIn);

      if (checkIn.duplicate) {
        setState(() => _step = KioskStep.duplicateVisit);
        return;
      }

      setState(() => _step = KioskStep.visitSuccess);
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _cancelFaceCapture() async {
    _countdownTimer?.cancel();
    await _disposeCamera();
    if (!mounted) return;
    setState(() {
      _countdown = KioskConfig.countdownSeconds;
      _photoBytes = null;
      _usingMockCamera = false;
      _step = KioskStep.faceEnrollmentIntro;
    });
    _bumpSession();
  }

  void _armMockCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        unawaited(_snapPhoto());
      } else {
        setState(() => _countdown -= 1);
      }
    });
  }

  Future<void> _startMockCameraCapture({String? reason}) async {
    if (reason != null) {
      debugPrint('[kiosk] MOCK_CAMERA fallback: $reason');
    } else {
      debugPrint('[kiosk] MOCK_CAMERA: skipping hardware camera');
    }
    await _disposeCamera();
    if (!mounted) return;
    setState(() {
      _usingMockCamera = true;
      _cameraController = null;
      _countdown = KioskConfig.countdownSeconds;
      _step = KioskStep.faceCapture;
    });
    _armMockCountdown();
  }

  Future<void> _startCameraCapture() async {
    setState(() => _step = KioskStep.faceCapture);
    _bumpSession();

    if (_preferMockCamera) {
      await _startMockCameraCapture();
      return;
    }

    try {
      await _withCameraGate(() async {
        await _disposeCameraUnlocked();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          throw Exception('camera');
        }
        final preferred = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        final controller = CameraController(
          preferred,
          kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: kIsWeb ? null : ImageFormatGroup.jpeg,
        );
        await controller.initialize();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _usingMockCamera = false;
          _cameraController = controller;
          _countdown = KioskConfig.countdownSeconds;
        });
        _armMockCountdown();
      });
    } catch (e) {
      // Design/dev: keep flow usable when webcam fails.
      if (kDebugMode) {
        await _startMockCameraCapture(reason: e.toString());
        return;
      }
      _showError(_s.cameraUnavailableBody, camera: true);
    }
  }

  Future<Uint8List> _loadMockPhotoBytes() async {
    final data = await rootBundle.load(KioskConfig.mockCameraAsset);
    return data.buffer.asUint8List();
  }

  Future<void> _snapPhoto() async {
    setState(() => _countdown = 0);

    if (_mockCaptureActive) {
      try {
        final bytes = await _loadMockPhotoBytes();
        await _disposeCamera();
        if (!mounted) return;
        setState(() {
          _photoBytes = bytes;
          _step = KioskStep.facePosePreview;
        });
        _bumpSession();
      } catch (e) {
        debugPrint('[kiosk] MOCK_CAMERA photo load failed: $e');
        _showError(_s.cameraUnavailableBody, camera: true);
      }
      return;
    }

    final camera = _cameraController;
    if (camera == null || !camera.value.isInitialized) {
      if (kDebugMode) {
        await _startMockCameraCapture(reason: 'snap without ready camera');
        // Immediately produce mock photo for this tick.
        try {
          final bytes = await _loadMockPhotoBytes();
          if (!mounted) return;
          setState(() {
            _usingMockCamera = true;
            _photoBytes = bytes;
            _step = KioskStep.facePosePreview;
          });
          _bumpSession();
        } catch (_) {
          _showError(_s.cameraUnavailableBody, camera: true);
        }
        return;
      }
      _showError(_s.cameraUnavailableBody, camera: true);
      return;
    }
    try {
      final file = await camera.takePicture();
      final bytes = await file.readAsBytes();
      await _disposeCamera();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _step = KioskStep.facePosePreview;
      });
      _bumpSession();
    } catch (e) {
      if (kDebugMode) {
        try {
          final bytes = await _loadMockPhotoBytes();
          await _disposeCamera();
          if (!mounted) return;
          setState(() {
            _usingMockCamera = true;
            _photoBytes = bytes;
            _step = KioskStep.facePosePreview;
          });
          _bumpSession();
          return;
        } catch (_) {}
      }
      _showError(_s.cameraUnavailableBody, camera: true);
    }
  }

  Future<void> _useEnrollmentPhoto() async {
    final bytes = _photoBytes;
    if (bytes == null || bytes.isEmpty) {
      _showError(_s.genericError);
      return;
    }

    _enrollPhotos[_currentPose] = bytes;

    if (_enrollIndex < _enrollPoses.length - 1) {
      setState(() {
        _enrollIndex += 1;
        _photoBytes = null;
        _step = KioskStep.faceCapture;
      });
      _bumpSession();
      unawaited(_startCameraCapture());
      return;
    }

    setState(() {
      _photoBytes = null;
      _step = KioskStep.faceReview;
    });
    _bumpSession();
  }

  Future<void> _uploadEnrollment() async {
    final lookup = _lookup;
    final front = _enrollPhotos['front'];
    final right = _enrollPhotos['right'];
    final left = _enrollPhotos['left'];
    if (lookup == null || front == null || right == null || left == null) {
      _showError(_s.genericError);
      return;
    }

    setState(() => _step = KioskStep.faceUploading);
    _bumpSession();

    try {
      await widget.api.enrollFace(
        rfidUid: lookup.rfidUid,
        front: front,
        right: right,
        left: left,
      );

      if (!mounted) return;
      await _disposeCamera();
      setState(() {
        _step = KioskStep.faceCompleted;
        _enrollPhotos.clear();
        _photoBytes = null;
      });
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _createAccountThenEnroll() async {
    final lookup = _lookup;
    final draft = _draft;
    if (lookup == null || draft == null) {
      _showError(_s.genericError);
      return;
    }

    setState(() => _step = KioskStep.faceUploading);
    _bumpSession();

    try {
      final bound = await widget.api.registerVisitor(
        rfidUid: lookup.rfidUid,
        name: draft.name,
        email: draft.email,
        phone: draft.phone,
      );
      if (!mounted) return;
      setState(() {
        _lookup = bound;
        _enrollmentForExisting = false;
      });
      _beginEnrollment();
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _disposeCamera() {
    return _withCameraGate(_disposeCameraUnlocked);
  }

  Future<void> _disposeCameraUnlocked() async {
    final cam = _cameraController;
    _cameraController = null;
    if (cam == null) return;
    try {
      await cam.dispose();
    } catch (e) {
      debugPrint('[kiosk] camera dispose: $e');
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _rfidFocus,
      autofocus: _listenRfid,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onTapDown: (_) => _bumpSession(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          body: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case KioskStep.idle:
        return WelcomePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          serverOnline: _serverOnline,
          onTapMemberCard: () => unawaited(_startVisitScan()),
          onRegister: () => unawaited(_startRegisterRfidScan()),
          onHelp: () => setState(() => _step = KioskStep.help),
        );
      case KioskStep.awaitingRfidVisit:
      case KioskStep.awaitingRfidRegister:
      case KioskStep.verifyingRfid:
        return RfidAwaitPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          serverOnline: _serverOnline,
          verifying: _step == KioskStep.verifyingRfid,
          registerFlow: _registerFlow,
          onCancel: () => unawaited(_goIdle()),
          scannerController: _scannerController,
          onDetect: _onQrDetect,
          showScanner: _awaitingRfid && _hardwareReady,
        );
      case KioskStep.rfidUnregistered:
        return UnregisteredPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onRegister: () {
            _rfidFocus.unfocus();
            setState(() {
              _registerFlow = true;
              _step = KioskStep.registration;
            });
            _bumpSession();
          },
          onCancel: () => unawaited(_goIdle()),
        );
      case KioskStep.registration:
        return RegisterProfilePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          initialName: _draft?.name ?? '',
          initialEmail: _draft?.email,
          initialPhone: _draft?.phone,
          onContinue: (name, email, phone) {
            setState(() {
              _draft = RegisterDraft(
                name: name,
                email: email,
                phone: phone,
              );
            });
            unawaited(_createAccountThenEnroll());
          },
          onCancel: () => unawaited(_goIdle()),
        );
      case KioskStep.faceEnrollmentIntro:
        return FaceEnrollmentIntroPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          requiredExisting: _enrollmentForExisting,
          onStart: () => unawaited(_startCameraCapture()),
          onBack: () => unawaited(_goIdle()),
        );
      case KioskStep.faceCapture:
        final copy = _poseCopy;
        return _CameraCaptureView(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          controller: _cameraController,
          countdown: _countdown,
          countdownMax: KioskConfig.countdownSeconds,
          title: copy.$1,
          instruction: _s.keepFace,
          mockCamera: _mockCaptureActive,
          onCancel: () => unawaited(_cancelFaceCapture()),
          onBack: () => unawaited(_cancelFaceCapture()),
        );
      case KioskStep.facePosePreview:
        return PhotoPreviewPage(
          strings: _s,
          photoBytes: _photoBytes!,
          onUsePhoto: () => unawaited(_useEnrollmentPhoto()),
          onRetake: () => unawaited(_startCameraCapture()),
        );
      case KioskStep.faceReview:
        return FaceReviewPage(
          strings: _s,
          front: _enrollPhotos['front']!,
          right: _enrollPhotos['right']!,
          left: _enrollPhotos['left']!,
          onComplete: () => unawaited(_uploadEnrollment()),
          onRetake: () {
            setState(() {
              _enrollIndex = 0;
              _enrollPhotos.clear();
              _photoBytes = null;
            });
            unawaited(_startCameraCapture());
          },
        );
      case KioskStep.faceUploading:
        return ProgressStatusPage(
          title: _s.savingIdentity,
          message: _s.pleaseWait,
        );
      case KioskStep.faceCompleted:
        return EnrollmentCompletePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onDone: () => unawaited(_goIdle()),
        );
      case KioskStep.visitCreating:
        return ProgressStatusPage(
          title: _s.recordingVisit,
          message: _s.pleaseWait,
        );
      case KioskStep.visitSuccess:
        return VisitSuccessPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          name: _checkIn?.memberName ?? _lookup?.user?.name ?? '',
          pointsAwarded: _checkIn?.pointsAwarded ?? 0,
          pointsBalance: _checkIn?.pointsBalance ?? 0,
          onDone: () => unawaited(_goIdle()),
        );
      case KioskStep.duplicateVisit:
        return DuplicateCheckInPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          name: _checkIn?.memberName ?? _lookup?.user?.name,
          onHome: () => unawaited(_goIdle()),
        );
      case KioskStep.cameraError:
        return CameraErrorPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onRetry: () => unawaited(_startCameraCapture()),
          onHome: () => unawaited(_goIdle()),
        );
      case KioskStep.sessionTimeout:
        return TimeoutPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onStart: () => unawaited(_goIdle()),
        );
      case KioskStep.offline:
        return OfflinePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onRetry: () async {
            await _pollHealth();
            if (_serverOnline) {
              await _goIdle();
            }
          },
          onHome: () => unawaited(_goIdle()),
        );
      case KioskStep.error:
        return ErrorPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          message: _errorMessage ?? _s.couldNotCheckIn,
          onRetry: () => unawaited(_retryFromError()),
          onCancel: () => unawaited(_goIdle()),
        );
      case KioskStep.help:
        return HelpPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onBack: () => unawaited(_goIdle()),
        );
    }
  }
}

class _CameraCaptureView extends StatelessWidget {
  const _CameraCaptureView({
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.controller,
    required this.countdown,
    required this.countdownMax,
    required this.title,
    required this.instruction,
    required this.mockCamera,
    required this.onCancel,
    required this.onBack,
  });

  final KioskStrings strings;
  final KioskLang lang;
  final ValueChanged<KioskLang> onLangChanged;
  final CameraController? controller;
  final int countdown;
  final int countdownMax;
  final String title;
  final String instruction;
  final bool mockCamera;
  final VoidCallback onCancel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ready = !mockCamera &&
        controller != null &&
        controller!.value.isInitialized;
    final progress = countdownMax <= 0
        ? 1.0
        : ((countdownMax - countdown + 1) / countdownMax).clamp(0.0, 1.0);

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KioskAppHeader(
              title: title,
              lang: lang,
              onLangChanged: onLangChanged,
              onBack: onBack,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          instruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.45,
                            color: Color(0xFF6D6E73),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 360,
                              height: 360,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: -20,
                                    top: 120,
                                    child: _CountdownRing(
                                      size: 80,
                                      progress: progress,
                                      label:
                                          countdown <= 0 ? '✓' : '$countdown',
                                    ),
                                  ),
                                  _FaceCaptureFrame(
                                    size: 280,
                                    mobile: false,
                                    child: _CameraCirclePreview(
                                      ready: ready,
                                      mockCamera: mockCamera,
                                      controller: controller,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(strings.cancel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.size,
    required this.progress,
    required this.label,
  });

  final double size;
  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CountdownRingPainter(progress: progress),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  _CountdownRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final track = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - track.strokeWidth / 2, track);
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius - active.strokeWidth / 2,
      ),
      -1.5708,
      6.2832 * progress.clamp(0.05, 1.0),
      false,
      active,
    );

    final fill = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - track.strokeWidth - 2, fill);
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FaceCaptureFrame extends StatelessWidget {
  const _FaceCaptureFrame({
    required this.size,
    required this.mobile,
    required this.child,
  });

  final double size;
  final bool mobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final corner = mobile ? 40.0 : 58.0;
    final borderW = mobile ? 5.0 : 7.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size * 0.84,
            height: size * 0.84,
            child: child,
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _corner(corner, borderW, top: true, left: true),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _corner(corner, borderW, top: true, left: false),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _corner(corner, borderW, top: false, left: true),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _corner(corner, borderW, top: false, left: false),
          ),
        ],
      ),
    );
  }

  Widget _corner(
    double size,
    double borderW, {
    required bool top,
    required bool left,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(10) : Radius.zero,
            topRight: top && !left ? const Radius.circular(10) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(10) : Radius.zero,
            bottomRight:
                !top && !left ? const Radius.circular(10) : Radius.zero,
          ),
          border: Border(
            top: top
                ? BorderSide(color: AppColors.primary, width: borderW)
                : BorderSide.none,
            bottom: !top
                ? BorderSide(color: AppColors.primary, width: borderW)
                : BorderSide.none,
            left: left
                ? BorderSide(color: AppColors.primary, width: borderW)
                : BorderSide.none,
            right: !left
                ? BorderSide(color: AppColors.primary, width: borderW)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CameraCirclePreview extends StatelessWidget {
  const _CameraCirclePreview({
    required this.ready,
    required this.mockCamera,
    required this.controller,
  });

  final bool ready;
  final bool mockCamera;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEDEDED),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ready
          ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.previewSize?.height ?? 720,
                height: controller!.value.previewSize?.width ?? 1280,
                child: CameraPreview(controller!),
              ),
            )
          : mockCamera
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      KioskConfig.mockCameraAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFEEF7F5),
                          child: Icon(
                            Icons.person_rounded,
                            size: 72,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          'MOCK CAMERA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const ColoredBox(
                  color: Color(0xFFF2F2F2),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.4,
                    ),
                  ),
                ),
    );
  }
}
