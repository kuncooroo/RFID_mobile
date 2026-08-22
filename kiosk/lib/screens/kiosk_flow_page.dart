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
import '../theme/app_radius.dart';
import '../widgets/kiosk_scaffold.dart';
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
  registrationName,
  registrationContact,
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
  Timer? _countdownTimer;
  Timer? _healthTimer;
  Timer? _holdTimer;
  Timer? _sessionTimer;
  Timer? _returnTimer;
  int _countdown = KioskConfig.countdownSeconds;
  int _returnSeconds = 5;

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
    _returnTimer?.cancel();
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
    _returnTimer?.cancel();
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
    _countdown = KioskConfig.countdownSeconds;
  }

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
            setState(() => _step = KioskStep.registrationName);
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
    _returnTimer?.cancel();
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
    _returnTimer?.cancel();
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
      setState(() => _step = KioskStep.registrationName);
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
        setState(() {
          _step = KioskStep.duplicateVisit;
          _returnSeconds = 4;
        });
        _armReturnCountdown(KioskStep.duplicateVisit, seconds: 4);
        return;
      }

      setState(() {
        _step = KioskStep.visitSuccess;
        _returnSeconds = 5;
      });
      _armReturnCountdown(KioskStep.visitSuccess, seconds: 5);
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  void _armReturnCountdown(KioskStep expected, {required int seconds}) {
    _returnTimer?.cancel();
    _returnSeconds = seconds;
    _returnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _step != expected) {
        timer.cancel();
        return;
      }
      if (_returnSeconds <= 1) {
        timer.cancel();
        unawaited(_goIdle());
        return;
      }
      setState(() => _returnSeconds -= 1);
    });
  }

  Future<void> _startCameraCapture() async {
    setState(() => _step = KioskStep.faceCapture);
    _bumpSession();
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
          _cameraController = controller;
          _countdown = KioskConfig.countdownSeconds;
        });
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
      });
    } catch (_) {
      _showError(_s.cameraUnavailableBody, camera: true);
    }
  }

  Future<void> _snapPhoto() async {
    final camera = _cameraController;
    if (camera == null || !camera.value.isInitialized) {
      _showError(_s.cameraUnavailableBody, camera: true);
      return;
    }
    setState(() => _countdown = 0);
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
    } catch (_) {
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
        _returnSeconds = 4;
      });
      _armReturnCountdown(KioskStep.faceCompleted, seconds: 4);
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
          onHelp: () => setState(() => _step = KioskStep.help),
          scannerController: _scannerController,
          onDetect: _onQrDetect,
          showScanner: _awaitingRfid && _hardwareReady,
        );
      case KioskStep.rfidUnregistered:
        return UnregisteredPage(
          strings: _s,
          onRegister: () {
            _rfidFocus.unfocus();
            setState(() {
              _registerFlow = true;
              _step = KioskStep.registrationName;
            });
            _bumpSession();
          },
          onCancel: () => unawaited(_goIdle()),
        );
      case KioskStep.registrationName:
        return RegisterNamePage(
          strings: _s,
          initial: _draft?.name ?? '',
          onContinue: (name) {
            setState(() {
              _draft = RegisterDraft(
                name: name,
                email: _draft?.email,
                phone: _draft?.phone,
              );
              _step = KioskStep.registrationContact;
            });
            _bumpSession();
          },
          onCancel: () => unawaited(_goIdle()),
        );
      case KioskStep.registrationContact:
        return RegisterContactPage(
          strings: _s,
          initialEmail: _draft?.email,
          initialPhone: _draft?.phone,
          onContinue: (email, phone) {
            setState(() {
              _draft = RegisterDraft(
                name: _draft?.name ?? '',
                email: email,
                phone: phone,
              );
            });
            unawaited(_createAccountThenEnroll());
          },
          onBack: () {
            setState(() => _step = KioskStep.registrationName);
            _bumpSession();
          },
        );
      case KioskStep.faceEnrollmentIntro:
        return FaceEnrollmentIntroPage(
          strings: _s,
          requiredExisting: _enrollmentForExisting,
          onStart: () => unawaited(_startCameraCapture()),
        );
      case KioskStep.faceCapture:
        final copy = _poseCopy;
        return _CameraCaptureView(
          strings: _s,
          controller: _cameraController,
          countdown: _countdown,
          title: copy.$1,
          instruction: copy.$2,
          poseIndex: _enrollIndex,
          completed: _enrollPhotos.keys.toSet(),
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
          countdown: _returnSeconds,
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
          name: _checkIn?.memberName ?? _lookup?.user?.name ?? '',
          pointsAwarded: _checkIn?.pointsAwarded ?? 0,
          pointsBalance: _checkIn?.pointsBalance ?? 0,
          countdown: _returnSeconds,
          onDone: () => unawaited(_goIdle()),
        );
      case KioskStep.duplicateVisit:
        return DuplicateCheckInPage(
          strings: _s,
          name: _checkIn?.memberName ?? _lookup?.user?.name,
          countdown: _returnSeconds,
          onHome: () => unawaited(_goIdle()),
        );
      case KioskStep.cameraError:
        return CameraErrorPage(
          strings: _s,
          onRetry: () => unawaited(_startCameraCapture()),
          onHome: () => unawaited(_goIdle()),
        );
      case KioskStep.sessionTimeout:
        return TimeoutPage(
          strings: _s,
          onStart: () => unawaited(_goIdle()),
        );
      case KioskStep.offline:
        return OfflinePage(
          strings: _s,
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
          message: _errorMessage ?? _s.couldNotCheckIn,
          onRetry: () => unawaited(_retryFromError()),
          onCancel: () => unawaited(_goIdle()),
        );
      case KioskStep.help:
        return HelpPage(strings: _s, onBack: () => unawaited(_goIdle()));
    }
  }
}

class _CameraCaptureView extends StatelessWidget {
  const _CameraCaptureView({
    required this.strings,
    required this.controller,
    required this.countdown,
    required this.title,
    required this.instruction,
    required this.poseIndex,
    required this.completed,
  });

  final KioskStrings strings;
  final CameraController? controller;
  final int countdown;
  final String title;
  final String instruction;
  final int poseIndex;
  final Set<String> completed;

  @override
  Widget build(BuildContext context) {
    final ready = controller != null && controller!.value.isInitialized;
    final overlay = countdown <= 0 ? strings.capture : '$countdown';
    return KioskScaffold(
      dark: true,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          PoseProgressBar(
            strings: strings,
            currentIndex: poseIndex,
            completed: completed,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (ready)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller!.value.previewSize?.height ?? 720,
                        height: controller!.value.previewSize?.width ?? 1280,
                        child: CameraPreview(controller!),
                      ),
                    )
                  else
                    const ColoredBox(
                      color: Color(0xFF1A1A1A),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  CustomPaint(painter: _FaceGuidePainter()),
                  Center(
                    child: Text(
                      overlay,
                      style: TextStyle(
                        fontSize: countdown <= 0 ? 42 : 96,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: const [
                          Shadow(blurRadius: 18, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.keepFace,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.48),
      width: size.width * 0.58,
      height: size.height * 0.62,
    );
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(oval, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
