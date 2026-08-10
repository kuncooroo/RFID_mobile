import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';

/// Step 2 — Realistic camera capture + RFID status overlay.
class FaceHoldStillView extends StatefulWidget {
  const FaceHoldStillView({
    super.key,
    required this.progress,
    required this.onBack,
    required this.onCapture,
    this.rfidUid,
    this.isSubmitting = false,
  });

  final double progress;
  final String? rfidUid;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onCapture;

  @override
  State<FaceHoldStillView> createState() => _FaceHoldStillViewState();
}

class _FaceHoldStillViewState extends State<FaceHoldStillView>
    with SingleTickerProviderStateMixin {
  static const _titleColor = Color(0xFF1E1E1E);
  static const _subtitleColor = Color(0xFF6B7280);
  static const _accent = Color(0xFF5B50C6);
  static const _surface = Color(0xFFF9FAFB);
  static const _success = Color(0xFF16A34A);

  late final AnimationController _scanController;

  bool get _hasRfid =>
      widget.rfidUid != null && widget.rfidUid!.trim().isNotEmpty;

  bool get _canCapture => _hasRfid && !widget.isSubmitting;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  onPressed: widget.isSubmitting ? null : widget.onBack,
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
                  scanAnimation: _scanController,
                  accent: _accent,
                  hasRfid: _hasRfid,
                  rfidUid: widget.rfidUid,
                  successColor: _success,
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
                  onPressed: _canCapture ? widget.onCapture : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: widget.isSubmitting
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

/// Smartphone-ratio rounded camera preview with brackets + RFID badge.
class _CameraViewport extends StatelessWidget {
  const _CameraViewport({
    required this.scanAnimation,
    required this.accent,
    required this.hasRfid,
    required this.successColor,
    this.rfidUid,
  });

  final Animation<double> scanAnimation;
  final Color accent;
  final bool hasRfid;
  final Color successColor;
  final String? rfidUid;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Portrait camera frame ~ 3:4, capped by available height.
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Camera body
                Positioned.fill(
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
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF1F2937),
                                  Color(0xFF111827),
                                  Color(0xFF030712),
                                ],
                              ),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(0, -0.15),
                                radius: 0.95,
                                colors: [
                                  Colors.white.withValues(alpha: 0.07),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.45),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                          // Soft face-guide silhouette (no cartoon face)
                          Center(
                            child: Container(
                              width: width * 0.52,
                              height: height * 0.58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(width * 0.26),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Scan line
                          AnimatedBuilder(
                            animation: scanAnimation,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _ScanLinePainter(
                                  progress: scanAnimation.value,
                                  color: accent,
                                ),
                              );
                            },
                          ),
                          // Corner brackets (full rectangle frame)
                          const Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(14),
                              child: CustomPaint(
                                painter: _RectBracketsPainter(
                                  color: Color(0xEBFFFFFF),
                                  strokeWidth: 2.5,
                                  cornerLength: 28,
                                ),
                              ),
                            ),
                          ),
                          // Purple outer rim hint
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
                // RFID status badge — top center overlay
                Positioned(
                  top: 14,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: _RfidStatusBadge(
                      hasRfid: hasRfid,
                      rfidUid: rfidUid,
                      accent: accent,
                      successColor: successColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RfidStatusBadge extends StatelessWidget {
  const _RfidStatusBadge({
    required this.hasRfid,
    required this.accent,
    required this.successColor,
    this.rfidUid,
  });

  final bool hasRfid;
  final Color accent;
  final Color successColor;
  final String? rfidUid;

  @override
  Widget build(BuildContext context) {
    final bg = hasRfid ? successColor : const Color(0xCC111827);
    final fg = Colors.white;
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
          color: hasRfid
              ? Colors.white.withValues(alpha: 0.2)
              : accent.withValues(alpha: 0.45),
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

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (0.12 + progress * 0.76);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, y, size.width * 0.8, 2),
      Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y, size.width, 2)),
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, y - 14, size.width * 0.76, 28),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y - 14, size.width, 28)),
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _RectBracketsPainter extends CustomPainter {
  const _RectBracketsPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx + dx * cornerLength, origin.dy)
        ..lineTo(origin.dx, origin.dy)
        ..lineTo(origin.dx, origin.dy + dy * cornerLength);
      canvas.drawPath(path, paint);
    }

    corner(Offset.zero, 1, 1);
    corner(Offset(size.width, 0), -1, 1);
    corner(Offset(0, size.height), 1, -1);
    corner(Offset(size.width, size.height), -1, -1);
  }

  @override
  bool shouldRepaint(covariant _RectBracketsPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.cornerLength != cornerLength;
}
