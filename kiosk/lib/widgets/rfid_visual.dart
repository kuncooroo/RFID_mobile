import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RfidVisual extends StatefulWidget {
  const RfidVisual({super.key, this.processing = false});

  final bool processing;

  @override
  State<RfidVisual> createState() => _RfidVisualState();
}

class _RfidVisualState extends State<RfidVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 42,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white70),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final delay = i / 3;
                final wave = ((t + delay) % 1.0);
                final opacity = widget.processing
                    ? 0.35
                    : (1 - wave).clamp(0.2, 0.85);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.wifi_rounded,
                    size: 22 + i * 4,
                    color: AppColors.primary.withValues(alpha: opacity),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            const Text(
              'RFID',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}
