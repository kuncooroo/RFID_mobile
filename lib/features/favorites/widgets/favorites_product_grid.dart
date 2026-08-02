import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_product_card.dart';
import '../../product/models/product.dart';
import '../models/favorite.dart';
import '../navigation/favorites_navigation.dart';

class FavoritesProductGrid extends StatelessWidget {
  const FavoritesProductGrid({
    super.key,
    required this.items,
    required this.onRemove,
  });

  final List<Favorite> items;
  final ValueChanged<Favorite> onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppSizes.productGridCrossAxisCount,
          mainAxisSpacing: AppSpacing.grid,
          crossAxisSpacing: AppSpacing.grid,
          childAspectRatio: AppSizes.productGridAspectRatio,
        ),
        itemBuilder: (context, index) {
          final favorite = items[index];
          final product =
              favorite.product ??
              Product(
                id: favorite.productId,
                name: 'Product',
                price: 0,
                isFavorite: true,
              );

          final hasImage = product.primaryImage.isNotEmpty;

          return AppProductCard(
            name: product.name,
            brand: product.brand,
            priceLabel: _priceLabel(product),
            imageUrl: hasImage ? product.primaryImage : null,
            assetPath: hasImage ? null : AppAssets.placeholderProduct,
            isFavorite: true,
            onTap: () =>
                FavoritesNavigation.openFavoriteProduct(context, favorite),
            onFavoriteTap: () => onRemove(favorite),
          );
        },
      ),
    );
  }

  String _priceLabel(Product product) {
    final currency = product.currency == 'USD' ? '\$' : '${product.currency} ';
    return '$currency${product.displayPrice.toStringAsFixed(0)}';
  }
}
