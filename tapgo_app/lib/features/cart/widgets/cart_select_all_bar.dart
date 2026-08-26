import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/text_styles.dart';

/// Select-all control for My Cart (supports indeterminate state).
class CartSelectAllBar extends StatelessWidget {
  const CartSelectAllBar({
    super.key,
    required this.allSelected,
    required this.hasSelection,
    required this.onToggleAll,
    this.itemCount,
  });

  final bool allSelected;
  final bool hasSelection;
  final ValueChanged<bool> onToggleAll;
  final int? itemCount;

  bool? get _checkboxValue {
    if (allSelected) return true;
    if (!hasSelection) return false;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _checkboxValue,
          tristate: true,
          onChanged: (value) => onToggleAll(value ?? false),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
        ),
        Expanded(
          child: Text('Select All', style: AppTextStyles.titleSmall),
        ),
        if (itemCount != null)
          Text(
            '$itemCount item${itemCount == 1 ? '' : 's'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
