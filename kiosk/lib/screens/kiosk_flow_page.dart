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
import '../services/presence_service.dart';
import '../services/rfid_keyboard_buffer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../widgets/kiosk_scaffold.dart';
import 'idle_page.dart';
import 'photo_preview_page.dart';
import 'register_pages.dart';
import 'status_pages.dart';

enum KioskStep {
  welcome,
  rfidScan,
  verifyingRfid,
  memberFound,
  newMember,
  registrationName,
  registrationContact,
  registrationConfirm,
  cameraPrep,
  cameraCapture,
  photoPreview,
  verifyingPresence,
  checkingIn,
  awardingPoints,
  checkInSuccess,
  pointsEarned,
  duplicateCheckIn,
  cameraError,
  sessionTimeout,
  offline,
  error,
  help,
}

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

  late final PresenceService _presence = PresenceService(widget.api);

  Future<void> _cameraGate = Future<void>.value();

  KioskStep _step = KioskStep.welcome;
  KioskLang _lang = KioskLang.en;
  String? _errorMessage;
  final bool _rfidReady = true;
  bool _serverOnline = true;

  RfidLookup? _lookup;
  RegisterDraft? _draft;
  Uint8List? _photoBytes;
  CheckInRecord? _checkIn;

  CameraController? _cameraController;
  Timer? _countdownTimer;
  Timer? _healthTimer;
  Timer? _holdTimer;
  Timer? _sessionTimer;
  int _countdown = KioskConfig.countdownSeconds;

  KioskStrings get _s => KioskStrings(_lang);

  bool get _hardwareReady => _rfidReady && _serverOnline;

  bool get _onScanSurface =>
      _step == KioskStep.welcome || _step == KioskStep.rfidScan;

  bool get _listenRfid => _onScanSurface && _hardwareReady;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rfidFocus.requestFocus();
      unawaited(_startScannerSafely());
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
    if (_step == KioskStep.welcome ||
        _step == KioskStep.sessionTimeout ||
        _step == KioskStep.checkInSuccess ||
        _step == KioskStep.pointsEarned) {
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
      _lookup = null;
      _draft = null;
      _photoBytes = null;
      _checkIn = null;
      _errorMessage = null;
    });
    _holdTimer = Timer(KioskConfig.timeoutHold, () {
      if (!mounted) return;
      unawaited(_goIdle());
    });
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

  Future<void> _openScan() async {
    if (!_serverOnline) {
      setState(() => _step = KioskStep.offline);
      return;
    }
    setState(() => _step = KioskStep.rfidScan);
    _bumpSession();
    await _startScannerSafely();
    _rfidFocus.requestFocus();
  }

  Future<void> _handleDetectedCode(String code) async {
    if (!_onScanSurface || !_hardwareReady) return;
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
          setState(() {
            _lookup = lookup;
            _step = KioskStep.memberFound;
          });
          _bumpSession();
          _holdTimer?.cancel();
          _holdTimer = Timer(KioskConfig.memberFoundHold, () {
            if (!mounted || _step != KioskStep.memberFound) return;
            setState(() => _step = KioskStep.cameraPrep);
          });
        case RfidLookupCode.rfidNotRegistered:
          setState(() {
            _lookup = lookup;
            _step = KioskStep.newMember;
          });
          _bumpSession();
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
      _step = KioskStep.welcome;
      _lookup = null;
      _draft = null;
      _photoBytes = null;
      _checkIn = null;
      _errorMessage = null;
      _countdown = KioskConfig.countdownSeconds;
    });
    await _startScannerSafely();
    _rfidFocus.requestFocus();
  }

  Future<void> _retryFromError() async {
    if (_photoBytes != null && _lookup != null) {
      setState(() => _step = KioskStep.photoPreview);
      _bumpSession();
      return;
    }
    if (_lookup != null && _lookup!.isRegistered) {
      setState(() => _step = KioskStep.cameraPrep);
      _bumpSession();
      return;
    }
    await _goIdle();
  }

  Future<void> _startCameraCapture() async {
    setState(() => _step = KioskStep.cameraCapture);
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
        _step = KioskStep.photoPreview;
      });
      _bumpSession();
    } catch (_) {
      _showError(_s.cameraUnavailableBody, camera: true);
    }
  }

  Future<void> _usePhoto() async {
    final lookup = _lookup;
    final bytes = _photoBytes;
    if (lookup == null || bytes == null || bytes.isEmpty) {
      _showError(_s.genericError);
      return;
    }

    try {
      var bound = lookup;
      if (!bound.isRegistered) {
        final draft = _draft;
        if (draft == null) {
          _showError(_s.genericError);
          return;
        }
        setState(() => _step = KioskStep.verifyingPresence);
        bound = await widget.api.registerVisitor(
          rfidUid: lookup.rfidUid,
          name: draft.name,
          email: draft.email,
          phone: draft.phone,
        );
        if (!mounted) return;
        setState(() => _lookup = bound);
      }

      setState(() => _step = KioskStep.verifyingPresence);
      final presence = await _presence.submitCapture(
        rfidUid: bound.rfidUid,
        photoBytes: bytes,
      );

      if (!mounted) return;
      setState(() => _step = KioskStep.checkingIn);
      final checkIn = await _presence.completeCheckIn(
        presence: presence,
        rfidUid: bound.rfidUid,
      );

      if (!mounted) return;
      if (!checkIn.succeeded) {
        _showError(_s.checkInFailed);
        return;
      }

      setState(() => _checkIn = checkIn);

      if (checkIn.alreadyCheckedInToday && checkIn.pointsAwarded == 0) {
        setState(() => _step = KioskStep.duplicateCheckIn);
        _bumpSession();
        return;
      }

      setState(() => _step = KioskStep.awardingPoints);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _step = KioskStep.checkInSuccess);
      _holdTimer?.cancel();
      _holdTimer = Timer(const Duration(seconds: 6), () {
        if (!mounted || _step != KioskStep.checkInSuccess) return;
        setState(() => _step = KioskStep.pointsEarned);
        _armIdleFromPoints();
      });
    } catch (e) {
      _showError(_customerMessage(e));
    }
  }

  void _armIdleFromPoints() {
    _holdTimer?.cancel();
    _holdTimer = Timer(KioskConfig.successHold, () {
      if (!mounted || _step != KioskStep.pointsEarned) return;
      unawaited(_goIdle());
    });
  }

  DateTime? _checkedInAt() {
    final raw = _checkIn?.checkedInAt;
    if (raw == null || raw.isEmpty) return DateTime.now();
    return DateTime.tryParse(raw) ?? DateTime.now();
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
          body: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case KioskStep.welcome:
        return WelcomePage(
          strings: _s,
          lang: _lang,
          onLangChanged: (lang) => setState(() => _lang = lang),
          serverOnline: _serverOnline,
          onCheckIn: () => unawaited(_openScan()),
          onRegister: () => unawaited(_openScan()),
          onHelp: () => setState(() => _step = KioskStep.help),
        );
      case KioskStep.rfidScan:
      case KioskStep.verifyingRfid:
        return RfidScanPage(
          strings: _s,
          scannerController: _scannerController,
          onDetect: _onQrDetect,
          showScanner: _step == KioskStep.rfidScan && _hardwareReady,
          processing: _step == KioskStep.verifyingRfid,
          onCancel: () => unawaited(_goIdle()),
          onHelp: () => setState(() => _step = KioskStep.help),
          serverOnline: _serverOnline,
        );
      case KioskStep.memberFound:
        return RegisteredPage(
          lookup: _lookup!,
          strings: _s,
          onContinue: () {
            _holdTimer?.cancel();
            setState(() => _step = KioskStep.cameraPrep);
            _bumpSession();
          },
        );
      case KioskStep.newMember:
        return UnregisteredPage(
          strings: _s,
          onRegister: () {
            _rfidFocus.unfocus();
            setState(() => _step = KioskStep.registrationName);
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
              _step = KioskStep.registrationConfirm;
            });
            _bumpSession();
          },
          onBack: () {
            setState(() => _step = KioskStep.registrationName);
            _bumpSession();
          },
        );
      case KioskStep.registrationConfirm:
        return RegisterConfirmPage(
          strings: _s,
          name: _draft?.name ?? '',
          email: _draft?.email,
          phone: _draft?.phone,
          rfidUid: _lookup?.rfidUid ?? '',
          onCreate: () {
            setState(() => _step = KioskStep.cameraPrep);
            _bumpSession();
          },
          onBack: () {
            setState(() => _step = KioskStep.registrationContact);
            _bumpSession();
          },
        );
      case KioskStep.cameraPrep:
        return CameraPrepPage(
          strings: _s,
          onContinue: () => unawaited(_startCameraCapture()),
        );
      case KioskStep.cameraCapture:
        return _CameraCaptureView(
          strings: _s,
          controller: _cameraController,
          countdown: _countdown,
        );
      case KioskStep.photoPreview:
        return PhotoPreviewPage(
          strings: _s,
          photoBytes: _photoBytes!,
          onUsePhoto: () => unawaited(_usePhoto()),
          onRetake: () => unawaited(_startCameraCapture()),
        );
      case KioskStep.verifyingPresence:
        return ProgressStatusPage(
          title: _s.confirmingPresence,
          message: _s.pleaseWait,
        );
      case KioskStep.checkingIn:
        return ProgressStatusPage(
          title: _s.checkingIn,
          message: _s.pleaseWait,
        );
      case KioskStep.awardingPoints:
        return ProgressStatusPage(
          title: _s.awardingPoints,
          message: _s.pleaseWait,
        );
      case KioskStep.checkInSuccess:
        return SuccessPage(
          strings: _s,
          name: _checkIn?.memberName ?? _lookup?.user?.name ?? '',
          checkedInAt: _checkedInAt(),
          onContinue: () {
            _holdTimer?.cancel();
            setState(() => _step = KioskStep.pointsEarned);
            _armIdleFromPoints();
          },
        );
      case KioskStep.pointsEarned:
        return PointsPage(
          strings: _s,
          pointsAwarded: _checkIn?.pointsAwarded ?? 0,
          pointsBalance: _checkIn?.pointsBalance ?? 0,
          onDone: () => unawaited(_goIdle()),
        );
      case KioskStep.duplicateCheckIn:
        return DuplicateCheckInPage(
          strings: _s,
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
              await _openScan();
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
}

class _CameraCaptureView extends StatelessWidget {
  const _CameraCaptureView({
    required this.strings,
    required this.controller,
    required this.countdown,
  });

  final KioskStrings strings;
  final CameraController? controller;
  final int countdown;

  @override
  Widget build(BuildContext context) {
    final ready = controller != null && controller!.value.isInitialized;
    final overlay = countdown <= 0 ? strings.capture : '$countdown';
    return KioskScaffold(
      dark: true,
      child: Column(
        children: [
          Text(
            strings.takePhoto,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
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
