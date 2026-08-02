import 'package:flutter/material.dart';

import '../design_system/radius.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';
import 'app_favorite_button.dart';
import 'app_image.dart';

/// Product card used on Home, Search, Store, and Favorites grids.
class AppProductCard extends StatelessWidget {
  const AppProductCard({
    super.key,
    required this.name,
    required this.priceLabel,
    this.brand,
    this.imageUrl,
    this.assetPath,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  final String name;
  final String priceLabel;
  final String? brand;
  final String? imageUrl;
  final String? assetPath;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppImage(
                    imageUrl: imageUrl,
                    assetPath: assetPath,
                    borderRadius: AppRadius.card,
                  ),
                ),
                if (onFavoriteTap != null)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: AppFavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: onFavoriteTap,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.productName,
          ),
          if (brand != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              brand!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.productBrand,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(priceLabel, style: AppTextStyles.price),
        ],
      ),
    );
  }
}
