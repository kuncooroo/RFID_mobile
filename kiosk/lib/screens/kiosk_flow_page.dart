import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../config/kiosk_config.dart';
import '../models/kiosk_member.dart';
import '../services/kiosk_api.dart';
import '../services/rfid_keyboard_buffer.dart';
import '../theme/kiosk_theme.dart';
import 'widgets/kiosk_frame.dart';

enum KioskStep { idle, verifying, countdown, previewUpload }

/// Fullscreen self-service loop: idle → verify → countdown → upload → idle.
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

  /// Serializes start/stop/dispose so scanner + camera never overlap.
  Future<void> _cameraGate = Future<void>.value();

  KioskStep _step = KioskStep.idle;
  String? _statusMessage;
  bool _busy = false;
  KioskMember? _member;
  Uint8List? _previewBytes;

  CameraController? _cameraController;
  Timer? _countdownTimer;
  int _countdown = KioskConfig.countdownSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rfidFocus.requestFocus();
      unawaited(_startScannerSafely());
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rfidFocus.dispose();
    unawaited(_disposeCamera());
    _scannerController.dispose();
    super.dispose();
  }

  Future<T> _withCameraGate<T>(Future<T> Function() action) {
    final run = _cameraGate.then((_) => action());
    _cameraGate = run.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[CAMERA-DEBUG] cameraGate swallowed error for sequencing');
        debugPrint('[CAMERA-DEBUG] exception type: ${error.runtimeType}');
        debugPrint('[CAMERA-DEBUG] exception message: $error');
        debugPrint('[CAMERA-DEBUG] stack trace:\n$stackTrace');
      },
    );
    return run;
  }

  Future<void> _startScannerSafely() {
    return _withCameraGate(() async {
      debugPrint('[CAMERA-DEBUG] MobileScanner start requested (step=$_step)');
      if (!mounted || _step != KioskStep.idle) {
        debugPrint(
          '[CAMERA-DEBUG] MobileScanner start SKIPPED '
          '(mounted=$mounted step=$_step)',
        );
        return;
      }
      // CameraController must be fully gone before scanner claims the device.
      await _disposeCameraUnlocked();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted || _step != KioskStep.idle) {
        debugPrint(
          '[CAMERA-DEBUG] MobileScanner start SKIPPED after delay '
          '(mounted=$mounted step=$_step)',
        );
        return;
      }
      try {
        debugPrint('[CAMERA-DEBUG] MobileScanner.start() START');
        await _scannerController.start();
        debugPrint('[CAMERA-DEBUG] MobileScanner.start() SUCCESS');
      } catch (e, st) {
        debugPrint('[CAMERA-DEBUG] MobileScanner.start() FAILED');
        debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
        debugPrint('[CAMERA-DEBUG] exception message: $e');
        debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
        // Logged only — idle recovery must not crash the flow.
      }
    });
  }

  Future<void> _stopScannerFully() {
    return _withCameraGate(() async {
      debugPrint('[CAMERA-DEBUG] Disposing/stopping MobileScanner START');
      try {
        await _scannerController.stop();
        debugPrint('[CAMERA-DEBUG] MobileScanner.stop() SUCCESS');
      } catch (e, st) {
        debugPrint('[CAMERA-DEBUG] MobileScanner.stop() FAILED');
        debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
        debugPrint('[CAMERA-DEBUG] exception message: $e');
        debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
        // Still wait for browser release even if stop threw.
      }
      // Give Chrome time to release the MediaStream before CameraController.
      debugPrint('[CAMERA-DEBUG] Waiting 450ms after MobileScanner stop');
      await Future<void>.delayed(const Duration(milliseconds: 450));
      debugPrint('[CAMERA-DEBUG] Disposing/stopping MobileScanner DONE');
    });
  }

  void _logCameraValue(String label, CameraController? controller) {
    if (controller == null) {
      debugPrint('[CAMERA-DEBUG] $label: controller=null');
      return;
    }
    final v = controller.value;
    debugPrint('[CAMERA-DEBUG] $label:');
    debugPrint('[CAMERA-DEBUG]   isInitialized=${v.isInitialized}');
    debugPrint('[CAMERA-DEBUG]   isTakingPicture=${v.isTakingPicture}');
    debugPrint('[CAMERA-DEBUG]   hasError=${v.hasError}');
    debugPrint('[CAMERA-DEBUG]   errorDescription=${v.errorDescription}');
    debugPrint('[CAMERA-DEBUG]   previewSize=${v.previewSize}');
    debugPrint('[CAMERA-DEBUG]   isPreviewPaused=${v.isPreviewPaused}');
  }

  void _onKey(KeyEvent event) {
    if (_step != KioskStep.idle || _busy) return;
    final code = _rfidBuffer.handleKeyEvent(event);
    if (code != null) {
      debugPrint('[CAMERA-DEBUG] RFID code detected from keyboard: $code');
      unawaited(_handleDetectedCode(code, source: 'RFID'));
    }
  }

  void _onQrDetect(BarcodeCapture capture) {
    if (_step != KioskStep.idle || _busy) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;
      debugPrint('[CAMERA-DEBUG] QR code detected: $raw');
      unawaited(_handleDetectedCode(raw, source: 'QR'));
      break;
    }
  }

  Future<void> _handleDetectedCode(String code, {required String source}) async {
    if (_busy || _step != KioskStep.idle) {
      debugPrint(
        '[CAMERA-DEBUG] detect ignored (busy=$_busy step=$_step source=$source)',
      );
      return;
    }
    setState(() {
      _busy = true;
      _step = KioskStep.verifying;
      _statusMessage = 'Memverifikasi $source...';
    });
    debugPrint('[CAMERA-DEBUG] Step -> verifying ($source code=$code)');

    // Unmount MobileScanner (verifying has showScanner=false) then release stream.
    debugPrint('[CAMERA-DEBUG] Waiting endOfFrame before MobileScanner stop');
    await WidgetsBinding.instance.endOfFrame;
    await _stopScannerFully();

    try {
      debugPrint('[CAMERA-DEBUG] verify API START');
      final member = await widget.api.verify(code);
      debugPrint(
        '[CAMERA-DEBUG] RFID verification completed '
        'user=${member.name} uid=${member.rfidUid} userId=${member.userId}',
      );
      if (!mounted) {
        debugPrint('[CAMERA-DEBUG] widget unmounted after verify — abort');
        return;
      }
      setState(() {
        _member = member;
        _statusMessage = 'Halo, ${member.name}!';
      });
      debugPrint('[CAMERA-DEBUG] Halo UI shown for ${member.name}');
      debugPrint('[CAMERA-DEBUG] Starting countdown capture');
      await _startCountdownCapture();
      debugPrint('[CAMERA-DEBUG] _startCountdownCapture() returned');
    } catch (e, st) {
      debugPrint('[CAMERA-DEBUG] verify / post-verify FAILED');
      debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
      debugPrint('[CAMERA-DEBUG] exception message: $e');
      debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
      if (!mounted) return;
      setState(() {
        _step = KioskStep.idle;
        _busy = false;
        _statusMessage = e.toString().replaceFirst('Exception: ', '');
      });
      await _startScannerSafely();
      _rfidFocus.requestFocus();
      Future<void>.delayed(KioskConfig.errorHold, () {
        if (!mounted || _step != KioskStep.idle) return;
        setState(() => _statusMessage = null);
      });
    }
  }

  Future<void> _startCountdownCapture() async {
    debugPrint('[CAMERA-DEBUG] _startCountdownCapture() ENTER');
    try {
      await _withCameraGate(() async {
        debugPrint('[CAMERA-DEBUG] cameraGate acquired for countdown capture');
        // Scanner widget must already be off-tree; ensure no leftover CameraController.
        debugPrint('[CAMERA-DEBUG] Disposing previous CameraController if any');
        await _disposeCameraUnlocked();
        debugPrint('[CAMERA-DEBUG] Waiting 400ms before creating CameraController');
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) {
          debugPrint('[CAMERA-DEBUG] unmounted before availableCameras — abort');
          return;
        }

        debugPrint('[CAMERA-DEBUG] availableCameras() START');
        final cameras = await availableCameras();
        debugPrint('[CAMERA-DEBUG] availableCameras() count=${cameras.length}');
        if (cameras.isEmpty) {
          throw Exception('Kamera tidak tersedia di perangkat ini.');
        }
        for (final c in cameras) {
          debugPrint(
            '[CAMERA-DEBUG] camera option: name=${c.name} '
            'lens=${c.lensDirection.name} sensor=${c.sensorOrientation}',
          );
        }
        final preferred = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        debugPrint(
          '[CAMERA-DEBUG] selected camera: ${preferred.name} '
          '(${preferred.lensDirection.name})',
        );

        debugPrint('[CAMERA-DEBUG] Creating CameraController');
        late final CameraController controller;
        try {
          // On web, avoid ImageFormatGroup.jpeg — it can break initialize/takePicture.
          controller = CameraController(
            preferred,
            kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
            enableAudio: false,
            imageFormatGroup: kIsWeb ? null : ImageFormatGroup.jpeg,
          );
          debugPrint(
            '[CAMERA-DEBUG] CameraController created '
            '(preset=${kIsWeb ? 'medium' : 'high'} kIsWeb=$kIsWeb)',
          );
          _logCameraValue('after create (before initialize)', controller);
        } catch (e, st) {
          debugPrint('[CAMERA-DEBUG] Creating CameraController FAILED');
          debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
          debugPrint('[CAMERA-DEBUG] exception message: $e');
          debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
          rethrow;
        }

        try {
          debugPrint('[CAMERA-DEBUG] Camera initialization START');
          await controller.initialize();
          debugPrint('[CAMERA-DEBUG] Camera initialization SUCCESS');
          debugPrint(
            '[CAMERA-DEBUG] Camera initialized: ${controller.value.isInitialized}',
          );
          _logCameraValue('after initialize()', controller);
        } catch (e, st) {
          debugPrint('[CAMERA-DEBUG] Camera initialization FAILED');
          debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
          debugPrint('[CAMERA-DEBUG] exception message: $e');
          debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
          _logCameraValue('after initialize() failure', controller);
          try {
            await controller.dispose();
          } catch (disposeError, disposeSt) {
            debugPrint('[CAMERA-DEBUG] dispose after failed init FAILED');
            debugPrint('[CAMERA-DEBUG] exception type: ${disposeError.runtimeType}');
            debugPrint('[CAMERA-DEBUG] exception message: $disposeError');
            debugPrint('[CAMERA-DEBUG] stack trace:\n$disposeSt');
          }
          rethrow;
        }

        if (!mounted) {
          debugPrint('[CAMERA-DEBUG] unmounted after initialize — disposing');
          await controller.dispose();
          return;
        }

        setState(() {
          _cameraController = controller;
          _step = KioskStep.countdown;
          _countdown = KioskConfig.countdownSeconds;
          _busy = false;
          _statusMessage = 'Posisikan wajah Anda di dalam bingkai';
        });
        debugPrint('[CAMERA-DEBUG] Step -> countdown');
        debugPrint('[CAMERA-DEBUG] Countdown START');
        debugPrint('[CAMERA-DEBUG] Countdown: $_countdown');

        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            debugPrint('[CAMERA-DEBUG] Countdown aborted (unmounted)');
            timer.cancel();
            return;
          }
          if (_countdown <= 1) {
            timer.cancel();
            debugPrint('[CAMERA-DEBUG] Countdown: 1');
            debugPrint('[CAMERA-DEBUG] Countdown finished');
            unawaited(_snapAndUpload());
          } else {
            setState(() => _countdown -= 1);
            debugPrint('[CAMERA-DEBUG] Countdown: $_countdown');
          }
        });
      });
    } catch (e, st) {
      debugPrint('[CAMERA-DEBUG] _startCountdownCapture() FAILED');
      debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
      debugPrint('[CAMERA-DEBUG] exception message: $e');
      debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
      await _failAndReset(e.toString());
    }
  }

  Future<void> _snapAndUpload() async {
    debugPrint('[CAMERA-DEBUG] _snapAndUpload() ENTER');
    final member = _member;
    final camera = _cameraController;
    _logCameraValue('before takePicture checks', camera);

    if (member == null) {
      debugPrint('[CAMERA-DEBUG] takePicture() SKIPPED — member is null');
      await _failAndReset('Kamera belum siap.');
      return;
    }
    if (camera == null) {
      debugPrint('[CAMERA-DEBUG] takePicture() SKIPPED — camera controller is null');
      await _failAndReset('Kamera belum siap.');
      return;
    }
    if (!camera.value.isInitialized) {
      debugPrint('[CAMERA-DEBUG] takePicture() SKIPPED — isInitialized=false');
      _logCameraValue('not initialized', camera);
      await _failAndReset('Kamera belum siap.');
      return;
    }

    setState(() {
      _busy = true;
      _statusMessage = 'Mengambil foto...';
      _countdown = 0;
    });

    try {
      debugPrint('[CAMERA-DEBUG] takePicture() START');
      _logCameraValue('takePicture() START', camera);
      final file = await camera.takePicture();
      debugPrint('[CAMERA-DEBUG] takePicture() SUCCESS path=${file.path}');
      final bytes = await file.readAsBytes();
      debugPrint('[CAMERA-DEBUG] readAsBytes() SUCCESS bytes=${bytes.length}');

      // Release CameraController immediately after capture (preview uses bytes).
      debugPrint('[CAMERA-DEBUG] Disposing CameraController after capture');
      await _disposeCamera();

      if (!mounted) {
        debugPrint('[CAMERA-DEBUG] unmounted after capture — abort upload');
        return;
      }

      setState(() {
        _previewBytes = bytes;
        _step = KioskStep.previewUpload;
        _statusMessage = 'Mengunggah foto ke galeri...';
      });
      debugPrint('[CAMERA-DEBUG] Step -> previewUpload, upload START');

      await widget.api.uploadPhoto(
        code: member.rfidUid,
        userId: member.userId,
        bytes: bytes,
        filename: 'kiosk_${member.rfidUid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      debugPrint('[CAMERA-DEBUG] uploadPhoto() SUCCESS');

      if (!mounted) return;
      setState(() => _statusMessage = 'Berhasil! Terima kasih, ${member.name}.');

      await Future<void>.delayed(KioskConfig.previewHold);
      await _resetToIdle();
      debugPrint('[CAMERA-DEBUG] reset to idle after successful upload');
    } catch (e, st) {
      debugPrint('[CAMERA-DEBUG] takePicture() FAILED / upload FAILED');
      debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
      debugPrint('[CAMERA-DEBUG] exception message: $e');
      debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
      _logCameraValue('after takePicture/upload failure', _cameraController);
      await _failAndReset(e.toString());
    }
  }

  Future<void> _failAndReset(String message) async {
    debugPrint('[CAMERA-DEBUG] _failAndReset message=$message');
    if (!mounted) return;
    _countdownTimer?.cancel();
    setState(() {
      _step = KioskStep.idle;
      _busy = false;
      _statusMessage = message.replaceFirst('Exception: ', '');
      _member = null;
      _previewBytes = null;
    });
    await _disposeCamera();
    await _startScannerSafely();
    _rfidFocus.requestFocus();
    Future<void>.delayed(KioskConfig.errorHold, () {
      if (!mounted || _step != KioskStep.idle) return;
      setState(() => _statusMessage = null);
    });
  }

  Future<void> _resetToIdle() async {
    debugPrint('[CAMERA-DEBUG] _resetToIdle()');
    _countdownTimer?.cancel();
    await _disposeCamera();
    if (!mounted) return;
    setState(() {
      _step = KioskStep.idle;
      _busy = false;
      _member = null;
      _previewBytes = null;
      _statusMessage = null;
      _countdown = KioskConfig.countdownSeconds;
    });
    await _startScannerSafely();
    _rfidFocus.requestFocus();
  }

  Future<void> _disposeCamera() {
    return _withCameraGate(_disposeCameraUnlocked);
  }

  Future<void> _disposeCameraUnlocked() async {
    final cam = _cameraController;
    _cameraController = null;
    if (cam == null) {
      debugPrint('[CAMERA-DEBUG] CameraController dispose skipped (null)');
      return;
    }
    debugPrint('[CAMERA-DEBUG] CameraController.dispose() START');
    _logCameraValue('before dispose', cam);
    try {
      await cam.dispose();
      debugPrint('[CAMERA-DEBUG] CameraController.dispose() SUCCESS');
    } catch (e, st) {
      debugPrint('[CAMERA-DEBUG] CameraController.dispose() FAILED');
      debugPrint('[CAMERA-DEBUG] exception type: ${e.runtimeType}');
      debugPrint('[CAMERA-DEBUG] exception message: $e');
      debugPrint('[CAMERA-DEBUG] stack trace:\n$st');
      // Logged — continue delay so browser can still release the device.
    }
    // Browser needs a beat before another getUserMedia call.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    debugPrint('[CAMERA-DEBUG] post-dispose delay done');
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _rfidFocus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        body: SafeArea(
          child: switch (_step) {
            KioskStep.idle => _IdleView(
                scannerController: _scannerController,
                onDetect: _onQrDetect,
                showScanner: true,
                verifying: false,
                statusMessage: _statusMessage,
              ),
            // Critical on Chrome: do NOT keep MobileScanner mounted while
            // CameraController.initialize() runs after RFID verify.
            KioskStep.verifying => _IdleView(
                scannerController: _scannerController,
                onDetect: _onQrDetect,
                showScanner: false,
                verifying: true,
                statusMessage: _statusMessage,
              ),
            KioskStep.countdown => _CountdownView(
                controller: _cameraController,
                countdown: _countdown,
                memberName: _member?.name,
                statusMessage: _statusMessage,
              ),
            KioskStep.previewUpload => _PreviewView(
                bytes: _previewBytes,
                statusMessage: _statusMessage,
                uploading: _busy,
              ),
          },
        ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({
    required this.scannerController,
    required this.onDetect,
    required this.showScanner,
    required this.verifying,
    this.statusMessage,
  });

  final MobileScannerController scannerController;
  final void Function(BarcodeCapture capture) onDetect;
  final bool showScanner;
  final bool verifying;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return KioskFrame(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'KIOS FOTO RFID',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan Tempel Kartu RFID Anda\nATAU Arahkan QR Code Aplikasi HP ke Kamera',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: KioskColors.muted,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: KioskColors.panel,
                    child: showScanner
                        ? MobileScanner(
                            controller: scannerController,
                            onDetect: onDetect,
                          )
                        : const SizedBox.expand(),
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: KioskColors.primary.withValues(alpha: 0.55),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                  if (verifying)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.55),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _StatusBanner(
            message: statusMessage ??
                'Menunggu kartu RFID USB atau QR Code digital...',
            tone: statusMessage != null && !verifying
                ? _BannerTone.danger
                : _BannerTone.neutral,
          ),
        ],
      ),
    );
  }
}

class _CountdownView extends StatelessWidget {
  const _CountdownView({
    required this.controller,
    required this.countdown,
    this.memberName,
    this.statusMessage,
  });

  final CameraController? controller;
  final int countdown;
  final String? memberName;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final ready = controller != null && controller!.value.isInitialized;
    return KioskFrame(
      child: Column(
        children: [
          Text(
            memberName == null ? 'Bersiap...' : 'Halo, $memberName!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage ?? 'Tahan posisi wajah Anda',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: KioskColors.muted,
                ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
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
                      color: KioskColors.panel,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  Center(
                    child: Text(
                      countdown <= 0 ? 'SNAP!' : '$countdown',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 120,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: const [
                              Shadow(blurRadius: 24, color: Colors.black54),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({
    required this.bytes,
    required this.uploading,
    this.statusMessage,
  });

  final Uint8List? bytes;
  final bool uploading;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return KioskFrame(
      child: Column(
        children: [
          Text(
            'Hasil Foto',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: bytes == null
                  ? const ColoredBox(color: KioskColors.panel)
                  : Image.memory(bytes!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 20),
          _StatusBanner(
            message: statusMessage ?? (uploading ? 'Mengunggah...' : 'Selesai'),
            tone: uploading ? _BannerTone.neutral : _BannerTone.success,
            showSpinner: uploading,
          ),
        ],
      ),
    );
  }
}

enum _BannerTone { neutral, success, danger }

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    this.tone = _BannerTone.neutral,
    this.showSpinner = false,
  });

  final String message;
  final _BannerTone tone;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tone) {
      _BannerTone.success => KioskColors.success.withValues(alpha: 0.18),
      _BannerTone.danger => KioskColors.danger.withValues(alpha: 0.18),
      _BannerTone.neutral => Colors.white.withValues(alpha: 0.08),
    };
    final fg = switch (tone) {
      _BannerTone.success => KioskColors.success,
      _BannerTone.danger => const Color(0xFFFFB4B4),
      _BannerTone.neutral => KioskColors.text,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (showSpinner) ...[
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
