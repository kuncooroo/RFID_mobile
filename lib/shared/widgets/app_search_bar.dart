import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';

/// Search field used on Home entry, Search, Results, and Store filter hosts.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFilterTap,
    this.readOnly = false,
    this.autofocus = false,
    this.showFilter = false,
    this.leading,
    this.trailing,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final bool readOnly;
  final bool autofocus;
  final bool showFilter;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.inputHeight,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        style: AppTextStyles.inputText,
        cursorColor: AppColors.primary,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.inputPlaceholder,
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child:
                leading ??
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: AppSizes.iconMd,
                ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: AppSizes.iconButton,
            minHeight: AppSizes.iconButton,
          ),
          suffixIcon:
              trailing ??
              (showFilter
                  ? IconButton(
                      onPressed: onFilterTap,
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.textPrimary,
                        size: AppSizes.iconMd,
                      ),
                    )
                  : null),
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: AppColors.inputBorderFocused,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
