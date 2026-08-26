import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';
import 'app_badge.dart';

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
    this.onClear,
    this.readOnly = false,
    this.autofocus = false,
    this.showFilter = false,
    this.filterActive = false,
    this.showClear = false,
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
  final VoidCallback? onClear;
  final bool readOnly;
  final bool autofocus;
  final bool showFilter;
  final bool filterActive;
  final bool showClear;
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
          suffixIcon: trailing ?? _buildSuffix(),
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

  Widget? _buildSuffix() {
    final children = <Widget>[];

    if (showClear && onClear != null) {
      children.add(
        IconButton(
          tooltip: 'Clear',
          onPressed: onClear,
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
            size: AppSizes.iconSm,
          ),
        ),
      );
    }

    if (showFilter) {
      children.add(
        IconButton(
          tooltip: 'Filter',
          onPressed: onFilterTap,
          icon: filterActive
              ? AppBadge.dot(
                  offset: const Offset(4, 4),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textPrimary,
                    size: AppSizes.iconMd,
                  ),
                )
              : const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textPrimary,
                  size: AppSizes.iconMd,
                ),
        ),
      );
    }

    if (children.isEmpty) return null;
    if (children.length == 1) return children.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
