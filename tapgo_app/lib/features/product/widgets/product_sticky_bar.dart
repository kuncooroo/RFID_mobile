import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/product.dart';

/// Sticky bottom bar with price and Add to Cart CTA.
class ProductStickyBar extends StatelessWidget {
  const ProductStickyBar({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.isLoading = false,
  });

  final Product product;
  final VoidCallback? onAddToCart;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final priceText = formatMoney(
      product.displayPrice,
      currency: product.currency,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Price', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Text(priceText, style: AppTextStyles.priceLarge),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          formatMoney(product.price, currency: product.currency),
                          style: AppTextStyles.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: AppButton(
                label: 'Add to Cart',
                onPressed: product.inStock ? onAddToCart : null,
                isLoading: isLoading,
                isExpanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
