import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../config/system_config.dart';
import '../l10n/system_strings.dart';
import '../models/system_member.dart';
import '../models/presence.dart';
import '../services/system_api.dart';
import '../services/rfid_keyboard_buffer.dart';
import '../services/visit_service.dart';
import '../theme/app_colors.dart';
import '../widgets/alert_status_layout.dart';
import '../widgets/system_content_scaffold.dart';
import '../widgets/primary_button.dart';
import 'idle_page.dart';
import 'photo_preview_page.dart';
import 'register_pages.dart';
import 'status_pages.dart';

enum SystemStep {
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
  profileDetails,
  gateCapture,
  gatePhotoPreview,
  insufficientBalance,
  visitCreating,
  paymentSuccess,
  visitResult,
  cardNeedsLink,
  visitSuccess,
  duplicateVisit,
  cameraError,
  sessionTimeout,
  offline,
  error,
  help,
}

const _enrollPoses = ['front', 'right', 'left'];

class SystemFlowPage extends StatefulWidget {
  const SystemFlowPage({super.key, required this.api});

  final SystemApi api;

  @override
  State<SystemFlowPage> createState() => _SystemFlowPageState();
}

class _SystemFlowPageState extends State<SystemFlowPage> {
  final _rfidFocus = FocusNode(debugLabel: 'kioskRfid');
  final _rfidBuffer = RfidKeyboardBuffer();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.front,
    autoStart: false,
  );

  late final VisitService _visits = VisitService(widget.api);
  Future<void> _cameraGate = Future<void>.value();

  SystemStep _step = SystemStep.idle;
  SystemLang _lang = SystemLang.en;
  String? _errorMessage;
  final bool _rfidReady = true;
  bool _serverOnline = true;
  bool _rfidLocked = false;
  bool _registerFlow = false;
  bool _capturingGate = false;

  RfidLookup? _lookup;
  RegisterDraft? _draft;
  Uint8List? _photoBytes;
  CheckInRecord? _checkIn;

  int _enrollIndex = 0;
  final Map<String, Uint8List> _enrollPhotos = {};
  bool _enrollmentForExisting = false;
  bool _identityLinked = false;

  CameraController? _cameraController;
  /// True for this capture session when using placeholder instead of hardware.
  bool _usingMockCamera = false;
  Timer? _countdownTimer;
  Timer? _healthTimer;
  Timer? _holdTimer;
  Timer? _sessionTimer;
  int _countdown = SystemConfig.countdownSeconds;

  SystemStrings get _s => SystemStrings(_lang);
  bool get _hardwareReady => _rfidReady && _serverOnline;
  bool get _awaitingRfid =>
      _step == SystemStep.awaitingRfidVisit ||
      _step == SystemStep.awaitingRfidRegister;
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
    if (_step == SystemStep.idle ||
        _step == SystemStep.sessionTimeout ||
        _step == SystemStep.visitSuccess ||
        _step == SystemStep.visitResult ||
        _step == SystemStep.faceCompleted ||
        _step == SystemStep.duplicateVisit) {
      return;
    }
    _sessionTimer = Timer(SystemConfig.sessionTimeout, _onSessionTimeout);
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
      _step = SystemStep.sessionTimeout;
      _clearSessionFields();
    });
    _holdTimer = Timer(SystemConfig.timeoutHold, () {
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
    _identityLinked = false;
    _registerFlow = false;
    _capturingGate = false;
    _rfidLocked = false;
    _usingMockCamera = false;
    _countdown = SystemConfig.countdownSeconds;
  }

  /// Only when explicitly enabled via `--dart-define=MOCK_CAMERA=true`.
  bool get _preferMockCamera => SystemConfig.mockCamera;

  bool get _mockCaptureActive =>
      _usingMockCamera || SystemConfig.mockCamera;

  void _startHealthPoll() {
    _healthTimer?.cancel();
    unawaited(_pollHealth());
    _healthTimer = Timer.periodic(SystemConfig.healthPoll, (_) {
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
      _step = SystemStep.verifyingRfid;
      _errorMessage = null;
    });
    _bumpSession();

    await WidgetsBinding.instance.endOfFrame;
    await _stopScannerFully();

    try {
      final lookup = await widget.api
          .lookupRfid(code)
          .timeout(SystemConfig.lookupTimeout);
      if (!mounted) return;

      switch (lookup.resultCode) {
        case RfidLookupCode.memberFound:
        case RfidLookupCode.cardReady:
          setState(() => _lookup = lookup);
          if (registerFlow) {
            if (lookup.resultCode == RfidLookupCode.memberFound) {
              _showError(_s.cardAlreadyRegistered);
              return;
            }
            setState(() => _step = SystemStep.registration);
            _bumpSession();
            return;
          }
          if (lookup.resultCode != RfidLookupCode.memberFound) {
            setState(() => _step = SystemStep.cardNeedsLink);
            _bumpSession();
            return;
          }
          if (!lookup.canEnter) {
            setState(() => _step = SystemStep.insufficientBalance);
            _bumpSession();
          } else if (lookup.user == null || !lookup.user!.hasProfile) {
            setState(() => _step = SystemStep.profileDetails);
            _bumpSession();
          } else {
            unawaited(_chargeThenPhoto());
          }
        case RfidLookupCode.rfidNotRegistered:
          setState(() => _lookup = lookup);
          if (registerFlow) {
            setState(() => _step = SystemStep.registration);
            _bumpSession();
          } else {
            setState(() => _step = SystemStep.rfidUnregistered);
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
      setState(() => _step = SystemStep.offline);
      return;
    }
    setState(() {
      _registerFlow = false;
      _lookup = null;
      _step = SystemStep.awaitingRfidVisit;
    });
    _bumpSession();
    await _startScannerSafely();
    _rfidFocus.requestFocus();
  }

  Future<void> _startRegisterRfidScan() async {
    if (!_serverOnline) {
      setState(() => _step = SystemStep.offline);
      return;
    }
    setState(() {
      _registerFlow = true;
      _step = SystemStep.awaitingRfidRegister;
    });
    _bumpSession();
    await _startScannerSafely();
    _rfidFocus.requestFocus();
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
      _step = camera ? SystemStep.cameraError : SystemStep.error;
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
      _step = SystemStep.idle;
      _clearSessionFields();
    });
    await _stopScannerFully();
    _rfidFocus.requestFocus();
  }

  Future<void> _retryFromError() async {
    if (_photoBytes != null && _lookup != null) {
      setState(() => _step = SystemStep.facePosePreview);
      _bumpSession();
      return;
    }
    if (_registerFlow && _lookup != null && !_lookup!.isRegistered) {
      setState(() => _step = SystemStep.registration);
      _bumpSession();
      return;
    }
    if (_registerFlow) {
      unawaited(_startRegisterRfidScan());
      return;
    }
    if (_lookup != null && _lookup!.isRegistered) {
      if (_checkIn != null && _checkIn!.succeeded && !_checkIn!.duplicate) {
        if (_photoBytes != null) {
          setState(() => _step = SystemStep.visitResult);
          _bumpSession();
          return;
        }
        unawaited(_startGateCapture());
        return;
      }
      if (!_lookup!.canEnter) {
        setState(() => _step = SystemStep.insufficientBalance);
        _bumpSession();
        return;
      }
      if (_capturingGate && _photoBytes != null) {
        setState(() => _step = SystemStep.gatePhotoPreview);
        _bumpSession();
        return;
      }
      unawaited(_startGateCapture());
      return;
    }
    if (_lookup != null && !_lookup!.isRegistered) {
      setState(() => _step = SystemStep.rfidUnregistered);
      _bumpSession();
      return;
    }
    await _goIdle();
  }

  Future<void> _startGateCapture() async {
    _capturingGate = true;
    await _startCameraCapture(step: SystemStep.gateCapture);
  }

  Future<void> _recordVisit({List<int>? photo}) async {
    final lookup = _lookup;
    if (lookup == null || !lookup.canUseGate) {
      _showError(_s.genericError);
      return;
    }

    setState(() => _step = SystemStep.visitCreating);
    _bumpSession();

    try {
      final checkIn = await _visits.recordVisit(
        rfidUid: lookup.rfidUid,
        photo: photo,
      );
      if (!mounted) return;
      if (checkIn.denied) {
        setState(() => _step = SystemStep.insufficientBalance);
        _bumpSession();
        return;
      }
      if (!checkIn.succeeded) {
        _showError(_s.checkInFailed);
        return;
      }

      setState(() => _checkIn = checkIn);

      if (checkIn.duplicate) {
        setState(() => _step = SystemStep.duplicateVisit);
        return;
      }

      setState(() => _step = SystemStep.visitSuccess);
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _cancelFaceCapture() async {
    _countdownTimer?.cancel();
    await _disposeCamera();
    if (!mounted) return;
    setState(() {
      _countdown = SystemConfig.countdownSeconds;
      _photoBytes = null;
      _usingMockCamera = false;
      _step = SystemStep.faceEnrollmentIntro;
    });
    _bumpSession();
  }

  void _armCaptureCountdown() {
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

  Future<void> _startMockCameraCapture({
    String? reason,
    SystemStep step = SystemStep.faceCapture,
  }) async {
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
      _countdown = SystemConfig.countdownSeconds;
      _step = step;
    });
    _armCaptureCountdown();
  }

  Future<void> _startCameraCapture({
    SystemStep step = SystemStep.faceCapture,
  }) async {
    setState(() => _step = step);
    _bumpSession();

    if (_preferMockCamera) {
      await _startMockCameraCapture(step: step);
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
          _countdown = SystemConfig.countdownSeconds;
        });
        _armCaptureCountdown();
      });
    } catch (e) {
      debugPrint('[kiosk] camera start failed: $e');
      _showError(_s.cameraUnavailableBody, camera: true);
    }
  }

  Future<Uint8List> _loadMockPhotoBytes() async {
    final data = await rootBundle.load(SystemConfig.mockCameraAsset);
    return data.buffer.asUint8List();
  }

  Future<void> _snapPhoto() async {
    setState(() => _countdown = 0);

    if (_mockCaptureActive) {
      try {
        final bytes = await _loadMockPhotoBytes();
        await _disposeCamera();
        if (!mounted) return;
        if (_capturingGate) {
          await _finishGatePhoto(bytes);
          return;
        }
        setState(() {
          _photoBytes = bytes;
          _step = SystemStep.facePosePreview;
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
      _showError(_s.cameraUnavailableBody, camera: true);
      return;
    }
    try {
      final file = await camera.takePicture();
      final bytes = await file.readAsBytes();
      await _disposeCamera();
      if (!mounted) return;
      if (_capturingGate) {
        await _finishGatePhoto(bytes);
        return;
      }
      setState(() {
        _photoBytes = bytes;
        _step = SystemStep.facePosePreview;
      });
      _bumpSession();
    } catch (e) {
      debugPrint('[kiosk] takePicture failed: $e');
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
        _step = SystemStep.faceCapture;
      });
      _bumpSession();
      unawaited(_startCameraCapture());
      return;
    }

    setState(() {
      _photoBytes = null;
      _step = SystemStep.faceReview;
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

    setState(() => _step = SystemStep.faceUploading);
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
        _step = SystemStep.faceCompleted;
        _enrollPhotos.clear();
        _photoBytes = null;
      });
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _chargeThenPhoto() async {
    final lookup = _lookup;
    if (lookup == null) {
      _showError(_s.genericError);
      return;
    }
    setState(() => _step = SystemStep.visitCreating);
    _bumpSession();
    try {
      final checkIn = await _visits.recordVisit(rfidUid: lookup.rfidUid);
      if (!mounted) return;
      if (checkIn.denied) {
        setState(() => _step = SystemStep.insufficientBalance);
        _bumpSession();
        return;
      }
      if (!checkIn.succeeded) {
        _showError(_s.checkInFailed);
        return;
      }
      setState(() => _checkIn = checkIn);
      if (checkIn.duplicate) {
        setState(() => _step = SystemStep.duplicateVisit);
        return;
      }
      setState(() => _step = SystemStep.paymentSuccess);
      _bumpSession();
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _saveExistingProfile(RegisterDraft draft) async {
    final lookup = _lookup;
    if (lookup == null || draft.age == null || draft.gender == null) {
      _showError(_s.genericError);
      return;
    }
    setState(() => _step = SystemStep.visitCreating);
    _bumpSession();
    try {
      final updated = await widget.api.updateProfile(
        rfidUid: lookup.rfidUid,
        name: draft.name,
        age: draft.age!,
        origin: draft.origin ?? '',
        gender: draft.gender!,
      );
      if (!mounted) return;
      setState(() => _lookup = updated);
      if (!updated.canEnter) {
        setState(() => _step = SystemStep.insufficientBalance);
        return;
      }
      await _chargeThenPhoto();
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  Future<void> _finishGatePhoto(List<int> bytes) async {
    final lookup = _lookup;
    final checkIn = _checkIn;
    setState(() {
      _photoBytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
      _step = SystemStep.visitCreating;
    });
    _bumpSession();
    try {
      if (lookup != null && checkIn != null) {
        await widget.api.attachVisitPhoto(
          checkInId: checkIn.id,
          rfidUid: lookup.rfidUid,
          photo: bytes,
        );
      }
      if (!mounted) return;
      setState(() => _step = SystemStep.visitResult);
      _bumpSession();
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

    setState(() => _step = SystemStep.faceUploading);
    _bumpSession();

    try {
      final bound = await widget.api.registerVisitor(
        rfidUid: lookup.rfidUid,
        name: draft.name,
        email: draft.email,
        phone: draft.phone,
        age: draft.age,
        origin: draft.origin,
        gender: draft.gender,
      );
      if (!mounted) return;
      setState(() {
        _lookup = bound;
        _enrollmentForExisting = false;
        _identityLinked = true;
      });
      if (!bound.canEnter) {
        setState(() => _step = SystemStep.insufficientBalance);
        return;
      }
      await _chargeThenPhoto();
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
      case SystemStep.idle:
        return WelcomePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          serverOnline: _serverOnline,
          onTapMemberCard: () => unawaited(_startVisitScan()),
          onRegister: () => unawaited(_startRegisterRfidScan()),
          onHelp: () => setState(() => _step = SystemStep.help),
        );
      case SystemStep.awaitingRfidVisit:
      case SystemStep.awaitingRfidRegister:
      case SystemStep.verifyingRfid:
        return RfidAwaitPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          serverOnline: _serverOnline,
          verifying: _step == SystemStep.verifyingRfid,
          registerFlow: _registerFlow,
          onCancel: () => unawaited(_goIdle()),
          scannerController: _scannerController,
          onDetect: _onQrDetect,
          showScanner: _awaitingRfid && _hardwareReady,
        );
      case SystemStep.cardNeedsLink:
        return AlertStatusLayout(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          title: _s.cardNeedsLinkTitle,
          body: _s.cardNeedsLinkBody,
          tone: AlertTone.brand,
          icon: Icons.badge_outlined,
          primaryLabel: _s.linkMyself,
          onPrimary: () {
            setState(() {
              _registerFlow = true;
              _step = SystemStep.registration;
            });
            _bumpSession();
          },
          secondaryLabel: _s.back,
          onSecondary: () => unawaited(_goIdle()),
          languageOnlyHeader: true,
        );
      case SystemStep.rfidUnregistered:
        return UnregisteredPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onCancel: () => unawaited(_goIdle()),
        );
      case SystemStep.profileDetails:
        final user = _lookup?.user;
        return RegisterProfilePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          initialName: user?.name ?? '',
          initialAge: user?.age,
          initialOrigin: user?.origin,
          initialGender: user?.gender,
          requirePhone: false,
          onContinue: (draft) => unawaited(_saveExistingProfile(draft)),
          onCancel: () => unawaited(_goIdle()),
        );
      case SystemStep.paymentSuccess:
        final paid = _checkIn;
        return AlertStatusLayout(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          title: _s.paymentDoneTitle,
          body: _s.paymentDoneBody,
          tone: AlertTone.success,
          icon: Icons.payments_rounded,
          badge: AlertBadgeKind.check,
          primaryLabel: _s.takePhoto,
          onPrimary: () => unawaited(_startGateCapture()),
          languageOnlyHeader: true,
          bodyExtra: paid == null
              ? null
              : Text(
                  '${_s.fareCharged}: ${paid.amountCharged.round()}\n${_s.remainingBalance}: ${paid.walletBalance.round()}',
                  textAlign: TextAlign.center,
                ),
        );
      case SystemStep.visitResult:
        return _VisitPhotoResult(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          photoBytes: _photoBytes,
          name: _checkIn?.memberName ?? _lookup?.user?.name ?? '',
          age: _checkIn?.age ?? _lookup?.user?.age,
          origin: _checkIn?.origin ?? _lookup?.user?.origin,
          gender: _s.genderText(_checkIn?.gender ?? _lookup?.user?.gender),
          onDone: () => unawaited(_goIdle()),
          onRetake: () => unawaited(_startGateCapture()),
        );
      case SystemStep.registration:
        return RegisterProfilePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          initialName: _draft?.name ?? '',
          initialEmail: _draft?.email,
          initialPhone: _draft?.phone,
          onContinue: (draft) {
            setState(() => _draft = draft);
            unawaited(_createAccountThenEnroll());
          },
          onCancel: () => unawaited(_goIdle()),
        );
      case SystemStep.faceEnrollmentIntro:
        return FaceEnrollmentIntroPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          requiredExisting: _enrollmentForExisting,
          onStart: () => unawaited(_startCameraCapture()),
          onBack: () => unawaited(_goIdle()),
        );
      case SystemStep.faceCapture:
        final copy = _poseCopy;
        return _CameraCaptureView(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          controller: _cameraController,
          countdown: _countdown,
          countdownMax: SystemConfig.countdownSeconds,
          title: copy.$1,
          instruction: _s.keepFace,
          headerTitle: _s.takeAPhoto,
          mockCamera: _mockCaptureActive,
          onCancel: () => unawaited(_cancelFaceCapture()),
          onBack: () => unawaited(_cancelFaceCapture()),
        );
      case SystemStep.facePosePreview:
        return PhotoPreviewPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          photoBytes: _photoBytes!,
          onUsePhoto: () => unawaited(_useEnrollmentPhoto()),
          onRetake: () => unawaited(_startCameraCapture()),
        );
      case SystemStep.faceReview:
        return FaceReviewPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
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
          onBack: () => unawaited(_goIdle()),
        );
      case SystemStep.faceUploading:
        return ProgressStatusPage(
          title: _s.savingIdentity,
          message: _s.pleaseWait,
        );
      case SystemStep.gateCapture:
        return _CameraCaptureView(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          controller: _cameraController,
          countdown: _countdown,
          countdownMax: SystemConfig.countdownSeconds,
          title: _s.captureVisitTitle,
          instruction: _s.captureVisitBody,
          headerTitle: _s.takeAPhoto,
          mockCamera: _mockCaptureActive,
          fullScreen: true,
          onCancel: () => unawaited(_goIdle()),
          onBack: () => unawaited(_goIdle()),
        );
      case SystemStep.gatePhotoPreview:
        return PhotoPreviewPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          photoBytes: _photoBytes!,
          onUsePhoto: () => unawaited(_recordVisit(photo: _photoBytes)),
          onRetake: () => unawaited(_startGateCapture()),
        );
      case SystemStep.insufficientBalance:
        return ErrorPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          message: _s.insufficientBalance,
          onRetry: () => unawaited(_goIdle()),
          onCancel: () => unawaited(_goIdle()),
        );
      case SystemStep.faceCompleted:
        return EnrollmentCompletePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          title: _identityLinked ? _s.identityLinkedTitle : null,
          body: _identityLinked ? _s.identityLinkedBody : null,
          onDone: () => unawaited(_goIdle()),
        );
      case SystemStep.visitCreating:
        return ProgressStatusPage(
          title: _s.recordingVisit,
          message: _s.pleaseWait,
        );
      case SystemStep.visitSuccess:
        return VisitSuccessPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          name: _checkIn?.memberName ?? _lookup?.user?.name ?? '',
          pointsAwarded: _checkIn?.pointsAwarded ?? 0,
          pointsBalance: _checkIn?.pointsBalance ?? 0,
          amountCharged: _checkIn?.amountCharged ?? 0,
          walletBalance: _checkIn?.walletBalance ?? 0,
          onDone: () => unawaited(_goIdle()),
        );
      case SystemStep.duplicateVisit:
        return DuplicateCheckInPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          name: _checkIn?.memberName ?? _lookup?.user?.name,
          onHome: () => unawaited(_goIdle()),
        );
      case SystemStep.cameraError:
        return CameraErrorPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onRetry: () => unawaited(
            _capturingGate ? _startGateCapture() : _startCameraCapture(),
          ),
          onHome: () => unawaited(_goIdle()),
        );
      case SystemStep.sessionTimeout:
        return TimeoutPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          onStart: () => unawaited(_goIdle()),
        );
      case SystemStep.offline:
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
      case SystemStep.error:
        return ErrorPage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          message: _errorMessage ?? _s.couldNotCheckIn,
          onRetry: () => unawaited(_retryFromError()),
          onCancel: () => unawaited(_goIdle()),
        );
      case SystemStep.help:
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
    required this.headerTitle,
    required this.title,
    required this.instruction,
    required this.mockCamera,
    this.fullScreen = false,
    required this.onCancel,
    required this.onBack,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final CameraController? controller;
  final int countdown;
  final int countdownMax;
  final String headerTitle;
  final String title;
  final String instruction;
  final bool mockCamera;
  final bool fullScreen;
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

    if (fullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.previewSize?.height ?? 1080,
                  height: controller!.value.previewSize?.width ?? 1920,
                  child: CameraPreview(controller!),
                ),
              )
            else
              const ColoredBox(color: Colors.black),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  _CountdownRing(
                    size: 84,
                    progress: progress,
                    label: countdown <= 0 ? '✓' : '$countdown',
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SystemContentScaffold(
      headerTitle: headerTitle,
      lang: lang,
      onLangChanged: onLangChanged,
      onBack: onBack,
      languageOnlyHeader: true,
      footer: SecondaryButton(label: strings.cancel, onPressed: onCancel),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final ringSize = 72.0;

          return Column(
            children: [
              SystemPageHeading(title: title, subtitle: instruction),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Positioned.fill(
                      child: _CameraFramePreview(
                        ready: ready,
                        mockCamera: mockCamera,
                        controller: controller,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _CountdownRing(
                        size: ringSize,
                        progress: progress,
                        label: countdown <= 0 ? '✓' : '$countdown',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

class _CameraFramePreview extends StatelessWidget {
  const _CameraFramePreview({
    required this.ready,
    required this.mockCamera,
    required this.controller,
  });

  final bool ready;
  final bool mockCamera;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: ColoredBox(
        color: const Color(0xFF111111),
        child: ready
            ? _FullCameraPreview(controller: controller!)
            : mockCamera
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        SystemConfig.mockCameraAsset,
                        fit: BoxFit.contain,
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
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.4,
                    ),
                  ),
      ),
    );
  }
}

/// Shows the sensor frame without a circular crop.
class _FullCameraPreview extends StatelessWidget {
  const _FullCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize;
    final aspect = preview == null || preview.width == 0 || preview.height == 0
        ? 3 / 4
        : preview.height / preview.width;

    return Center(
      child: AspectRatio(
        aspectRatio: aspect,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _VisitPhotoResult extends StatelessWidget {
  const _VisitPhotoResult({
    required this.strings,
    required this.lang,
    required this.onLangChanged,
    required this.photoBytes,
    required this.name,
    required this.age,
    required this.origin,
    required this.gender,
    required this.onDone,
    required this.onRetake,
  });

  final SystemStrings strings;
  final SystemLang lang;
  final ValueChanged<SystemLang> onLangChanged;
  final Uint8List? photoBytes;
  final String name;
  final int? age;
  final String? origin;
  final String gender;
  final VoidCallback onDone;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final photo = photoBytes;
    return SystemContentScaffold(
      headerTitle: strings.visitResultTitle,
      lang: lang,
      onLangChanged: onLangChanged,
      languageOnlyHeader: true,
      footer: Column(
        children: [
          PrimaryButton(label: strings.done, onPressed: onDone),
          const SizedBox(height: 12),
          SecondaryButton(label: strings.retake, onPressed: onRetake),
        ],
      ),
      body: ListView(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: photo == null
                  ? const ColoredBox(color: Colors.black)
                  : Image.memory(photo, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          _ResultLine(label: strings.fullName, value: name),
          _ResultLine(label: strings.ageLabel, value: age?.toString() ?? '—'),
          _ResultLine(label: strings.originLabel, value: origin ?? '—'),
          _ResultLine(label: strings.genderLabel, value: gender),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6F737C), fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
