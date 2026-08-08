import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';
import 'app_loading.dart';

enum AppButtonVariant { primary, secondary, outline, text, social, destructive }

enum AppButtonSize { medium, small }

/// Primary CTA and secondary action button used across Kutuku screens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isExpanded = true,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool isExpanded;
  final double? height;

  bool get _enabled => onPressed != null && !isLoading;

  double get _height =>
      height ??
      (size == AppButtonSize.small
          ? AppSizes.buttonHeightSm
          : AppSizes.buttonHeight);

  @override
  Widget build(BuildContext context) {
    final child = _buildContent();

    final button = switch (variant) {
      AppButtonVariant.primary ||
      AppButtonVariant.destructive => ElevatedButton(
        onPressed: _enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: variant == AppButtonVariant.destructive
              ? AppColors.danger
              : AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primarySoft,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.button,
        ),
        child: child,
      ),
      AppButtonVariant.secondary || AppButtonVariant.social => OutlinedButton(
        onPressed: _enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.border),
          minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.buttonSecondary,
        ),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: _enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.buttonSecondary.copyWith(
            color: AppColors.primary,
          ),
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: _enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          textStyle: AppTextStyles.link,
        ),
        child: child,
      ),
    };

    if (isExpanded) return button;
    return IntrinsicWidth(child: button);
  }

  Widget _buildContent() {
    if (isLoading) {
      return AppLoading(
        size: 20,
        color:
            variant == AppButtonVariant.primary ||
                variant == AppButtonVariant.destructive
            ? AppColors.white
            : AppColors.primary,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
