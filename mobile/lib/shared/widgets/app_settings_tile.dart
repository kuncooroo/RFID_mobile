import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';

/// Settings list tile used across the Settings hub screens.
class AppSettingsTile extends StatelessWidget {
  const AppSettingsTile({
    super.key,
    required this.title,
    this.leading,
    this.trailingText,
    this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
  });

  final String title;
  final Widget? leading;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.danger : AppColors.textPrimary;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.settingsTile,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.settingsTile,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.settingsTile,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: color, size: AppSizes.iconMd),
                  child: leading!,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(color: color),
                ),
              ),
              if (trailingText != null) ...[
                Text(trailingText!, style: AppTextStyles.bodySmall),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (showChevron && !isDestructive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
