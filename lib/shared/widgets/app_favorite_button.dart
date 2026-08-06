import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';

/// Circular favorite toggle overlay used on product cards and detail.
class AppFavoriteButton extends StatelessWidget {
  const AppFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onPressed,
    this.size = AppSizes.favoriteButton,
    this.backgroundColor,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final label = isFavorite ? 'Remove from favorites' : 'Add to favorites';

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: AppSizes.minTapTarget,
          height: AppSizes.minTapTarget,
          child: Center(
            child: Material(
              color: backgroundColor ?? AppColors.white.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: size * 0.55,
                    color: isFavorite
                        ? AppColors.favorite
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
