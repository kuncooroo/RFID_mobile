import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';

/// Step 2 — Live front camera + USB RFID keyboard-wedge capture.
class FaceHoldStillView extends StatefulWidget {
  const FaceHoldStillView({
    super.key,
    required this.progress,
    required this.onBack,
    required this.onRfidCaptured,
    required this.onCapture,
    this.rfidUid,
    this.isSubmitting = false,
  });

  final double progress;
  final String? rfidUid;
  final bool isSubmitting;
  final VoidCallback onBack;
  final ValueChanged<String> onRfidCaptured;
  final Future<void> Function(String imagePath, String rfidUid) onCapture;

  @override
  State<FaceHoldStillView> createState() => _FaceHoldStillViewState();
}

class _FaceHoldStillViewState extends State<FaceHoldStillView> {
  static const _titleColor = Color(0xFF1E1E1E);
  static const _subtitleColor = Color(0xFF6B7280);
  static const _accent = Color(0xFF5B50C6);
  static const _surface = Color(0xFFF9FAFB);
  static const _success = Color(0xFF16A34A);
  static const _waitingBadge = Color(0xCC111827);

  final FocusNode _rfidFocusNode = FocusNode(debugLabel: 'rfidUsbReader');
  final StringBuffer _rfidBuffer = StringBuffer();

  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _cameraInitializing = true;
  String? _cameraError;
  bool _capturing = false;

  bool get _hasRfid =>
      widget.rfidUid != null && widget.rfidUid!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _rfidFocusNode.requestFocus();
    });
    unawaited(_initFrontCamera());
  }

  Future<void> _initFrontCamera() async {
    setState(() {
      _cameraInitializing = true;
      _cameraError = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('NoCamera', 'No cameras available on this device.');
      }

      final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _cameraReady = true;
        _cameraInitializing = false;
      });

      _rfidFocusNode.requestFocus();
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _cameraReady = false;
        _cameraInitializing = false;
        _cameraError = error.description ?? error.code;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cameraReady = false;
        _cameraInitializing = false;
        _cameraError = error.toString();
      });
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final uid = _rfidBuffer.toString().trim();
      _rfidBuffer.clear();
      if (uid.isEmpty) return;

      widget.onRfidCaptured(uid);
      return;
    }

    final character = event.character;
    if (character == null || character.isEmpty) return;
    if (character == '\n' || character == '\r') return;

    // USB RFID readers typically emit printable UID characters then Enter.
    if (character.length == 1 && character.codeUnitAt(0) >= 32) {
      _rfidBuffer.write(character);
    }
  }

  Future<void> _onCapturePressed() async {
    if (widget.isSubmitting || _capturing) return;

    if (!_cameraReady ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      _showWarning('Camera is not ready yet. Please wait or allow camera access.');
      _rfidFocusNode.requestFocus();
      return;
    }

    if (!_hasRfid) {
      _showWarning('Please tap an RFID card first.');
      _rfidFocusNode.requestFocus();
      return;
    }

    final uid = widget.rfidUid!.trim();
    setState(() => _capturing = true);

    try {
      final photo = await _cameraController!.takePicture();
      debugPrint('RFID Captured UID: $uid');
      debugPrint('Face image path: ${photo.path}');
      await widget.onCapture(photo.path, uid);
    } catch (error) {
      if (!mounted) return;
      _showWarning('Failed to capture photo: $error');
    } finally {
      if (mounted) setState(() => _capturing = false);
      _rfidFocusNode.requestFocus();
    }
  }

  void _showWarning(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF111827),
      ),
    );
  }

  @override
  void dispose() {
    _rfidFocusNode.dispose();
    final camera = _cameraController;
    _cameraController = null;
    unawaited(camera?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.isSubmitting || _capturing;

    return KeyboardListener(
      focusNode: _rfidFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: _surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Back',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    onPressed: busy ? null : widget.onBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 24,
                      color: _titleColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Position Your Face',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: _titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Hold still while we capture face and scan RFID card',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _subtitleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(
                  child: _CameraViewport(
                    controller: _cameraController,
                    cameraReady: _cameraReady,
                    initializing: _cameraInitializing,
                    errorMessage: _cameraError,
                    hasRfid: _hasRfid,
                    rfidUid: widget.rfidUid,
                    accent: _accent,
                    successColor: _success,
                    waitingColor: _waitingBadge,
                    onRetryCamera: () => unawaited(_initFrontCamera()),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ScanProgressBar(
                  progress: widget.progress,
                  accent: _accent,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: busy ? null : _onCapturePressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      disabledBackgroundColor:
                          _accent.withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Capture & Save',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanProgressBar extends StatelessWidget {
  const _ScanProgressBar({
    required this.progress,
    required this.accent,
  });

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFFE5E7EB)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: ColoredBox(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded rectangular live camera viewport (no oval overlay).
class _CameraViewport extends StatelessWidget {
  const _CameraViewport({
    required this.controller,
    required this.cameraReady,
    required this.initializing,
    required this.hasRfid,
    required this.accent,
    required this.successColor,
    required this.waitingColor,
    required this.onRetryCamera,
    this.errorMessage,
    this.rfidUid,
  });

  final CameraController? controller;
  final bool cameraReady;
  final bool initializing;
  final String? errorMessage;
  final bool hasRfid;
  final Color accent;
  final Color successColor;
  final Color waitingColor;
  final String? rfidUid;
  final VoidCallback onRetryCamera;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        var width = maxW;
        var height = width * 4 / 3;
        if (height > maxH) {
          height = maxH;
          width = height * 3 / 4;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Color(0xFF111827)),
                    if (cameraReady &&
                        controller != null &&
                        controller!.value.isInitialized)
                      _LiveCameraPreview(controller: controller!)
                    else
                      _CameraPlaceholder(
                        initializing: initializing,
                        errorMessage: errorMessage,
                        onRetry: onRetryCamera,
                      ),
                    Positioned(
                      top: 14,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: _RfidStatusBadge(
                          hasRfid: hasRfid,
                          rfidUid: rfidUid,
                          waitingColor: waitingColor,
                          successColor: successColor,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiveCameraPreview extends StatelessWidget {
  const _LiveCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Color(0xFF111827));
    }

    // CameraPreview reports size in landscape; rotate for portrait frame.
    final previewAspect = previewSize.height / previewSize.width;

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: AspectRatio(
          aspectRatio: previewAspect,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({
    required this.initializing,
    required this.onRetry,
    this.errorMessage,
  });

  final bool initializing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111827),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (initializing) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Starting camera...',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ] else ...[
                const Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white70,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? 'Camera unavailable',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RfidStatusBadge extends StatelessWidget {
  const _RfidStatusBadge({
    required this.hasRfid,
    required this.waitingColor,
    required this.successColor,
    this.rfidUid,
  });

  final bool hasRfid;
  final Color waitingColor;
  final Color successColor;
  final String? rfidUid;

  @override
  Widget build(BuildContext context) {
    final bg = hasRfid ? successColor : waitingColor;
    const fg = Colors.white;
    final label = hasRfid
        ? 'RFID Captured: ${rfidUid ?? ''}'
        : 'Waiting for RFID Card tap...';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: hasRfid ? 0.2 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasRfid ? Icons.check_circle_rounded : Icons.nfc_rounded,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
