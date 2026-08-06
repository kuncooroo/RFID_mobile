import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import 'face_scan_brackets.dart';

/// Step 2 — Hold still with camera preview, landmarks, and progress.
class FaceHoldStillView extends StatelessWidget {
  const FaceHoldStillView({
    super.key,
    required this.progress,
    required this.onBack,
  });

  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8DFD4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SimulatedCameraFeed(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.34,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE8DFD4),
                    const Color(0xFFE8DFD4).withValues(alpha: 0.92),
                    const Color(0xFFE8DFD4).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    tooltip: 'Back',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 26),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Hold still',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Look directly into the camera while we do the magic',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(flex: 2),
                  const Center(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FaceScanBrackets(
                            size: 248,
                            color: Colors.white,
                            strokeWidth: 3.5,
                            cornerLength: 42,
                          ),
                          _FaceLandmarks(),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  _ScanProgressBar(progress: progress),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanProgressBar extends StatelessWidget {
  const _ScanProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0x66FFFFFF)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: const ColoredBox(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceLandmarks extends StatelessWidget {
  const _FaceLandmarks();

  static const _points = <Offset>[
    Offset(0.50, 0.28),
    Offset(0.38, 0.40),
    Offset(0.62, 0.40),
    Offset(0.50, 0.48),
    Offset(0.50, 0.58),
    Offset(0.36, 0.55),
    Offset(0.64, 0.55),
    Offset(0.42, 0.70),
    Offset(0.58, 0.70),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            for (final p in _points)
              Positioned(
                left: p.dx * constraints.maxWidth - 4,
                top: p.dy * constraints.maxHeight - 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SimulatedCameraFeed extends StatelessWidget {
  const _SimulatedCameraFeed();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEDE4D8),
            Color(0xFFD9CBBA),
            Color(0xFFBFAE97),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _SoftFacePainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _SoftFacePainter extends CustomPainter {
  const _SoftFacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.58;

    final head = Paint()..color = const Color(0xFFD2B39A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.55,
        height: size.height * 0.42,
      ),
      head,
    );

    final hair = Paint()..color = const Color(0xFF3A2E28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - size.height * 0.14),
        width: size.width * 0.58,
        height: size.height * 0.22,
      ),
      hair,
    );

    final feature = Paint()..color = const Color(0xFF5A4638);
    canvas.drawCircle(Offset(cx - 36, cy - 10), 6, feature);
    canvas.drawCircle(Offset(cx + 36, cy - 10), 6, feature);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 18), width: 18, height: 28),
      feature,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 48), width: 48, height: 28),
      0.15,
      2.8,
      false,
      Paint()
        ..color = const Color(0xFF8B5E4B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
