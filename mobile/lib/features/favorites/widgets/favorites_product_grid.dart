import 'package:flutter/material.dart';

import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_product_card.dart';
import '../../../shared/widgets/app_product_grid.dart';
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
    return AppProductGrid(
      itemCount: items.length,
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
          priceLabel: formatMoney(product.displayPrice, currency: product.currency),
          imageUrl: hasImage ? product.primaryImage : null,
          isFavorite: true,
          onTap: () =>
              FavoritesNavigation.openFavoriteProduct(context, favorite),
          onFavoriteTap: () => onRemove(favorite),
        );
      },
    );
  }
}
