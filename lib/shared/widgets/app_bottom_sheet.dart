import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';

/// Shows a Kutuku-styled modal bottom sheet and returns its result.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isScrollControlled = true,
  bool showHandle = true,
  bool isDismissible = true,
  bool enableDrag = true,
  EdgeInsetsGeometry? padding,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (context) => AppBottomSheet(
      title: title,
      showHandle: showHandle,
      padding: padding,
      child: child,
    ),
  );
}

/// Bottom sheet shell used for Filter By and option pickers.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
  });

  final Widget child;
  final String? title;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.bottomSheet,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xxl,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                Container(
                  width: AppSizes.bottomSheetHandleWidth,
                  height: AppSizes.bottomSheetHandleHeight,
                  decoration: BoxDecoration(
                    color: AppColors.bottomSheetHandle,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (title != null) ...[
                Text(title!, style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.xl),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
