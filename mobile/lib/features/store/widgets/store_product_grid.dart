import 'package:flutter/material.dart';

import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_product_card.dart';
import '../../../shared/widgets/app_product_grid.dart';
import '../../product/models/product.dart';

/// 2-column product grid for Store Detail.
class StoreProductGrid extends StatelessWidget {
  const StoreProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.onFavoriteTap,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product>? onFavoriteTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return AppProductGrid(
      itemCount: products.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, index) {
        final product = products[index];
        return AppProductCard(
          name: product.name,
          brand: product.brand,
          priceLabel: formatMoney(product.displayPrice, currency: product.currency),
          imageUrl: product.primaryImage.isEmpty ? null : product.primaryImage,
          isFavorite: product.isFavorite,
          onTap: () => onProductTap(product),
          onFavoriteTap:
              onFavoriteTap == null ? null : () => onFavoriteTap!(product),
        );
      },
    );
  }
}
