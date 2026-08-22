import 'package:flutter/material.dart';

import '../l10n/kiosk_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum RfidScanState { ready, reading, processing, success, error }

/// RFID tap zone — white bordered area with card + wave icon.
class RfidScanArea extends StatelessWidget {
  const RfidScanArea({
    super.key,
    required this.strings,
    this.state = RfidScanState.ready,
    this.title,
    this.description,
  });

  final KioskStrings strings;
  final RfidScanState state;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final processing = state == RfidScanState.processing ||
        state == RfidScanState.reading;
    final narrow = MediaQuery.sizeOf(context).width < 640;
    final titleText = title ??
        (processing ? strings.scanReadingTitle : strings.scanRfidTitle);
    final descText = description ??
        (processing ? strings.scanReadingDesc : strings.scanRfidDesc);
    final titleSize =
        AppSpacing.scale(context, narrow ? 23 : 27).clamp(20.0, 28.0);
    final descSize =
        AppSpacing.scale(context, narrow ? 15 : 17).clamp(13.0, 17.0);
    final iconSize =
        AppSpacing.scale(context, 112).clamp(72.0, 112.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final zoneW = maxW.clamp(0.0, 430.0);

        return Container(
          width: zoneW,
          constraints: BoxConstraints(
            maxWidth: 430,
            minHeight: zoneW * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDEDEDE)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: narrow ? 16 : 30,
            vertical: narrow ? 22 : 28,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: CustomPaint(
                  painter: _RfidIconPainter(active: processing),
                ),
              ),
              SizedBox(height: AppSpacing.vGap(context, 18, min: 12, max: 18)),
              Text(
                titleText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  descText,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: descSize,
                    height: 1.45,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RfidIconPainter extends CustomPainter {
  _RfidIconPainter({required this.active});

  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Card (rotated slightly).
    canvas.save();
    canvas.translate(size.width * 0.28, size.height * 0.22);
    canvas.rotate(-0.14);
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * 0.38, size.height * 0.53),
      Radius.circular(size.width * 0.055),
    );
    canvas.drawRRect(card, stroke);
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.38),
      Offset(size.width * 0.30, size.height * 0.38),
      stroke,
    );
    canvas.restore();

    // Wave arcs.
    final wave = Paint()
      ..color = const Color(0xFF111111).withValues(alpha: active ? 0.95 : 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.52, size.height * 0.48),
        radius: size.width * 0.22,
      ),
      -1.1,
      1.6,
      false,
      wave,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.52, size.height * 0.48),
        radius: size.width * 0.34,
      ),
      -1.15,
      1.7,
      false,
      wave..color = const Color(0xFF111111).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _RfidIconPainter oldDelegate) =>
      oldDelegate.active != active;
}

/// Backward-compatible alias.
class RfidVisual extends StatelessWidget {
  const RfidVisual({super.key, this.processing = false, this.strings});

  final bool processing;
  final KioskStrings? strings;

  @override
  Widget build(BuildContext context) {
    return RfidScanArea(
      strings: strings ?? const KioskStrings(KioskLang.en),
      state: processing ? RfidScanState.processing : RfidScanState.ready,
    );
  }
}
