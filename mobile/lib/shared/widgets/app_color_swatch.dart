import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';

/// Circular color swatch selector for Product Detail and Filter sheet.
class AppColorSwatch extends StatelessWidget {
  const AppColorSwatch({
    super.key,
    required this.color,
    this.selected = false,
    this.onTap,
    this.size = AppSizes.colorSwatch,
  });

  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check_rounded,
                size: size * 0.55,
                color: _contrastOn(color),
              )
            : null,
      ),
    );
  }

  Color _contrastOn(Color background) {
    return background.computeLuminance() > 0.55
        ? AppColors.textPrimary
        : AppColors.white;
  }
}
