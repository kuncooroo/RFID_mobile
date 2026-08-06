import 'package:flutter/material.dart';

import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_product_card.dart';
import '../../../shared/widgets/app_product_grid.dart';
import '../../product/models/product.dart';

class SearchResultsGrid extends StatelessWidget {
  const SearchResultsGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onFavoriteTap,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onFavoriteTap;
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
          onFavoriteTap: () => onFavoriteTap(product),
        );
      },
    );
  }
}
