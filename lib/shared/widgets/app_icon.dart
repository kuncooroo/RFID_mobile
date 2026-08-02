import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';

enum AppIconSource { asset, material }

/// Reusable icon that renders an SVG asset or a Material [IconData].
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    this.assetPath,
    this.icon,
    this.size = AppSizes.iconMd,
    this.color,
    this.fit = BoxFit.contain,
  }) : assert(
         assetPath != null || icon != null,
         'Provide either assetPath or icon.',
       );

  const AppIcon.asset(
    this.assetPath, {
    super.key,
    this.size = AppSizes.iconMd,
    this.color,
    this.fit = BoxFit.contain,
  }) : icon = null;

  const AppIcon.data(
    this.icon, {
    super.key,
    this.size = AppSizes.iconMd,
    this.color,
    this.fit = BoxFit.contain,
  }) : assetPath = null;

  final String? assetPath;
  final IconData? icon;
  final double size;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColors.textPrimary;

    if (assetPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          assetPath!,
          width: size,
          height: size,
          fit: fit,
          colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
        ),
      );
    }

    return Icon(icon, size: size, color: resolvedColor);
  }
}
