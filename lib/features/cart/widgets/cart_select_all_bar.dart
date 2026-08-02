import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';

class CartSelectAllBar extends StatelessWidget {
  const CartSelectAllBar({
    super.key,
    required this.allSelected,
    required this.onToggleAll,
    this.itemCount,
  });

  final bool allSelected;
  final ValueChanged<bool> onToggleAll;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: allSelected,
          tristate: true,
          onChanged: (value) => onToggleAll(value ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Text(
            'Select All',
            style: AppTextStyles.titleSmall,
          ),
        ),
        if (itemCount != null)
          Text(
            '$itemCount item(s)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
