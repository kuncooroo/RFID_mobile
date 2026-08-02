import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/text_styles.dart';

/// Count or dot badge for notifications, cart, and tab items.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    this.count,
    this.showDot = false,
    this.child,
    this.color = AppColors.badge,
    this.maxCount = 99,
    this.offset = const Offset(2, -2),
  });

  /// Dot-only badge (Home notification bell).
  const AppBadge.dot({
    super.key,
    this.child,
    this.color = AppColors.badge,
    this.offset = const Offset(2, -2),
  }) : count = null,
       showDot = true,
       maxCount = 99;

  final int? count;
  final bool showDot;
  final Widget? child;
  final Color color;
  final int maxCount;
  final Offset offset;

  bool get _visible => showDot || (count != null && count! > 0);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return _visible ? _badge() : const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child!,
        if (_visible)
          Positioned(right: offset.dx, top: offset.dy, child: _badge()),
      ],
    );
  }

  Widget _badge() {
    if (showDot && count == null) {
      return Container(
        width: AppSizes.badge,
        height: AppSizes.badge,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    final label = (count ?? 0) > maxCount ? '$maxCount+' : '${count ?? 0}';

    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
          fontSize: 10,
          height: 1.2,
        ),
      ),
    );
  }
}
