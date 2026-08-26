import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_color_swatch.dart';
import '../../../shared/widgets/app_qty_stepper.dart';
import '../../../shared/widgets/app_rating.dart';
import '../models/product.dart';
import 'product_store_row.dart';

Color _hexToColor(String hex) {
  final value = hex.replaceFirst('#', '');
  if (value.length == 6) {
    return Color(int.parse('FF$value', radix: 16));
  }
  if (value.length == 8) {
    return Color(int.parse(value, radix: 16));
  }
  return AppColors.textPrimary;
}

/// Title, rating, stock, quantity, colors, sizes, and description (Detail / v2).
class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({
    super.key,
    required this.product,
    required this.selectedColorId,
    required this.selectedSize,
    required this.quantity,
    required this.descriptionExpanded,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.onQuantityChanged,
    required this.onReadMoreTap,
    this.storeLogoUrl,
    this.storeVerified = false,
    this.onStoreTap,
  });

  final Product product;
  final String? selectedColorId;
  final String? selectedSize;
  final int quantity;
  final bool descriptionExpanded;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onSizeSelected;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onReadMoreTap;
  final String? storeLogoUrl;
  final bool storeVerified;
  final VoidCallback? onStoreTap;

  String? get _selectedColorName {
    final id = selectedColorId;
    if (id == null) return null;
    for (final color in product.colors) {
      if (color.id == id) return color.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
        AppSpacing.screenHorizontal,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.brand != null && onStoreTap != null) ...[
            ProductStoreRow(
              storeName: product.brand!,
              logoUrl: storeLogoUrl,
              isVerified: storeVerified,
              onTap: onStoreTap,
            ),
            const SizedBox(height: AppSpacing.xl),
          ] else if (product.brand != null) ...[
            Text(product.brand!, style: AppTextStyles.productBrand),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(product.name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          AppRating(rating: product.rating, reviewCount: product.reviewCount),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  _stockLabel(product),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: product.inStock
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
              ),
              AppQtyStepper(
                value: quantity,
                max: product.stock > 0 ? product.stock : 99,
                onChanged: product.inStock ? onQuantityChanged : null,
              ),
            ],
          ),
          if (product.colors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.section),
            Row(
              children: [
                Text('Color', style: AppTextStyles.titleSmall),
                if (_selectedColorName != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _selectedColorName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: product.colors.map((color) {
                return AppColorSwatch(
                  color: _hexToColor(color.hex),
                  selected: color.id == selectedColorId,
                  onTap: () => onColorSelected(color.id),
                );
              }).toList(),
            ),
          ],
          if (product.sizes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.section),
            Text('Size', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: product.sizes.map((size) {
                return AppChip(
                  label: size,
                  selected: size == selectedSize,
                  onTap: () => onSizeSelected(size),
                );
              }).toList(),
            ),
          ],
          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.section),
            Text('Description', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              product.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: descriptionExpanded ? null : 3,
              overflow: descriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (!_isShortDescription(product.description!))
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: GestureDetector(
                  onTap: onReadMoreTap,
                  child: Text(
                    descriptionExpanded ? 'Read Less' : 'Read More',
                    style: AppTextStyles.link,
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  String _stockLabel(Product product) {
    if (!product.inStock) return 'Out of stock';
    if (product.stock <= 5) return 'Only ${product.stock} left';
    return 'In stock';
  }

  bool _isShortDescription(String text) {
    return text.length <= 120;
  }
}
