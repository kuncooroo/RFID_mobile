import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../design_system/app_assets.dart';
import '../design_system/colors.dart';
import '../design_system/radius.dart';
import 'app_loading.dart';

/// Cached network / asset image with consistent placeholders.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  }) : assert(
         imageUrl != null || assetPath != null,
         'Provide either imageUrl or assetPath.',
       );

  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.card;

    Widget child;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (_, __) =>
            placeholder ?? const ColoredBox(color: AppColors.surfaceMuted),
        errorWidget: (_, __, ___) =>
            errorWidget ?? _ErrorFallback(width: width, height: height),
      );
    } else {
      child = Image.asset(
        assetPath ?? AppAssets.placeholderProduct,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            errorWidget ?? _ErrorFallback(width: width, height: height),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: child),
    );
  }
}

class _ErrorFallback extends StatelessWidget {
  const _ErrorFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: Icon(Icons.image_outlined, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

/// Full-bleed shimmer-style loading box for image slots.
class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.card,
      child: ColoredBox(
        color: AppColors.surfaceMuted,
        child: SizedBox(
          width: width,
          height: height,
          child: const Center(child: AppLoading(size: 20)),
        ),
      ),
    );
  }
}
