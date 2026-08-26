import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/text_styles.dart';

/// Quantity stepper used on Product Detail and Cart.
class AppQtyStepper extends StatelessWidget {
  const AppQtyStepper({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 99,
    this.onChanged,
    this.width = AppSizes.qtyStepperWidth,
    this.height = AppSizes.qtyStepperHeight,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min && onChanged != null;
    final canIncrement = value < max && onChanged != null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            onTap: () => onChanged?.call(value - 1),
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall,
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            onTap: () => onChanged?.call(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AppRadius.fullAll,
      child: SizedBox(
        width: AppSizes.iconButton,
        height: double.infinity,
        child: Icon(
          icon,
          size: AppSizes.iconSm,
          color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
        ),
      ),
    );
  }
}
