import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';
import 'app_image.dart';

/// Promotional banner card used in the Home carousel.
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.assetPath,
    this.backgroundColor = AppColors.primarySoft,
    this.onTap,
    this.height = AppSizes.promoCarouselHeight,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? assetPath;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (imageUrl != null || assetPath != null)
            SizedBox(
              width: height * 0.75,
              height: height,
              child: AppImage(
                imageUrl: imageUrl,
                assetPath: assetPath,
                width: height * 0.75,
                height: height,
                borderRadius: BorderRadius.zero,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: content,
      ),
    );
  }
}
